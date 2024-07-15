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

    /// Draw a point on the current rendering target.
    pub fn drawPoint(self: *const Renderer, x: i32, y: i32) !void {
        if (c.SDL_RenderDrawPoint(self.sdl_renderer, x, y) != 0) {
            std.debug.print("failed to draw point: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Draw multiple points on the current rendering target.
    pub fn drawPoints(self: *const Renderer, points: []const Point) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        defer {
            _ = gpa.deinit();
        }

        var sdl_points: []c.SDL_Point = try allocator.alloc(c.SDL_Point, points.len);
        defer allocator.free(sdl_points);

        for (points, 0..) |p, i| {
            sdl_points[i] = c.SDL_Point{ .x = p.x, .y = p.y };
        }

        if (c.SDL_RenderDrawPoints(self.sdl_renderer, sdl_points.ptr, @intCast(points.len)) != 0) {
            std.debug.print("failed to draw points: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Draw a line on the current rendering target.
    pub fn drawLine(self: *const Renderer, x1: i32, y1: i32, x2: i32, y2: i32) !void {
        if (c.SDL_RenderDrawLine(self.sdl_renderer, x1, y1, x2, y2) != 0) {
            std.debug.print("failed to draw line: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Draw a series of connected lines on the current rendering target.
    pub fn drawLines(self: *const Renderer, points: []const Point) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        defer {
            _ = gpa.deinit();
        }

        var sdl_points: []c.SDL_Point = try allocator.alloc(c.SDL_Point, points.len);
        defer allocator.free(sdl_points);

        for (points, 0..) |p, i| {
            sdl_points[i] = c.SDL_Point{ .x = p.x, .y = p.y };
        }

        if (c.SDL_RenderDrawLines(self.sdl_renderer, sdl_points.ptr, @intCast(points.len)) != 0) {
            std.debug.print("failed to draw lines: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Draw a line on the current rendering target.
    pub fn drawRect(self: *const Renderer, x: i32, y: i32, width: i32, height: i32) !void {
        const rect = c.SDL_Rect{ .x = x, .y = y, .w = width, .h = height };
        if (c.SDL_RenderDrawRect(self.sdl_renderer, &rect) != 0) {
            std.debug.print("failed to draw rect: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Draw a series of connected lines on the current rendering target.
    pub fn drawRects(self: *const Renderer, rects: []const Rect) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        defer {
            _ = gpa.deinit();
        }

        var sdl_rects: []c.SDL_Rect = try allocator.alloc(c.SDL_Rect, rects.len);
        defer allocator.free(sdl_rects);

        for (rects, 0..) |r, i| {
            sdl_rects[i] = c.SDL_Rect{ .x = r.x, .y = r.y, .w = r.width, .h = r.height };
        }

        if (c.SDL_RenderDrawRects(self.sdl_renderer, sdl_rects.ptr, @intCast(rects.len)) != 0) {
            std.debug.print("failed to draw rects: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Fill a rectangle on the current rendering target with the drawing color.
    pub fn fillRect(self: *const Renderer, x: i32, y: i32, width: i32, height: i32) !void {
        const rect = c.SDL_Rect{ .x = x, .y = y, .w = width, .h = height };
        if (c.SDL_RenderFillRect(self.sdl_renderer, &rect) != 0) {
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

pub const Point = struct {
    x: i32,
    y: i32,
};

/// A rectangle, with the origin at the upper left (integer).
pub const Rect = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
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
