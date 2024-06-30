const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "shorthand",
        .root_source_file = b.path("app/main.zig"),
        .target = b.host,
    });

    const raylib_dependency = b.dependency("raylib-zig", .{
        .target = b.host,
    });

    const raylib = raylib_dependency.module("raylib");
    const raygui = raylib_dependency.module("raygui");
    const raylib_artifact = raylib_dependency.artifact("raylib");

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("app", "Run the application");
    run_step.dependOn(&run_exe.step);
}
