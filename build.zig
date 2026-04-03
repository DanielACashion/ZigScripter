const std = @import("std");

pub fn build(b: *std.Build) void {
    const zopts = b.standardOptimizeOption(.{});
    const ztarget = b.standardTargetOptions(.{});

    const zlua = b.dependency("zlua", .{
        .target = ztarget,
        .optimize = zopts,
        .lang = .lua53,
        .shared = false,
    });

    const square_player = b.createModule(.{
        .root_source_file = b.path("src/module/player.zig"),
        .optimize = zopts,
        .target = ztarget,
        .imports = &.{
            .{ .name = "lua", .module = zlua.module("zlua") },
        },
    });

    const zmain = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .optimize = zopts,
        .target = ztarget,
        .imports = &.{
            .{ .name = "splayer", .module = square_player },
        },
    });

    const exe = b.addExecutable(.{
        .name = "main",
        .root_module = zmain,
    });

    exe.root_module.addImport("zlua", zlua.module("zlua"));
    exe.addIncludePath(b.path("lib/SDL2/include/"));
    exe.addLibraryPath(b.path("lib/SDL2/lib/x64/"));
    exe.linkSystemLibrary("SDL2");
    b.installArtifact(exe);
}
