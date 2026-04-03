const lua = @import("lua");
const std = @import("std");
const default = @embedFile("scripts/splayer.lua");

const window_width = 1200;
const window_height = 800;
pub const square_player = struct {
    x: f64 = 0,
    y: f64 = 0,
    w: i16 = 10,
    h: i16 = 10,
    int: ?*lua.Lua = null,
    allocator: std.mem.Allocator,
    pub fn init(allocator: std.mem.Allocator) square_player {
        //
        var self = square_player{ .allocator = allocator };
        self.resetInt();
        return self;
    }
    pub fn deinit(sp: *square_player) void {
        if (sp.int != null) {
            sp.int.?.deinit();
        }
    }

    pub fn resetInt(sp: *square_player) void {
        //
        var l = lua.Lua.init(sp.allocator) catch return;
        errdefer l.deinit();
        l.openLibs();
        l.doString(default) catch return;
        l.pushFunction(lua.wrap(set_pos));
        l.setGlobal("set_player_pos");
        l.pushNumber(window_width);
        l.setGlobal("WINDOW_WIDTH");
        l.pushNumber(window_height);
        l.setGlobal("WINDOW_HEIGHT");
        if (sp.int != null) {
            sp.int.?.deinit();
        }
        sp.int = l;
    }

    pub fn attachCustomInt() void {}

    pub fn attachRunTimeInt(self: *square_player) void {
        var l = lua.Lua.init(self.allocator) catch return;
        errdefer l.deinit();
        l.openLibs();
        l.doFile("./src/scripts/splayer.lua") catch return;
        l.pushFunction(lua.wrap(set_pos));
        l.setGlobal("set_player_pos");
        l.pushNumber(window_width);
        l.setGlobal("WINDOW_WIDTH");
        l.pushNumber(window_height);
        l.setGlobal("WINDOW_HEIGHT");
        if (self.int != null) {
            self.int.?.deinit();
        }
        self.int = l;
    }

    fn set_pos(L: *lua.Lua) i32 {
        //
        _ = L;
        return 0;
    }
    fn set_col() i32 {
        //
        return 0;
    }
};
