const std = @import("std");
const sdl = @import("../sdl/sdl.zig");

pub fn collisions(renderer: sdl.Renderer) !void {
    var body_1 = sdl.RigidBody.init(sdl.Rect.init(320, 200, 10, 10, sdl.Color{ .red = 0xff, .green = 0, .blue = 0, .alpha = 0xff }));
    const body_2 = sdl.RigidBody.init(sdl.Rect.init(300, 200, 10, 10, sdl.Color{ .red = 0xff, .green = 0, .blue = 0, .alpha = 0xff }));

    const static_bodies = [_]sdl.RigidBody{body_2};

    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                sdl.EventType.Keydown => {
                    switch (event.getKeyCode()) {
                        sdl.KeyEvent.Up => body_1.velocity.y = -2,
                        sdl.KeyEvent.Down => body_1.velocity.y = 2,
                        sdl.KeyEvent.Left => body_1.velocity.x = -2,
                        sdl.KeyEvent.Right => body_1.velocity.x = 2,
                        else => {},
                    }
                },
                else => {},
            }
        }

        try renderer.setDrawColor(sdl.Color{ .red = 0xff, .green = 0xff, .blue = 0xff, .alpha = 0xff });
        try renderer.clear();

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

        for (static_bodies) |body| {
            try renderer.setDrawColor(body.rect.color);
            try renderer.fillRect(body.rect);
        }

        body_1.move();
        try renderer.setDrawColor(body_1.rect.color);
        try renderer.fillRect(body_1.rect);
        body_1.velocity.x = 0;
        body_1.velocity.y = 0;

        renderer.present();
    }
}
