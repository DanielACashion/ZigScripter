const std = @import("std");
const lua = @import("zlua");
const splayer = @import("splayer");

const sdl = @cImport({
    @cInclude("SDL.h");
});

const INIT_ERROR = error{
    WINDOW,
    SET_WINDOW,
    CREATE_RENDERER,
};

fn init_window() INIT_ERROR!void {
    if (sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) != 0) {
        return INIT_ERROR.WINDOW;
    }
    window = sdl.SDL_CreateWindow("ZLS", sdl.SDL_WINDOWPOS_CENTERED, sdl.SDL_WINDOWPOS_CENTERED, window_width, window_height, sdl.SDL_WINDOW_BORDERLESS);
    if (window == null) {
        return INIT_ERROR.SET_WINDOW;
    }
    renderer = sdl.SDL_CreateRenderer(window, -1, 0);
    if (renderer == null) {
        return INIT_ERROR.CREATE_RENDERER;
    }
}

fn process_input() void {
    //
    var event: sdl.SDL_Event = undefined;
    _ = sdl.SDL_PollEvent(&event);
    switch (event.type) {
        sdl.SDL_QUIT => is_running = false,
        sdl.SDL_KEYDOWN => {
            //
            switch (event.key.keysym.sym) {
                sdl.SDLK_ESCAPE => is_running = false,
                sdl.SDLK_r => for (players, 0..) |_, i| {
                    players[i].attachRunTimeInt();
                },
                else => return,
            }
        },
        else => return,
    }
}

fn update() void { //fix this to be timestamp checking for all but escape
    //
    const target = last_frame_time +% FRAME_TIME;
    var ticks = sdl.SDL_GetTicks();
    std.debug.print("target: {d}, current: {d}\n", .{ target, ticks });
    while (ticks < target) {
        ticks = sdl.SDL_GetTicks();
    }
    const tick_float: f32 = @floatFromInt(ticks);
    const lft_float: f32 = @floatFromInt(last_frame_time);
    const delta_time: f32 = (tick_float - lft_float) / 1000.0;
    player.x += 100 * delta_time;
    //std.debug.print("{d} = tick: {d}, lft:{d}\n", .{ delta_time, tick_float, lft_float });

    last_frame_time = ticks;
}

fn luaupdate() void {
    const target = last_frame_time +% FRAME_TIME;
    var ticks = sdl.SDL_GetTicks();
    while (ticks < target) {
        ticks = sdl.SDL_GetTicks();
    }
    const tick_float: f32 = @floatFromInt(ticks);
    const lft_float: f32 = @floatFromInt(last_frame_time);
    const delta_time: f32 = (tick_float - lft_float) / 1000.0;
    last_frame_time = ticks;

    const globalType = L.getGlobal("update") catch return;
    if (globalType != lua.LuaType.function) {
        return;
    }
    L.pushNumber(delta_time);
    L.pushNumber(player.x);
    L.pushNumber(player.y);
    L.protectedCall(.{
        .args = 3,
        .results = 0,
        .msg_handler = 0,
    }) catch return;
}

fn render() void {
    //
    defer _ = sdl.SDL_RenderPresent(renderer);
    _ = sdl.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    _ = sdl.SDL_RenderClear(renderer);
    _ = sdl.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    const player_rect = sdl.SDL_Rect{
        .x = @intFromFloat(player.x),
        .y = @intFromFloat(player.y),
        .w = @intFromFloat(player.width),
        .h = @intFromFloat(player.height),
    };
    _ = sdl.SDL_RenderFillRect(renderer, &player_rect);
}

fn set_player_pos(iL: *lua.Lua) i32 {
    const y = iL.toAny(f32, -1) catch return 0;
    const x = iL.toAny(f32, -2) catch return 0;
    player.x = x;
    player.y = y;
    return 0;
}

const Player = struct {
    x: f64 = 0,
    y: f64 = 0,
    width: f64 = 10,
    height: f64 = 10,
};
var last_frame_time: u32 = 0;
const TARGET_FPS = 30;
const FRAME_TIME = 1000 / TARGET_FPS;
var player = Player{ .x = 20, .y = 20 };
const window_width = 1200;
const window_height = 800;
var window: ?*sdl.SDL_Window = undefined;
var renderer: ?*sdl.SDL_Renderer = undefined;
var is_running: bool = true;
var L: *lua.Lua = undefined;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc_handle = gpa.allocator();
var players: [1]*splayer.square_player = undefined;
pub fn main() void {
    defer _ = gpa.deinit();
    var sq_player = splayer.square_player.init(alloc_handle);
    defer sq_player.deinit();
    players[0] = &sq_player;

    std.debug.print("Starting Main..\n", .{});
    L = lua.Lua.init(alloc_handle) catch return;
    defer L.deinit();
    L.openLibs();
    L.doFile("./src/scripts/playermovement.lua") catch return;
    L.pushFunction(lua.wrap(set_player_pos));
    L.setGlobal("set_player_pos");
    L.pushNumber(window_width);
    L.setGlobal("WINDOW_WIDTH");
    L.pushNumber(window_height);
    L.setGlobal("WINDOW_HEIGHT");

    init_window() catch return;
    defer sdl.SDL_Quit();
    defer sdl.SDL_DestroyWindow(window);
    defer sdl.SDL_DestroyRenderer(renderer);
    while (is_running) {
        process_input();
        luaupdate();
        render();
    }
}
