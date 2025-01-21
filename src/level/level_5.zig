const std = @import("std");
const sdl = @import("../sdl/sdl.zig");

pub fn shooting(renderer: sdl.Renderer) !void {
    var body_1 = sdl.RigidBody.init(sdl.Rect.init(320, 200, 10, 10, sdl.Color{ .red = 0xff, .green = 0, .blue = 0, .alpha = 0xff }));

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var projectiles = std.ArrayList(sdl.RigidBody).init(allocator);
    defer projectiles.deinit();

    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                sdl.EventType.Keydown => {
                    switch (event.getKeyCode()) {
                        sdl.KeyEvent.Space => {
                            var projectile = sdl.RigidBody.init(sdl.Rect.init(body_1.rect.sdl_rect.x + 1, body_1.rect.sdl_rect.y, 4, 4, sdl.Color{ .red = 0, .green = 0xff, .blue = 0, .alpha = 0xff }));
                            projectile.velocity.x = 2;
                            try projectiles.append(projectile);
                        },
                        else => {},
                    }
                },
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

        try renderer.setDrawColor(sdl.Color{ .red = 0xff, .green = 0xff, .blue = 0xff, .alpha = 0xff });
        try renderer.clear();

        var i: usize = 0;
        while (i < projectiles.items.len) {
            if (projectiles.items[i].rect.sdl_rect.x > body_1.rect.sdl_rect.x + 200) {
                _ = projectiles.swapRemove(i);
                continue;
            }

            try renderer.setDrawColor(projectiles.items[i].rect.color);
            projectiles.items[i].move();
            try renderer.fillRect(projectiles.items[i].rect);
            i += 1;
        }

        try renderer.setDrawColor(body_1.rect.color);

        body_1.move();

        try renderer.fillRect(body_1.rect);
        body_1.velocity.x = 0;
        body_1.velocity.y = 0;

        renderer.present();
    }
}
