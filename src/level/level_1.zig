const std = @import("std");
const sdl = @import("../sdl/sdl.zig");

pub fn movement(renderer: sdl.Renderer) !void {
    var body_1 = sdl.RigidBody.init(sdl.Rect.init(320, 200, 10, 10, sdl.Color{ .red = 0xff, .green = 0, .blue = 0, .alpha = 0xff }));

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

        try renderer.setDrawColor(body_1.rect.color);

        body_1.move();

        try renderer.fillRect(body_1.rect);
        body_1.velocity.x = 0;
        body_1.velocity.y = 0;

        renderer.present();
    }
}
