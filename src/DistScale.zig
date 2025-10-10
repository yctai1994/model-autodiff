value: f64, // σ or γ
deriv: f64, // dp/dσ or dp/dγ
deriv_in: *f64, // dy/dp

const Self: type = @This();

pub fn init(allocator: Allocator, tape: []f64) !*Self {
    const self: *Self = try allocator.create(Self);
    self.deriv_in = &tape[0];
    return self;
}

pub fn deinit(self: *Self, allocator: Allocator) void {
    allocator.destroy(self);
}

pub fn forward(self: *Self, scale: f64) void {
    self.value = scale;
}

pub fn backward(self: *Self, deriv_out: []f64) void {
    deriv_out[2] = self.deriv * self.deriv_in.*;
}

test "Normal Scale" {
    const page: Allocator = testing.allocator;
    var tape: [2]f64 = undefined;

    var self: *Self = try Self.init(page, &tape);
    defer self.deinit(page);
}

const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
