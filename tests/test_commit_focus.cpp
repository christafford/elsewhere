#include "compositor.h"
#include "compositor-private.h"
#include "input.h"
#include "seat-private.h"
#include "xdg-shell.h"
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <functional>
#include <iterator>
#include <string>
#include <sys/wait.h>
#include <unistd.h>

static void check(bool ok, const char* message) {
    if (!ok) { std::fprintf(stderr, "COMMIT FOCUS FAIL: %s\n", message); std::exit(1); }
}
static std::string read(const std::string& path) {
    std::ifstream stream(path); return {std::istreambuf_iterator<char>(stream), {}};
}
static void mark(const std::string& path) { std::ofstream stream(path); check(bool(stream), "marker"); }

int main(int argc, char** argv) {
    check(argc == 2, "fixture executable"); alarm(30);
    char directory[] = "/tmp/elsewhere-commit-focus-XXXXXX";
    check(mkdtemp(directory), "test directory");
    const std::string socket = std::string(directory) + "/wayland";
    auto* display = wl_display_create(); check(display, "display");
    auto* comp = create_compositor(display); check(comp, "compositor");
    auto* seat = create_seat(display); check(seat, "seat");
    g_compositor = comp;
    compositor_set_seat(comp, seat);
    auto* shell = create_xdg_shell(comp, display); check(shell, "shell");
    check(wl_display_init_shm(display) == 0 && wl_display_add_socket(display, socket.c_str()) == 0, "shm/socket");
    auto until = [&](const std::function<bool()>& predicate) {
        const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(5);
        while (!predicate()) {
            check(wl_event_loop_dispatch(wl_display_get_event_loop(display), 0) >= 0, "dispatch");
            wl_display_flush_clients(display);
            check(std::chrono::steady_clock::now() < deadline, "fixture timeout");
            usleep(1000);
        }
    };
    auto wait_file = [&](const std::string& path) { until([&] { return access(path.c_str(), F_OK) == 0; }); };
    auto command = [&](const char* line) {
        InputScript script{};
        script.fp = tmpfile(); check(script.fp, "input script");
        std::fprintf(script.fp, "%s\n", line); std::rewind(script.fp);
        check(input_script_step(&script, seat, comp, nullptr) == 0, "input command");
        std::fclose(script.fp);
    };
    auto spawn = [&](const std::string& base) {
        const auto pid = fork(); check(pid >= 0, "fork");
        if (!pid) { execl(argv[1], argv[1], socket.c_str(), base.c_str(), nullptr); _exit(127); }
        wait_file(base + ".ready"); return pid;
    };
    auto redraw = [&](const std::string& base, int round) {
        const auto path = base + ".redraw-" + std::to_string(round);
        mark(path); wait_file(path + "-ok");
    };
    command("mode app");
    check(input_mode_get() == InputMode::World && !seat->focused_surface_resource, "empty application entry");
    const std::string a = std::string(directory) + "/a", b = std::string(directory) + "/b";
    const auto pid_a = spawn(a);
    check(!seat->focused_surface_resource && !comp->focused_surface_resource && read(a + ".events").empty(),
          "initial commits selected a window");
    command("mode app");
    auto* selected = seat->focused_surface_resource;
    check(selected && input_mode_get() == InputMode::Application, "explicit application entry selects mapped window");
    until([&] { return read(a + ".events").find("1 enter 0\n") != std::string::npos; });
    const auto pid_b = spawn(b);
    check(seat->focused_surface_resource == selected && comp->focused_surface_resource == selected,
          "new background mapping stole focus");
    const auto selected_events = read(a + ".events");
    for (const auto& base : {b, a}) {
        redraw(base, 0);
        check(seat->focused_surface_resource == selected && comp->focused_surface_resource == selected,
              "buffer/metadata/roleless commits stole focus");
        check(read(a + ".events") == selected_events && read(b + ".events").empty(), "redraw emitted focus events");
    }
    command("key 42 press"); command("key 30 press");
    until([&] { return read(a + ".events").find("1 key 30 1 65\n") != std::string::npos; });
    command("focus lost");
    until([&] { return read(a + ".events").find("1 leave\n") != std::string::npos; });
    check(read(a + ".events").find("1 key 42 0") != std::string::npos && read(b + ".events").empty(),
          "held-key cleanup leaked to background client");
    const auto unfocused_events = read(a + ".events");
    redraw(b, 1); redraw(a, 1);
    check(!seat->focused_surface_resource && input_mode_get() == InputMode::World, "redraw restored lost focus");
    check(read(a + ".events") == unfocused_events && read(b + ".events").empty(), "unfocused redraw emitted input");
    command("focus gained");
    check(seat->focused_surface_resource == selected && input_mode_get() == InputMode::Application,
          "host focus restores selected application");
    command("mode world");
    command("focus gained");
    check(input_mode_get() == InputMode::World && !seat->focused_surface_resource, "host gain overrides world selection");
    redraw(b, 2); redraw(a, 2);
    check(!seat->focused_surface_resource, "world-mode redraw reacquired focus");
    command("key 30 press");
    check(read(b + ".events").empty(), "keys leaked to background client");
    command("mode app");
    check(seat->focused_surface_resource == selected, "application reentry preserves selection");
    mark(a + ".destroy"); wait_file(a + ".destroy-ok");
    check(!seat->focused_surface_resource, "selected destruction did not clear seat focus");
    check(!comp->focused_surface_resource, "selected destruction did not clear compositor focus");
    check(input_mode_get() == InputMode::World, "selected destruction did not return to world mode");
    redraw(b, 3);
    check(!seat->focused_surface_resource && read(b + ".events").empty(), "remaining app stole focus after destruction");
    command("mode app");
    check(seat->focused_surface_resource, "explicitly select remaining app");
    until([&] { return read(b + ".events").find("1 enter 0\n") != std::string::npos; });
    command("key 30 press"); command("key 30 release");
    until([&] { return read(b + ".events").find("1 key 30 0 97\n") != std::string::npos; });
    mark(a + ".finish"); mark(b + ".finish");
    wait_file(a + ".ok"); wait_file(b + ".ok");
    for (auto pid : {pid_a, pid_b}) {
        int status; check(waitpid(pid, &status, 0) == pid && WIFEXITED(status) && WEXITSTATUS(status) == 0, "fixture exit");
    }
    wl_display_destroy_clients(display);
    destroy_xdg_shell(shell); destroy_compositor(comp); destroy_seat(seat);
    g_compositor = nullptr;
    wl_display_destroy(display);
    for (const auto& base : {a, b}) {
        for (const char* suffix : {"events", "ready", "destroy", "destroy-ok", "finish", "ok"}) unlink((base + "." + suffix).c_str());
        for (int i=0; i<4; ++i) for (const char* suffix : {"", "-ok"}) unlink((base + ".redraw-" + std::to_string(i) + suffix).c_str());
    }
    check(rmdir(directory) == 0, "cleanup");
    std::puts("COMMIT_FOCUS_OK: explicit selection, background map/redraw, routed keys, host loss/restore and destruction");
}
