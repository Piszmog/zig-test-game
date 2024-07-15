const std = @import("std");
const sdl = @import("sdl/sdl.zig");

pub fn main() !void {
    sdl.init();
    defer sdl.stop();

    const window = try sdl.Window.init("Zig Game", sdl.WindowCentered, sdl.WindowCentered, 640, 400);
    defer window.cleanup();

    const renderer = try sdl.Renderer.init(&window, 0, sdl.RendererFlag.PresentVSync);
    defer renderer.cleanup();

    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                else => {},
            }
        }

        try renderer.setDrawColor(0xff, 0xff, 0xff, 0xff);
        try renderer.clear();

        try renderer.setDrawColor(0xff, 0, 0, 0xff);
        try renderer.drawRect(20, 20, 10, 10);
        try renderer.fillRect(10, 10, 10, 10);

        const rects = [_]sdl.Rect{
            .{ .x = 30, .y = 30, .width = 10, .height = 10 },
        };
        try renderer.drawRects(&rects);

        renderer.present();
    }
}
