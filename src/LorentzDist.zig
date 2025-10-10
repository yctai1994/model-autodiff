value: f64, // p
deriv_out: *f64, // dy/dp

cdata: *CenteredData,
scale: *DistScale,

const Self: type = @This();

pub fn init(allocator: Allocator, tape: []f64) !*Self {
    const self: *Self = try allocator.create(Self);
    errdefer allocator.destroy(self);

    self.cdata = try CenteredData.init(allocator, tape);
    errdefer self.cdata.deinit(allocator);

    self.scale = try DistScale.init(allocator, tape);

    self.deriv_out = &tape[0];
    return self;
}

pub fn deinit(self: *Self, allocator: Allocator) void {
    self.cdata.deinit(allocator);
    self.scale.deinit(allocator);
    allocator.destroy(self);
}

pub fn forward(self: *Self, data: f64, mode: f64, scale: f64) void {
    self.cdata.forward(data, mode);
    self.scale.forward(scale);

    const temp: f64 = sqr(self.cdata.value) + sqr(scale);

    self.value = scale / (PI * temp);

    self.cdata.deriv = -self.value * (2.0 * self.cdata.value) / temp; // dp/dx̄
    self.scale.deriv = self.value * (1.0 / scale - 2.0 * scale / temp); // dp/dσ
}

pub fn backward(self: *Self, final_deriv_out: []f64) void {
    self.deriv_out.* = 1.0;

    self.cdata.backward(final_deriv_out);
    self.scale.backward(final_deriv_out);
}

test "Lorentz Distribution" {
    const page: Allocator = testing.allocator;
    var tape: [2]f64 = undefined;

    var self: *Self = try Self.init(page, &tape);
    defer self.deinit(page);

    self.forward(3.3, 4.9, 1.1);

    var deriv: [3]f64 = undefined;
    self.backward(&deriv);

    debug.print("value = {d}\n", .{self.value});
    debug.print("deriv = {any}\n", .{deriv});
}

fn sqr(x: f64) f64 {
    return x * x;
}

const PI: comptime_float = 3.141592653589793238462643383279502884197; // in f128

const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const Allocator = std.mem.Allocator;

const CenteredData = @import("./CenteredData.zig");
const DistScale = @import("./DistScale.zig");
