const std = @import("std");
const sdl = @import("sdl/sdl.zig");
const level_11 = @import("level/level_11.zig");

pub fn main() !void {
    sdl.init();
    defer sdl.stop();

    const window = try sdl.Window.init("Zig Game", sdl.WindowCentered, sdl.WindowCentered, 640, 400);
    defer window.cleanup();

    const renderer = try sdl.Renderer.init(&window, 0, sdl.RendererFlag.PresentVSync);
    defer renderer.cleanup();

    //try level_1.movement(renderer);
    //try level_2.collisions(renderer);
    //try level_5.shooting(renderer);
    //try level_6.health(renderer);
    //try level_7.mouse(renderer);
    //try level_8.click_obj(renderer);
    //try level_9.move_obj(renderer);
    //try level_10.drag_obj(renderer);
    try level_11.text(renderer);
}
