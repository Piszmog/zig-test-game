const std = @import("std");
const sdl = @import("../sdl/sdl.zig");

pub fn gravity(renderer: sdl.Renderer) !void {
    var body_1 = sdl.RigidBody.init(sdl.Rect.init(320, 200, 10, 10));
    const ground = sdl.RigidBody.init(sdl.Rect.init(10, 350, 620, 5));

    const static_bodies = [_]sdl.RigidBody{ground};

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                else => {},
            }
        }

        const scancodes = try sdl.get_keyboard_state(allocator);
        defer allocator.free(scancodes);

        for (scancodes) |scancode| {
            switch (scancode) {
                sdl.Scancode.Up => body_1.velocity.y = -2,
                sdl.Scancode.Down => body_1.velocity.y = 2,
                sdl.Scancode.Left => body_1.velocity.x = -2,
                sdl.Scancode.Right => body_1.velocity.x = 2,
            }
        }

        if (body_1.velocity.y <= 0) {
            body_1.velocity.y += 1;
        }

        try renderer.setDrawColor(sdl.Color{ .red = 0xff, .green = 0xff, .blue = 0xff, .alpha = 0xff });
        try renderer.clear();

        try renderer.setDrawColor(0xff, 0, 0, 0xff);

        for (static_bodies) |body| {
            switch (sdl.check_collision(body_1, body)) {
                sdl.CollisionDirection.Top => {
                    if (body_1.velocity.y < 0) {
                        body_1.velocity.y = 0;
                    }
                    break;
                },
                sdl.CollisionDirection.Bottom => {
                    if (body_1.velocity.y > 0) {
                        body_1.velocity.y = 0;
                    }
                    break;
                },
                sdl.CollisionDirection.Left => {
                    if (body_1.velocity.x < 0) {
                        body_1.velocity.x = 0;
                    }
                    break;
                },
                sdl.CollisionDirection.Right => {
                    if (body_1.velocity.x > 0) {
                        body_1.velocity.x = 0;
                    }
                    break;
                },
                else => {},
            }
        }

        body_1.move();

        try renderer.fillRect(body_1.rect);
        body_1.velocity.x = 0;
        body_1.velocity.y = 0;

        try renderer.setDrawColor(0, 0xff, 0, 0xff);
        try renderer.fillRect(ground.rect);

        renderer.present();
    }
}
