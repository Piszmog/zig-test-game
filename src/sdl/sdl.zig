const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});

/// Initialize the SDL library.
pub fn init() void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        @panic(getError());
    }
}

/// Clean up all initialized subsystems.
pub fn stop() void {
    c.SDL_Quit();
}

/// The struct used as an opaque handle to a window.
pub const Window = struct {
    sdl_window: *c.SDL_Window,

    /// Create a window with the specified position, dimensions, and flags.
    pub fn init(
        title: [*c]const u8,
        x: i32,
        y: i32,
        width: i32,
        height: i32,
    ) !Window {
        const maybe_window = c.SDL_CreateWindow(title, x, y, width, height, 0);
        const window = maybe_window orelse return error.NullValue;
        return Window{
            .sdl_window = window,
        };
    }

    /// Destroy the window.
    pub fn cleanup(self: *const Window) void {
        c.SDL_DestroyWindow(self.sdl_window);
    }
};

/// Centered position of the window.
pub const WindowCentered = c.SDL_WINDOWPOS_CENTERED;

/// A structure representing rendering state.
pub const Renderer = struct {
    sdl_renderer: *c.SDL_Renderer,

    /// Create a 2D rendering context for a window.
    pub fn init(window: *const Window, index: i32, flags: RendererFlag) !Renderer {
        const maybe_renderer = c.SDL_CreateRenderer(window.sdl_window, index, @intFromEnum(flags));
        const render = maybe_renderer orelse return error.NullValue;
        return Renderer{
            .sdl_renderer = render,
        };
    }

    /// Destroy the rendering context for a window and free associated textures.
    pub fn cleanup(self: *const Renderer) void {
        c.SDL_DestroyRenderer(self.sdl_renderer);
    }

    /// Set the color used for drawing operations (Rect, Line and Clear).
    pub fn setDrawColor(self: *const Renderer, red: u8, green: u8, blue: u8, alpha: u8) !void {
        if (c.SDL_SetRenderDrawColor(self.sdl_renderer, red, green, blue, alpha) != 0) {
            std.debug.print("failed to draw color: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Clear the current rendering target with the drawing color.
    pub fn clear(self: *const Renderer) !void {
        if (c.SDL_RenderClear(self.sdl_renderer) != 0) {
            std.debug.print("failed to clear renderer: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Update the screen with any rendering performed since the previous call.
    pub fn present(self: *const Renderer) void {
        c.SDL_RenderPresent(self.sdl_renderer);
    }

    /// Fill a rectangle on the current rendering target with the drawing color.
    pub fn fillRect(self: *const Renderer, rect: *Rect) !void {
        if (c.SDL_RenderFillRect(self.sdl_renderer, &rect.sdl_rect) != 0) {
            std.debug.print("failed to fill rect: {s}\n", .{getError()});
            return error.RendererError;
        }
    }
};

/// Flags used when creating a rendering context.
pub const RendererFlag = enum(u32) {
    /// The renderer is a software fallback.
    Software = c.SDL_RENDERER_SOFTWARE,
    /// The renderer uses hardware acceleration.
    Accelerated = c.SDL_RENDERER_ACCELERATED,
    /// Present is synchronized with the refresh rate.
    PresentVSync = c.SDL_RENDERER_PRESENTVSYNC,
    /// The renderer supports rendering to texture.
    TargetedTexture = c.SDL_RENDERER_TARGETTEXTURE,
};

/// Get the number of milliseconds since SDL library initialization.
pub fn getTicks() u32 {
    return c.SDL_GetTicks();
}

/// Retrieve a message about the last error that occurred on the current thread.
pub fn getError() []const u8 {
    return cStringToSlice(c.SDL_GetError());
}

/// A rectangle, with the origin at the upper left (integer).
pub const Rect = struct {
    sdl_rect: c.SDL_Rect,

    /// Creates a new rectangle.
    pub fn init(x: i32, y: i32, width: i32, height: i32) Rect {
        return Rect{ .sdl_rect = c.SDL_Rect{
            .x = x,
            .y = y,
            .w = width,
            .h = height,
        } };
    }

    /// Sets the x position.
    pub fn setX(self: *Rect, x: i32) void {
        self.sdl_rect.x = x;
    }

    /// Sets the y position.
    pub fn setY(self: *Rect, y: i32) void {
        self.sdl_rect.y = y;
    }
};

/// General event structure.
pub const Event = struct {
    sdl_event: c.SDL_Event,

    /// Poll for currently pending events.
    /// Returns true if there is a pending event or false if there are none available.
    pub fn poll(self: *Event) bool {
        return c.SDL_PollEvent(&self.sdl_event) != 0;
    }

    /// Returns the type of the event.
    pub fn getType(self: Event) EventType {
        return switch (self.sdl_event.type) {
            c.SDL_QUIT => EventType.Quit,
            else => EventType.Unknown,
        };
    }
};

/// The different type of events that can occur.
pub const EventType = enum {
    /// USer requested quit.
    Quit,
    /// Event not yet covered by the enum.
    Unknown,
};

/// Converts a c-string to a zig string.
fn cStringToSlice(c_str: [*c]const u8) []const u8 {
    // Find the length of the C string
    var length: usize = 0;
    while (c_str[length] != 0) {
        length += 1;
    }

    // Create a Zig slice
    return c_str[0..length];
}
