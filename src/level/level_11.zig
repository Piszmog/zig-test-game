const std = @import("std");
const sdl = @import("../sdl/sdl.zig");

pub fn text(renderer: sdl.Renderer) !void {
    sdl.init_ttf();
    defer sdl.stop_ttf();

    const font = try sdl.Font.init("/Users/randell/Library/Fonts/MesloLGSNerdFont-Regular.ttf", 24);
    const textSurface = try sdl.TextSurface.init(font, sdl.Color{ .red = 255, .blue = 255, .green = 255, .alpha = 255 }, "Hey there!");
    const textTexture = try renderer.init_text_texture(textSurface);
    textSurface.free();

    const text_rect = sdl.Rect.init(100, 100, 200, 200, sdl.Color.green());

    mainloop: while (true) {
        var event: sdl.Event = undefined;
        while (event.poll()) {
            switch (event.getType()) {
                sdl.EventType.Quit => break :mainloop,
                else => {},
            }
        }

        try renderer.setDrawColor(sdl.Color{ .red = 0xff, .green = 0xff, .blue = 0xff, .alpha = 0xff });
        try renderer.clear();

        try renderer.renderCopy(textTexture, text_rect);

        renderer.present();
    }
}
