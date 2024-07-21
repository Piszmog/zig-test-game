const std = @import("std");
const sdl = @import("sdl/sdl.zig");

pub fn main() !void {
    sdl.init();
    defer sdl.stop();

    const window = try sdl.Window.init("Zig Game", sdl.WindowCentered, sdl.WindowCentered, 640, 400);
    defer window.cleanup();

    const renderer = try sdl.Renderer.init(&window, 0, sdl.RendererFlag.PresentVSync);
    defer renderer.cleanup();

    var posX: i32 = 320;
    var posY: i32 = 200;

    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                sdl.EventType.Keydown => {
                    switch (event.getKeyCode()) {
                        sdl.KeyCode.Up => posY -= 5,
                        sdl.KeyCode.Down => posY += 5,
                        sdl.KeyCode.Left => posX -= 5,
                        sdl.KeyCode.Right => posX += 5,
                        else => {},
                    }
                },
                else => {},
            }
        }

        try renderer.setDrawColor(0xff, 0xff, 0xff, 0xff);
        try renderer.clear();

        try renderer.setDrawColor(0xff, 0, 0, 0xff);
        try renderer.fillRect(posX, posY, 10, 10);

        renderer.present();
    }
}
