const std = @import("std");
const sdl = @import("../sdl/sdl.zig");

pub fn mouse(renderer: sdl.Renderer) !void {
    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                sdl.EventType.MouseButtonDown => {
                    std.log.debug("mouse down {}\n", .{event.getMousePosition()});
                },
                sdl.EventType.MouseButtonUp => {
                    std.log.debug("mouse up {}\n", .{event.getMousePosition()});
                },
                else => {},
            }
        }

        try renderer.setDrawColor(sdl.Color{ .red = 0xff, .green = 0xff, .blue = 0xff, .alpha = 0xff });
        try renderer.clear();

        renderer.present();
    }
}
