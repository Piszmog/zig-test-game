const std = @import("std");
const sdl = @import("../sdl/sdl.zig");

pub fn move_obj(renderer: sdl.Renderer) !void {
    var body_1 = sdl.RigidBody.init(sdl.Rect.init(320, 200, 20, 20, sdl.Color{ .red = 0xff, .green = 0, .blue = 0, .alpha = 0xff }));

    var moving = false;
    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                sdl.EventType.MouseButtonDown => {
                    if (sdl.inside(event.getMousePosition(), body_1)) {
                        moving = true;
                    }
                },
                sdl.EventType.MouseButtonUp => {
                    if (moving) {
                        const p = event.getMousePosition();
                        const w: i32 = @intCast(body_1.rect.sdl_rect.w);
                        const h: i32 = @intCast(body_1.rect.sdl_rect.h);
                        const middle_x = @divTrunc(w, 2);
                        const middle_y = @divTrunc(h, 2);

                        body_1.rect.sdl_rect.x = p.x - middle_x;
                        body_1.rect.sdl_rect.y = p.y - middle_y;
                        moving = false;
                    }
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
