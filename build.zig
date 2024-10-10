const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addSharedLibrary(.{
        .name = "haversine",
        .root_source_file = b.path("haversine.zig"),
        .target = target,
        .error_tracing = true,
        .optimize = optimize,
    });
    exe.linkSystemLibrary("sqlite3");
    b.installArtifact(exe);
}
