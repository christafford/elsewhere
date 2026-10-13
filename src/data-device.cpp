#include "data-device.h"
#include "seat-private.h"
#include <algorithm>
#include <cstring>
#include <new>
#include <string>
#include <vector>
#include <unistd.h>
#include <wayland-server-protocol.h>

struct DataSource;
struct ElsewhereDataDevice {
    ElsewhereSeat* seat;
    wl_global* global;
    wl_list managers, devices, sources, offers;
    DataSource* selection = nullptr;
    bool destroying = false;
};
namespace {
struct DataOffer { ElsewhereDataDevice* owner; DataSource* source; };
}
struct DataSource {
    ElsewhereDataDevice* owner;
    wl_resource* resource;
    std::vector<std::string> types;
    bool used = false;
};
namespace {
wl_client* focused(ElsewhereDataDevice* data) {
    auto* surface = data->seat->focused_surface_resource;
    return surface ? wl_resource_get_client(surface) : nullptr;
}
void release(wl_client*, wl_resource* resource) { wl_resource_destroy(resource); }
void unlink(wl_resource* resource) { wl_list_remove(wl_resource_get_link(resource)); }
bool active(wl_resource* resource, DataOffer* offer) {
    return offer->source && offer->source == offer->owner->selection &&
           focused(offer->owner) == wl_resource_get_client(resource);
}
bool has_type(DataSource* source, const char* type) {
    return type && std::find(source->types.begin(), source->types.end(), type) != source->types.end();
}
void accept(wl_client*, wl_resource* resource, uint32_t, const char* type) {
    auto* offer = static_cast<DataOffer*>(wl_resource_get_user_data(resource));
    if (active(resource, offer))
        wl_data_source_send_target(offer->source->resource, has_type(offer->source, type) ? type : nullptr);
}
void receive(wl_client*, wl_resource* resource, const char* type, int32_t fd) {
    auto* offer = static_cast<DataOffer*>(wl_resource_get_user_data(resource));
    if (active(resource, offer) && has_type(offer->source, type))
        wl_data_source_send_send(offer->source->resource, type, fd);
    close(fd);
}
const struct wl_data_offer_interface offer_impl = {accept, receive, release, nullptr, nullptr};
void offer_destroyed(wl_resource* resource) {
    unlink(resource);
    delete static_cast<DataOffer*>(wl_resource_get_user_data(resource));
}
void selection_to(wl_resource* device) {
    auto* data = static_cast<ElsewhereDataDevice*>(wl_resource_get_user_data(device));
    auto* client = wl_resource_get_client(device);
    if (client != focused(data)) return;
    if (!data->selection) { wl_data_device_send_selection(device, nullptr); return; }
    auto* resource = wl_resource_create(client, &wl_data_offer_interface, 1, 0);
    if (!resource) { wl_client_post_no_memory(client); return; }
    auto* offer = new (std::nothrow) DataOffer{data, data->selection};
    if (!offer) { wl_resource_destroy(resource); wl_client_post_no_memory(client); return; }
    wl_resource_set_implementation(resource, &offer_impl, offer, offer_destroyed);
    wl_list_insert(&data->offers, wl_resource_get_link(resource));
    wl_data_device_send_data_offer(device, resource);
    for (const auto& type : data->selection->types) wl_data_offer_send_offer(resource, type.c_str());
    wl_data_device_send_selection(device, resource);
}
void source_offer(wl_client* client, wl_resource* resource, const char* type) try {
    auto* source = static_cast<DataSource*>(wl_resource_get_user_data(resource));
    if (!source->used && !has_type(source, type)) source->types.emplace_back(type);
} catch (const std::bad_alloc&) { wl_client_post_no_memory(client); }
const struct wl_data_source_interface source_impl = {source_offer, release, nullptr};
void source_destroyed(wl_resource* resource) {
    auto* source = static_cast<DataSource*>(wl_resource_get_user_data(resource));
    auto* data = source->owner;
    wl_resource* item;
    wl_resource_for_each(item, &data->offers) {
        auto* offer = static_cast<DataOffer*>(wl_resource_get_user_data(item));
        if (offer->source == source) offer->source = nullptr;
    }
    if (data->selection == source) {
        data->selection = nullptr;
        if (!data->destroying) data_device_focus(data);
    }
    unlink(resource);
    delete source;
}
void set_selection(wl_client* client, wl_resource* device, wl_resource* resource, uint32_t serial) {
    auto* data = static_cast<ElsewhereDataDevice*>(wl_resource_get_user_data(device));
    // Only the focused nested client can replace the selection; reject serials
    // predating this focus or newer than any event this display has generated.
    if (client != focused(data) || int32_t(serial - data->seat->focus_serial) < 0 ||
        int32_t(wl_display_get_serial(data->seat->display) - serial) < 0) return;
    DataSource* source = nullptr;
    if (resource) {
        if (!wl_resource_instance_of(resource, &wl_data_source_interface, &source_impl)) return;
        source = static_cast<DataSource*>(wl_resource_get_user_data(resource));
        if (source->owner != data || wl_resource_get_client(resource) != client || source->used) return;
        source->used = true;
    }
    if (data->selection) wl_data_source_send_cancelled(data->selection->resource);
    data->selection = source;
    data_device_focus(data);
}
void start_drag(wl_client* client, wl_resource*, wl_resource* source, wl_resource*, wl_resource*, uint32_t) {
    // No drag destinations are exposed yet. End the operation explicitly; do
    // not retain the source, grant a grab, or claim a successful drop.
    if (source && wl_resource_get_client(source) == client &&
        wl_resource_instance_of(source, &wl_data_source_interface, &source_impl)) {
        auto* data = static_cast<DataSource*>(wl_resource_get_user_data(source));
        if (!data->used) { data->used = true; wl_data_source_send_cancelled(source); }
    }
}
const struct wl_data_device_interface device_impl = {start_drag, set_selection, release};
void create_source(wl_client* client, wl_resource* manager, uint32_t id) {
    auto* data = static_cast<ElsewhereDataDevice*>(wl_resource_get_user_data(manager));
    auto* resource = wl_resource_create(client, &wl_data_source_interface, 1, id);
    if (!resource) { wl_client_post_no_memory(client); return; }
    auto* source = new (std::nothrow) DataSource{data, resource, {}, false};
    if (!source) { wl_resource_destroy(resource); wl_client_post_no_memory(client); return; }
    wl_resource_set_implementation(resource, &source_impl, source, source_destroyed);
    wl_list_insert(&data->sources, wl_resource_get_link(resource));
}
void get_device(wl_client* client, wl_resource* manager, uint32_t id, wl_resource* seat) {
    auto* data = static_cast<ElsewhereDataDevice*>(wl_resource_get_user_data(manager));
    if (std::strcmp(wl_resource_get_class(seat), "wl_seat") || wl_resource_get_user_data(seat) != data->seat) {
        wl_client_post_implementation_error(client, "Data device requested for a different seat");
        return;
    }
    auto* resource = wl_resource_create(client, &wl_data_device_interface, 1, id);
    if (!resource) { wl_client_post_no_memory(client); return; }
    wl_resource_set_implementation(resource, &device_impl, data, unlink);
    wl_list_insert(&data->devices, wl_resource_get_link(resource));
    selection_to(resource);
}
const struct wl_data_device_manager_interface manager_impl = {create_source, get_device, nullptr};
void bind_manager(wl_client* client, void* state, uint32_t, uint32_t id) {
    auto* data = static_cast<ElsewhereDataDevice*>(state);
    auto* resource = wl_resource_create(client, &wl_data_device_manager_interface, 1, id);
    if (!resource) { wl_client_post_no_memory(client); return; }
    wl_resource_set_implementation(resource, &manager_impl, data, unlink);
    wl_list_insert(&data->managers, wl_resource_get_link(resource));
}
}
ElsewhereDataDevice* data_device_create(ElsewhereSeat* seat) {
    auto* data = new (std::nothrow) ElsewhereDataDevice{};
    if (!data) return nullptr;
    data->seat = seat;
    for (auto* list : {&data->managers, &data->devices, &data->sources, &data->offers}) wl_list_init(list);
    data->global = wl_global_create(seat->display, &wl_data_device_manager_interface, 1, data, bind_manager);
    if (!data->global) { delete data; return nullptr; }
    return data;
}
void data_device_focus(ElsewhereDataDevice* data) {
    if (!data || data->destroying) return;
    wl_resource* resource;
    // Old offers cease to authorize reads after focus or selection changes.
    wl_resource_for_each(resource, &data->offers)
        static_cast<DataOffer*>(wl_resource_get_user_data(resource))->source = nullptr;
    wl_resource_for_each(resource, &data->devices) selection_to(resource);
}
void data_device_destroy(ElsewhereDataDevice* data) {
    if (!data) return;
    data->destroying = true;
    for (auto* list : {&data->offers, &data->sources, &data->devices, &data->managers})
        while (!wl_list_empty(list)) wl_resource_destroy(wl_resource_from_link(list->next));
    wl_global_destroy(data->global);
    delete data;
}
