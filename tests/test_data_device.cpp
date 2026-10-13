// Real protocol connections, FD transfer and focused selection ownership.
#include "compositor-core.h"
#include "seat.h"
#include <wayland-client.h>
#include <wayland-server.h>
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>

static void check(bool ok, const char* why) { if (!ok) { std::fprintf(stderr,"DATA DEVICE FAIL: %s\n",why); std::exit(1); } }
struct Client {
    wl_display* display{}; wl_client* server{}; wl_compositor* compositor{};
    wl_seat* seat{}; wl_data_device_manager* manager{}; wl_data_device* device{};
    wl_keyboard* keyboard{}; wl_surface* surface{}; wl_data_offer* selection{};
    std::vector<wl_data_offer*> offers;
    uint32_t serial{}; int cancelled{}, sends{}, mime_types{};
};
static wl_display* server;
static std::vector<Client*> clients;
static void global(void* data,wl_registry* registry,uint32_t name,const char* interface,uint32_t version) {
    auto& c=*static_cast<Client*>(data);
    if (!std::strcmp(interface,"wl_compositor")) c.compositor=static_cast<wl_compositor*>(wl_registry_bind(registry,name,&wl_compositor_interface,4));
    if (!std::strcmp(interface,"wl_seat")) c.seat=static_cast<wl_seat*>(wl_registry_bind(registry,name,&wl_seat_interface,5));
    if (!std::strcmp(interface,"wl_data_device_manager")) {
        check(version==1,"only implemented data-device v1 advertised");
        c.manager=static_cast<wl_data_device_manager*>(wl_registry_bind(registry,name,&wl_data_device_manager_interface,1));
    }
}
static void removed(void*,wl_registry*,uint32_t) {}
static const wl_registry_listener globals={global,removed};
static void mime(void* data,wl_data_offer*,const char* type) { check(!std::strcmp(type,"text/plain"),"offered MIME"); ++static_cast<Client*>(data)->mime_types; }
static const wl_data_offer_listener offer_listener=[] { wl_data_offer_listener l{}; l.offer=mime; return l; }();
static void offer(void* data,wl_data_device*,wl_data_offer* value) {
    auto& c=*static_cast<Client*>(data); c.offers.push_back(value); wl_data_offer_add_listener(value,&offer_listener,&c);
}
static void selected(void* data,wl_data_device*,wl_data_offer* value) { static_cast<Client*>(data)->selection=value; }
static const wl_data_device_listener device_listener=[] { wl_data_device_listener l{}; l.data_offer=offer; l.selection=selected; return l; }();
static void keymap(void*,wl_keyboard*,uint32_t,int32_t fd,uint32_t) { close(fd); }
static void entered(void* data,wl_keyboard*,uint32_t serial,wl_surface*,wl_array*) { static_cast<Client*>(data)->serial=serial; }
static void left(void*,wl_keyboard*,uint32_t,wl_surface*) {}
static void mods(void*,wl_keyboard*,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t) {}
static void repeat(void*,wl_keyboard*,int32_t,int32_t) {}
static const wl_keyboard_listener keyboard_listener=[] { wl_keyboard_listener l{}; l.keymap=keymap;l.enter=entered;l.leave=left;l.modifiers=mods;l.repeat_info=repeat;return l; }();
static void target(void*,wl_data_source*,const char*) {}
static void send(void* data,wl_data_source*,const char* type,int32_t fd) {
    check(!std::strcmp(type,"text/plain"),"send MIME");
    check(write(fd,"hello",5)==5,"send selection bytes"); close(fd); ++static_cast<Client*>(data)->sends;
}
static void cancelled(void* data,wl_data_source*) { ++static_cast<Client*>(data)->cancelled; }
static const wl_data_source_listener source_listener=[] { wl_data_source_listener l{};l.target=target;l.send=send;l.cancelled=cancelled;return l; }();
static void pump() {
    for (auto* c:clients) check(wl_display_flush(c->display)>=0,"client flush");
    check(wl_event_loop_dispatch(wl_display_get_event_loop(server),0)>=0,"server dispatch");
    wl_display_flush_clients(server);
    for (auto* c:clients) {
        pollfd fd{wl_display_get_fd(c->display),POLLIN,0};
        if (poll(&fd,1,0)>0) check(wl_display_dispatch(c->display)>=0,"client dispatch");
        check(wl_display_dispatch_pending(c->display)>=0,"pending dispatch");
    }
}
static void done(void* data,wl_callback* callback,uint32_t) { *static_cast<bool*>(data)=true;wl_callback_destroy(callback); }
static const wl_callback_listener sync_listener={done};
static void sync(Client& c) {
    bool completed=false;wl_callback_add_listener(wl_display_sync(c.display),&sync_listener,&completed);
    while (!completed) pump();
    for(int i=0;i<4;++i) pump();
}
static void connect(Client& c) {
    int fd[2];check(socketpair(AF_UNIX,SOCK_STREAM|SOCK_CLOEXEC,0,fd)==0,"socketpair");
    c.server=wl_client_create(server,fd[0]); c.display=wl_display_connect_to_fd(fd[1]);
    check(c.server && c.display,"connect"); clients.push_back(&c);
    wl_registry_add_listener(wl_display_get_registry(c.display),&globals,&c);sync(c);
    check(c.compositor && c.seat && c.manager,"GTK seat prerequisite globals");
    c.keyboard=wl_seat_get_keyboard(c.seat);wl_keyboard_add_listener(c.keyboard,&keyboard_listener,&c);
    c.device=wl_data_device_manager_get_data_device(c.manager,c.seat);wl_data_device_add_listener(c.device,&device_listener,&c);
    c.surface=wl_compositor_create_surface(c.compositor);sync(c);
}
static wl_data_source* source(Client& c) {
    auto* value=wl_data_device_manager_create_data_source(c.manager);
    wl_data_source_add_listener(value,&source_listener,&c);wl_data_source_offer(value,"text/plain");return value;
}
static void read_offer(Client& c,wl_data_offer* offer,bool allowed,const char* type="text/plain") {
    int fd[2];check(pipe(fd)==0,"receive pipe");wl_data_offer_receive(offer,type,fd[1]);close(fd[1]);sync(c);
    char bytes[8]{};ssize_t size=read(fd[0],bytes,sizeof(bytes));close(fd[0]);
    check(allowed ? size==5 && !std::memcmp(bytes,"hello",5) : size==0,"selection FD authorization/content");
}
int main() {
    alarm(10);server=wl_display_create();check(server,"display");
    auto* compositor=compositor_core_create(server);auto* seat=seat_create(server,5);check(compositor && seat,"core and seat");
    compositor_set_seat(compositor,seat);
    Client a,b;connect(a);connect(b);
    auto focus=[&](Client& c) { seat_set_keyboard_focus(seat,wl_client_get_object(c.server,wl_proxy_get_id(reinterpret_cast<wl_proxy*>(c.surface))),compositor);sync(c); };
    check(a.offers.empty() && b.offers.empty(),"no world-mode selection leak");
    focus(a);auto* sa=source(a);wl_data_device_set_selection(a.device,sa,a.serial);sync(a);
    check(a.selection && a.mime_types==1 && b.selection==nullptr,"selection delivered only to focused client");
    auto* old_a=a.selection;read_offer(a,old_a,true);
    auto* sb=source(b);wl_data_device_set_selection(b.device,sb,a.serial);sync(b);
    check(a.cancelled==0 && b.selection==nullptr,"unfocused setter rejected");
    focus(b);check(b.selection && b.mime_types==1,"focus transfers offer");read_offer(b,b.selection,true);
    read_offer(a,old_a,false);read_offer(b,b.selection,false,"application/unknown");
    auto* old_b=b.selection;wl_data_device_set_selection(b.device,sb,b.serial);sync(b);
    check(a.cancelled==1 && b.selection!=old_b,"replacement cancels old source");read_offer(b,old_b,false);read_offer(b,b.selection,true);
    wl_data_device_set_selection(b.device,nullptr,b.serial);sync(b);
    check(b.cancelled==1 && b.selection==nullptr,"clear selection");
    auto* sc=source(b);wl_data_device_set_selection(b.device,sc,b.serial+10000);sync(b);
    check(b.selection==nullptr,"future serial rejected");
    wl_data_device_set_selection(b.device,sc,b.serial);sync(b);auto* dead=b.selection;
    wl_data_source_destroy(sc);sync(b);check(b.selection==nullptr,"source destroy clears selection");read_offer(b,dead,false);
    auto* drag=source(b);wl_data_device_start_drag(b.device,drag,b.surface,nullptr,b.serial);sync(b);
    check(b.cancelled==2,"unsupported drag explicitly cancelled");
    auto* sd=source(b);wl_data_device_set_selection(b.device,sd,b.serial);sync(b);dead=b.selection;
    wl_surface_destroy(b.surface);sync(b);read_offer(b,dead,false);
    check(compositor_core_get_focused_surface(compositor)==nullptr,"destroyed focus cleared");
    // Disconnect the selection owner before the still-connected receiver.
    wl_display_disconnect(b.display);clients.pop_back();pump();focus(a);
    check(a.selection==nullptr,"owner disconnect clears clipboard");
    wl_display_disconnect(a.display);clients.clear();wl_display_destroy_clients(server);
    seat_destroy(seat);compositor_core_destroy(compositor);wl_display_destroy(server);
    std::puts("DATA_DEVICE_OK focused selection, transfer, replacement, stale offers, MIME, destruction, drag cancellation");
}
