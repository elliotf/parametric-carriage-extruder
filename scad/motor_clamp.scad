include <util.scad>
include <config.scad>
include <positions.scad>

clamp_mount_width = 18;
clamp_mount_thickness = 8;
wall_thickness  = extrusion_width*4;

clamp_screw_diam    = m3_diam;
clamp_nut_diam      = m3_nut_diam;
clamp_nut_thickness = m3_nut_thickness;
resolution          = 64;

carriage_hole_pos_y = motor_side/2+1+clamp_mount_thickness/2;
carriage_hole_pos_z = bottom*6;


module motor_clamp() {
  clamp_captive_area_depth = clamp_nut_diam + wall_thickness*2;
  clamp_screw_pos_y        = front*(motor_side/2+wall_thickness+clamp_nut_diam/2+0.5);

  module body() {
    hull() {
      rotate([0,90,0]) {
        rounded_square(motor_side+wall_thickness*2,clamp_mount_width);
      }
      translate([0,carriage_hole_pos_y,0]) {
        cube([clamp_mount_width,clamp_mount_thickness,motor_side*0.65],center=true);
      }
    }
    hull() {
      translate([0,front*(motor_side/2+wall_thickness/2),0]) {
        cube([clamp_mount_width,wall_thickness,motor_side/2],center=true);
      }
      translate([0,clamp_screw_pos_y,0]) {
        for(x=[left,right]) {
          translate([x*(clamp_mount_width/2-clamp_nut_diam/2),0,0]) {
            rotate([0,0,90]) {
              hole(clamp_nut_diam,motor_side/2,6);
            }
          }
        }
        translate([0,front*clamp_nut_diam/2,0]) {
          hole(clamp_nut_diam,motor_side/2,6);
        }
      }
    }

    hull() {
      translate([0,carriage_hole_pos_y,0]) {
        cube([clamp_mount_width,clamp_mount_thickness,motor_side*0.65],center=true);

        translate([carriage_screw_spacing,0,carriage_hole_pos_z]) {
          rotate([90,0,0]) {
            rotate([0,0,90]) {
              hole(clamp_nut_diam+wall_thickness*2,clamp_mount_thickness,6);
            }
          }
        }
      }
    }
  }

  module holes() {
    rotate([0,90,0]) {
      rounded_square(motor_side,clamp_mount_width+1);
    }

    // motor void
    translate([0,-motor_side/2,0]) {
      cube([motor_len,motor_side,2],center=true);
    }

    // clamp screw area
    translate([0,clamp_screw_pos_y,0]) {
      rotate([0,0,22.5]) {
        hole(clamp_screw_diam,motor_len*2,8);
      }

      translate([0,0,-motor_side/2+clamp_nut_thickness]) {
        rotate([0,0,90]) {
          hole(clamp_nut_diam,motor_side/2,6);
        }
      }
    }

    // carriage mount holes
    translate([0,rear*(motor_side/2+clamp_mount_thickness/2),carriage_hole_pos_z]) {
      rotate([90,0,0]) {
        translate([0,0,clamp_mount_thickness/2]) {
          rotate([0,0,90]) {
            hole(clamp_nut_diam,clamp_mount_thickness,6);
          }
          rotate([0,0,22.5]) {
            hole(clamp_screw_diam,clamp_mount_thickness*3,8);
          }

          translate([carriage_screw_spacing,0,0]) {
            rotate([0,0,90]) {
              hole(clamp_nut_diam,clamp_mount_thickness,6);
            }
            rotate([0,0,22.5]) {
              hole(clamp_screw_diam,clamp_mount_thickness*3,8);
            }
          }
        }
      }
    }
  }

  color("Orange") difference() {
    body();
    holes();
  }
}

module clamp_assembly() {
  rotate([0,90,0]) {
    translate([0,0,clamp_mount_width/2+4]) {
      % motor();
    }
  }

  motor_clamp();
}

module clamp_plate() {
  translate([0,0,clamp_mount_width/2+4]) {
    % motor();
  }

  rotate([0,-90,0]) {
    motor_clamp();
  }
}

clamp_plate();
//clamp_assembly();
