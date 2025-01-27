const std = @import("std");
const sdl = @import("../sdl/sdl.zig");

pub fn click_obj(renderer: sdl.Renderer) !void {
    const body_1 = sdl.RigidBody.init(sdl.Rect.init(320, 200, 20, 20, sdl.Color{ .red = 0xff, .green = 0, .blue = 0, .alpha = 0xff }));

    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                sdl.EventType.MouseButtonDown => {
                    std.log.debug("is in body? {}", .{sdl.inside(event.getMousePosition(), body_1)});
                },
                else => {},
            }
        }

        try renderer.setDrawColor(sdl.Color{ .red = 0xff, .green = 0xff, .blue = 0xff, .alpha = 0xff });
        try renderer.clear();

        try renderer.setDrawColor(body_1.rect.color);
        try renderer.fillRect(body_1.rect);

        renderer.present();
    }
}
