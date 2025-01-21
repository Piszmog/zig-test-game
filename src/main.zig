const std = @import("std");
const sdl = @import("sdl/sdl.zig");
const level_1 = @import("level/level_1.zig");
const level_2 = @import("level/level_2.zig");
const level_5 = @import("level/level_5.zig");

pub fn main() !void {
    sdl.init();
    defer sdl.stop();

    const window = try sdl.Window.init("Zig Game", sdl.WindowCentered, sdl.WindowCentered, 640, 400);
    defer window.cleanup();

    const renderer = try sdl.Renderer.init(&window, 0, sdl.RendererFlag.PresentVSync);
    defer renderer.cleanup();

    //try level_1.movement(renderer);
    //try level_2.collisions(renderer);
    try level_5.shooting(renderer);
}
