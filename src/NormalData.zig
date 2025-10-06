value: f64, // x
deriv: f64, // dx̄/dx
deriv_in: *f64, // dy/dx̄

const Self: type = @This();

pub fn init(allocator: Allocator, tape: []f64) !*Self {
    const self: *Self = try allocator.create(Self);
    self.deriv_in = &tape[1];
    return self;
}

pub fn deinit(self: *Self, allocator: Allocator) void {
    allocator.destroy(self);
}

pub fn forward(self: *Self, data: f64) void {
    self.value = data;
}

pub fn backward(self: *Self, deriv_out: []f64) void {
    deriv_out[0] = self.deriv * self.deriv_in.*;
}

test "Normal Data" {
    const page: Allocator = testing.allocator;
    var tape: [2]f64 = undefined;

    var self: *Self = try Self.init(page, &tape);
    defer self.deinit(page);
}

const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
