// You can get this file from http://www.thingiverse.com/thing:3575
include <../scad/positions.scad>
use <../scad/main.scad>

translate([0,0,x_carriage_width/2]) {
  rotate([0,90,0]) {
    carriage();
  }
}

translate([-hotend_clamp_height/2,hotend_y-5,hotend_clamp_removable_width]) {
  rotate([0,-90,0]) {
    hotend_clamp();
  }
}

translate([x_carriage_width*.75*left,-motor_side,-belt_opening_width/2+belt_clamp_depth]) {
  rotate([0,0,90]) {
    rotate([90,0,0]) {
      belt_clamp();
    }
  }
}

translate([x_carriage_width*.6*right,-motor_side*1.2,-hobbed_effective_diam]) {
    rotate([-45,0,0]) {
      idler_arm();
    }
}
