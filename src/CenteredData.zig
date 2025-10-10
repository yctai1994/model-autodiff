value: f64, // x̄ ≡ x - μ
deriv: f64, // dp/dx̄
deriv_in: *f64, // dy/dp
deriv_out: *f64, // dy/dx̄

data: *DistData,
mode: *DistMode,

const Self: type = @This();

pub fn init(allocator: Allocator, tape: []f64) !*Self {
    const self: *Self = try allocator.create(Self);
    errdefer allocator.destroy(self);

    self.data = try DistData.init(allocator, tape);
    errdefer self.data.deinit(allocator);

    self.mode = try DistMode.init(allocator, tape);

    self.deriv_in = &tape[0];
    self.deriv_out = &tape[1];
    return self;
}

pub fn deinit(self: *Self, allocator: Allocator) void {
    self.data.deinit(allocator);
    self.mode.deinit(allocator);
    allocator.destroy(self);
}

pub fn forward(self: *Self, data: f64, mode: f64) void {
    self.data.forward(data);
    self.mode.forward(mode);
    self.value = data - mode;

    self.data.deriv = 1.0; // dx̄/dx
    self.mode.deriv = -1.0; // dx̄/dμ
}

pub fn backward(self: *Self, final_deriv_out: []f64) void {
    self.deriv_out.* = self.deriv * self.deriv_in.*; // dy/dx̄ = dp/dx̄ × dy/dp

    self.data.backward(final_deriv_out);
    self.mode.backward(final_deriv_out);
}

test "Centered Data" {
    const page: Allocator = testing.allocator;
    var tape: [2]f64 = undefined;

    var self: *Self = try Self.init(page, &tape);
    defer self.deinit(page);
}

const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

const DistData = @import("./DistData.zig");
const DistMode = @import("./DistMode.zig");
