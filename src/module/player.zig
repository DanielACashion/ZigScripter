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
    intel: ?*lua.Lua = null,
    allocator: std.mem.Allocator,
    pub fn init(allocator: std.mem.Allocator) square_player {
        //
        var self = square_player{ .allocator = allocator };
        self.resetInt();
        return self;
    }
    pub fn deinit(sp: *square_player) void {
        if (sp.intel != null) {
            sp.intel.?.deinit();
        }
    }

    pub fn update(self: *square_player, delta: f32) void {
        if (self.intel == null) {
            return;
        }
        const globalType = self.intel.?.getGlobal("update") catch return;
        if (globalType != lua.LuaType.function) {
            return;
        }
        self.intel.?.pushNumber(delta);
        self.intel.?.pushNumber(self.x);
        self.intel.?.pushNumber(self.y);
        self.intel.?.protectedCall(.{
            .args = 3,
            .results = 2,
            .msg_handler = 0,
        }) catch |err| {
            std.debug.print("err: {any}\n", .{err});
            return;
        };
        self.x = self.intel.?.toNumber(-2) catch self.x;
        self.y = self.intel.?.toNumber(-1) catch self.y;
        self.intel.?.pop(2);
    }

    pub fn resetInt(self: *square_player) void {
        //
        var l = lua.Lua.init(self.allocator) catch return;
        errdefer l.deinit();
        setLuaSideVars(l);
        l.doString(default) catch return;
        if (self.intel != null) {
            self.intel.?.deinit();
        }
        self.intel = l;
    }
    fn setLuaSideVars(l: *lua.Lua) void {
        l.openLibs();
        l.pushNumber(window_width);
        l.setGlobal("WINDOW_WIDTH");
        l.pushNumber(window_height);
        l.setGlobal("WINDOW_HEIGHT");
    }
    pub fn attachCustomInt() void {}

    pub fn attachRunTimeInt(self: *square_player) void {
        var l = lua.Lua.init(self.allocator) catch return;
        errdefer l.deinit();
        setLuaSideVars(l);
        l.doFile("./src/scripts/splayer.lua") catch return;
        if (self.intel != null) {
            self.intel.?.deinit();
        }
        self.intel = l;
    }

    fn set_col() i32 {
        //
        return 0;
    }
};
