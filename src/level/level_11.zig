const std = @import("std");
const sdl = @import("../sdl/sdl.zig");

pub fn text(renderer: sdl.Renderer) !void {
    sdl.init_ttf();
    defer sdl.stop_ttf();

    const font = try sdl.Font.init("/Users/randell/Library/Fonts/MesloLGSNerdFont-Regular.ttf", 24);
    const text_texture = try sdl.Texture.init(renderer, font, sdl.Rect.init(100, 100, 200, 200, sdl.Color.green()), "Hey there!");

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

        try renderer.render_texture(text_texture);

        renderer.present();
    }
}
