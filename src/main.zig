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

        var rect = sdl.Rect.init(0, 0, 60, 60);
        const a = 0.001 * @as(f32, @floatFromInt(sdl.getTicks()));
        const t = 2 * std.math.pi / 3.0;
        const r = 100 * @cos(0.1 * a);

        rect.setX(290 + @as(i32, @intFromFloat(r * @cos(a))));
        rect.setY(170 + @as(i32, @intFromFloat(r * @sin(a))));
        // Red
        try renderer.setDrawColor(0xff, 0, 0, 0xff);
        try renderer.fillRect(&rect);

        rect.setX(290 + @as(i32, @intFromFloat(r * @cos(a + t))));
        rect.setY(170 + @as(i32, @intFromFloat(r * @sin(a + t))));
        // Green
        try renderer.setDrawColor(0, 0xff, 0, 0xff);
        try renderer.fillRect(&rect);

        rect.setX(290 + @as(i32, @intFromFloat(r * @cos(a + 2 * t))));
        rect.setY(170 + @as(i32, @intFromFloat(r * @sin(a + 2 * t))));
        // Blue
        try renderer.setDrawColor(0, 0, 0xff, 0xff);
        try renderer.fillRect(&rect);

        renderer.present();
    }
}
