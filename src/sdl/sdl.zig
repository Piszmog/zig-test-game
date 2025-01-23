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
    pub fn setDrawColor(self: *const Renderer, color: Color) !void {
        if (c.SDL_SetRenderDrawColor(self.sdl_renderer, color.red, color.green, color.blue, color.alpha) != 0) {
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
    pub fn drawPoint(self: *const Renderer, point: Point) !void {
        if (c.SDL_RenderDrawPoint(self.sdl_renderer, point.x, point.y) != 0) {
            std.debug.print("failed to draw point: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Draw multiple points on the current rendering target.
    pub fn drawPoints(self: *const Renderer, allocator: std.mem.Allocator, points: []const Point) !void {
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
    pub fn drawLine(self: *const Renderer, point1: Point, point2: Point) !void {
        if (c.SDL_RenderDrawLine(self.sdl_renderer, point1.x, point1.y, point2.x, point2.y) != 0) {
            std.debug.print("failed to draw line: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Draw a series of connected lines on the current rendering target.
    pub fn drawLines(self: *const Renderer, allocator: std.mem.Allocator, points: []const Point) !void {
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
    pub fn drawRect(self: *const Renderer, rect: Rect) !void {
        if (c.SDL_RenderDrawRect(self.sdl_renderer, &rect.sdl_rect) != 0) {
            std.debug.print("failed to draw rect: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Draw a series of connected lines on the current rendering target.
    pub fn drawRects(self: *const Renderer, allocator: std.mem.Allocator, rects: []const Rect) !void {
        var sdl_rects: []c.SDL_Rect = try allocator.alloc(c.SDL_Rect, rects.len);
        defer allocator.free(sdl_rects);

        for (rects, 0..) |r, i| {
            sdl_rects[i] = r.sdl_rect;
        }

        if (c.SDL_RenderDrawRects(self.sdl_renderer, sdl_rects.ptr, @intCast(rects.len)) != 0) {
            std.debug.print("failed to draw rects: {s}\n", .{getError()});
            return error.RendererError;
        }
    }

    /// Fill a rectangle on the current rendering target with the drawing color.
    pub fn fillRect(self: *const Renderer, rect: Rect) !void {
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

pub const Point = struct {
    x: i32,
    y: i32,
};

pub const Color = struct {
    red: u8,
    green: u8,
    blue: u8,
    alpha: u8,

    pub fn red() Color {
        return Color{ .red = 0xff, .green = 0, .blue = 0, .alpha = 0xff };
    }

    pub fn green() Color {
        return Color{ .red = 0, .green = 0xff, .blue = 0, .alpha = 0xff };
    }

    pub fn blue() Color {
        return Color{ .red = 0, .green = 0, .blue = 0xff, .alpha = 0xff };
    }
};

/// A rectangle, with the origin at the upper left (integer).
pub const Rect = struct {
    sdl_rect: c.SDL_Rect,
    color: Color,

    /// Creates a new instance of the rect.
    pub fn init(x: i32, y: i32, width: i32, height: i32, color: Color) Rect {
        return Rect{ .sdl_rect = c.SDL_Rect{ .x = x, .y = y, .w = width, .h = height }, .color = color };
    }
};

/// Contains information about velocity.
pub const Velocity = struct {
    x: i32,
    y: i32,
};

/// A rigid body contains information about the rectangle and it's velocity.
pub const RigidBody = struct {
    rect: Rect,
    velocity: Velocity,

    /// Creates a new rigid body based on the provided rect.
    pub fn init(rect: Rect) RigidBody {
        return RigidBody{
            .rect = rect,
            .velocity = Velocity{
                .x = 0,
                .y = 0,
            },
        };
    }

    /// Moves the position of the rigid body based on velocity.
    pub fn move(self: *RigidBody) void {
        self.rect.sdl_rect.x += self.velocity.x;
        self.rect.sdl_rect.y += self.velocity.y;
    }
};

/// Determines if two rigid bodies will collide into one another.
pub fn has_collision(body_1: RigidBody, body_2: RigidBody) bool {
    return body_1.rect.sdl_rect.x + body_1.velocity.x < body_2.rect.sdl_rect.x + body_2.velocity.x + body_2.rect.sdl_rect.w and
        body_1.rect.sdl_rect.x + body_1.velocity.x + body_1.rect.sdl_rect.w > body_2.rect.sdl_rect.x + body_2.velocity.x and
        body_1.rect.sdl_rect.y + body_1.velocity.y < body_2.rect.sdl_rect.y + body_2.velocity.y + body_2.rect.sdl_rect.h and
        body_1.rect.sdl_rect.y + body_1.velocity.y + body_1.rect.sdl_rect.h > body_2.rect.sdl_rect.y + body_2.velocity.y;
}

pub fn check_collision(body_1: RigidBody, body_2: RigidBody) CollisionDirection {
    const future_1_x = body_1.rect.sdl_rect.x + body_1.velocity.x;
    const future_1_y = body_1.rect.sdl_rect.y + body_1.velocity.y;
    const future_2_x = body_2.rect.sdl_rect.x + body_2.velocity.x;
    const future_2_y = body_2.rect.sdl_rect.y + body_2.velocity.y;

    if (!(future_1_x < future_2_x + body_2.rect.sdl_rect.w and
        future_1_x + body_1.rect.sdl_rect.w > future_2_x and
        future_1_y < future_2_y + body_2.rect.sdl_rect.h and
        future_1_y + body_1.rect.sdl_rect.h > future_2_y))
    {
        return CollisionDirection.None;
    }

    const overlap_x_1 = future_2_x + body_2.rect.sdl_rect.w - future_1_x;
    const overlap_y_1 = future_2_y + body_2.rect.sdl_rect.h - future_1_y;
    const overlap_x_2 = future_1_x + body_1.rect.sdl_rect.w - future_2_x;
    const overlap_y_2 = future_1_y + body_1.rect.sdl_rect.h - future_2_y;

    const min_overlap_x = if (overlap_x_1 < overlap_x_2) overlap_x_1 else overlap_x_2;
    const min_overlap_y = if (overlap_y_1 < overlap_y_2) overlap_y_1 else overlap_y_2;

    if (min_overlap_x < min_overlap_y) {
        if (overlap_x_1 < overlap_x_2) {
            return CollisionDirection.Left;
        } else {
            return CollisionDirection.Right;
        }
    } else {
        if (overlap_y_1 < overlap_y_2) {
            return CollisionDirection.Top;
        } else {
            return CollisionDirection.Bottom;
        }
    }
}

pub const CollisionDirection = enum { None, Top, Bottom, Left, Right };

pub const Character = struct {
    body: RigidBody,
    health: i8,

    pub fn init(body: RigidBody) Character {
        return Character{ .body = body, .health = 100 };
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
            c.SDL_KEYDOWN => EventType.Keydown,
            else => EventType.Unknown,
        };
    }

    pub fn getKeyCode(self: Event) KeyEvent {
        return switch (self.sdl_event.key.keysym.sym) {
            c.SDLK_UP => KeyEvent.Up,
            c.SDLK_DOWN => KeyEvent.Down,
            c.SDLK_LEFT => KeyEvent.Left,
            c.SDLK_RIGHT => KeyEvent.Right,
            c.SDLK_SPACE => KeyEvent.Space,
            else => KeyEvent.Unknown,
        };
    }
};

pub fn get_keyboard_state(allocator: std.mem.Allocator) ![]Scancode {
    const key_state = c.SDL_GetKeyboardState(null);

    var scancodes = std.ArrayList(Scancode).init(allocator);
    defer scancodes.deinit();

    if (key_state[c.SDL_SCANCODE_UP] == 1) {
        try scancodes.append(Scancode.Up);
    }
    if (key_state[c.SDL_SCANCODE_DOWN] == 1) {
        try scancodes.append(Scancode.Down);
    }
    if (key_state[c.SDL_SCANCODE_LEFT] == 1) {
        try scancodes.append(Scancode.Left);
    }
    if (key_state[c.SDL_SCANCODE_RIGHT] == 1) {
        try scancodes.append(Scancode.Right);
    }

    return scancodes.toOwnedSlice();
}

/// The different type of events that can occur.
pub const EventType = enum {
    /// Key pressed.
    Keydown,
    /// User requested quit.
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

/// The SDL virtual key representation.
pub const KeyEvent = enum {
    Up,
    Down,
    Left,
    Right,
    Space,
    Unknown,
};

pub const Scancode = enum(c_int) {
    Up,
    Down,
    Left,
    Right,
};
