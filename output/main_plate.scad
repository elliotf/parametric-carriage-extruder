include <../scad/positions.scad>
use <../scad/main.scad>

translate([0,0,x_carriage_width/2]) {
  rotate([0,90,0]) {
    carriage();
  }
}

translate([-hotend_clamp_height*2.5,motor_y-5,0]) {
  rotate([0,-90,0]) {
    hotend_clamp();
  }
}

translate([hotend_clamp_height+10,hotend_y-5,hotend_clamp_removable_width]) {
  rotate([0,0,180]) {
    mirror([0,1,0]) {
      rotate([0,-90,0]) {
        //hotend_clamp();
      }
    }
  }
}

translate([-x_rod_spacing/2-hotend_clamp_height,-motor_side,-belt_opening_width/2+belt_clamp_depth]) {
  rotate([0,0,90]) {
    rotate([90,0,0]) {
      belt_clamp();
    }
  }
}

translate([motor_side/2,motor_y-motor_side*.25,motor_side/2]) {
  rotate([90,0,0]) {
    idler_arm();
  }
}

translate([hotend_clamp_height,-motor_side-bearing_body_diam-5,idler_shaft_diam/2]) {
  idler_shaft();
}
