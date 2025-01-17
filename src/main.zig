const std = @import("std");
const sdl = @import("sdl/sdl.zig");

pub fn main() !void {
    sdl.init();
    defer sdl.stop();

    const window = try sdl.Window.init("Zig Game", sdl.WindowCentered, sdl.WindowCentered, 640, 400);
    defer window.cleanup();

    const renderer = try sdl.Renderer.init(&window, 0, sdl.RendererFlag.PresentVSync);
    defer renderer.cleanup();

    var body_1 = sdl.RigidBody.init(sdl.Rect.init(320, 200, 10, 10));
    const body_2 = sdl.RigidBody.init(sdl.Rect.init(300, 200, 10, 10));
    const ground = sdl.RigidBody.init(sdl.Rect.init(10, 350, 620, 5));

    const static_bodies = [_]sdl.RigidBody{ body_2, ground };

    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                sdl.EventType.Keydown => {
                    switch (event.getKeyCode()) {
                        sdl.KeyCode.Up => body_1.velocity.y = -25,
                        sdl.KeyCode.Down => body_1.velocity.y = 5,
                        sdl.KeyCode.Left => body_1.velocity.x = -5,
                        sdl.KeyCode.Right => body_1.velocity.x = 5,
                        else => {},
                    }
                },
                else => {},
            }
        }

        if (body_1.velocity.y <= 0) {
            body_1.velocity.y += 1;
        }

        try renderer.setDrawColor(0xff, 0xff, 0xff, 0xff);
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

        try renderer.setDrawColor(0xff, 0, 0, 0xff);
        try renderer.fillRect(body_2.rect);

        try renderer.setDrawColor(0, 0xff, 0, 0xff);
        try renderer.fillRect(ground.rect);

        renderer.present();
    }
}
