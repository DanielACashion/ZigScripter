const std = @import("std");
const zlua = @import("zlua");

// current working directory

const Lua = zlua.Lua;
const dofile = @embedFile("scripts/factorial.lua");
pub fn main() !void {
    std.debug.print("hello from zig\n", .{});
    std.debug.print("{s}\n", .{dofile});
    try zlua_example();
    _ = try write_dofile_to_file();
}
pub fn write_dofile_to_file() ![]const u8 {
    const fs = std.fs.cwd();
    const file_name = "factorial_tmp.lua"; // file you want to create
    var file = try fs.createFile(file_name, .{ .truncate = true });
    defer file.close();

    // Write the embedded bytes
    try file.writeAll(dofile);

    std.debug.print("Wrote dofile to {s}\n", .{file_name});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var L = try Lua.init(allocator);
    defer L.deinit();
    L.openLibs();

    try L.doFile("factorial_tmp.lua");
    try L.doString(dofile);

    std.debug.print("completedFile\n", .{});
    return file_name;
}
fn lua_example_dofile() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var L = try Lua.init(allocator);
    L.openLibs();

    try L.doFile("factorial.lua");

    std.debug.print("completedFile\n", .{});
}

fn zlua_example() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Initialize the Lua vm
    var lua = Lua.init(allocator) catch {
        std.debug.print("hello from zig\n", .{});
        return;
    };
    defer lua.deinit();

    // Add an integer to the Lua stack and retrieve it
    lua.pushInteger(42);
    const someluaint = lua.toInteger(-1) catch |err| {
        std.debug.print("Error on To Int: {any}\n", .{err});
        return;
    };
    std.debug.print("{any}\n", .{someluaint});
}
