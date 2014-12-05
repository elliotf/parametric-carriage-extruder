include <util.scad>
include <config.scad>

idler_shaft_support   = 4;

filament_opening = filament_diam + 0.5;

plate_thickness = motor_shoulder_height;
plate_thickness = 4;
filament_pos_x  = (hobbed_effective_diam/2+filament_compressed_diam/2)*left;
filament_pos_y  = 0;
idler_nut_pos_z = motor_shoulder_height + extrusion_height + idler_nut_thickness/2;
idler_pos_x     = filament_pos_x - (filament_compressed_diam/2+idler_bearing_outer/2);
idler_pos_z     = idler_nut_pos_z + idler_nut_thickness/2 + idler_shaft_support + idler_bearing_height/2;
filament_pos_z  = idler_pos_z;

hinge_space_width = 2;
hinge_space_pos_x = filament_pos_x - filament_diam/2 - 1 - hinge_space_width/2;
hinge_pos_y       = - motor_hole_spacing/2;

hotend_pos_y      = -motor_hole_spacing/2-motor_screw_head_diam/2;

idler_screw_pos_y = motor_side/2-wall_thickness-m3_nut_diam/2;
idler_screw_pos_z = filament_pos_z - filament_opening/2 - extrusion_height - m3_diam/2;
idler_washer_thickness = 1;

echo("Idler screw length at least ", idler_shaft_support*2 + 1 + idler_bearing_height + 3);

module direct_drive() {
  rounded_radius = motor_side/2 - motor_hole_spacing/2;
  block_height = idler_pos_z + idler_bearing_height/2 + idler_washer_thickness + idler_shaft_support;
  block_height = idler_pos_z + idler_bearing_height/2;

  hotend_rounded_corner_radius = 3;
  module body() {
    hotend_rounded_corner_pos_x  = filament_pos_x+hotend_diam/2;
    hotend_rounded_corner_pos_y  = hotend_pos_y-hotend_clamped_height+hotend_rounded_corner_radius+hotend_clearance;
    hull() {
      for(side=[left,right]) {
        for(end=[front,rear]) {
          translate([motor_hole_spacing/2*side,motor_hole_spacing/2*end,plate_thickness/2]) {
            hole(rounded_radius*2,plate_thickness,resolution);
          }
        }
      }
      translate([hotend_rounded_corner_pos_x,hotend_rounded_corner_pos_y,plate_thickness/2]) {
        hole(hotend_rounded_corner_radius*2,plate_thickness,resolution);
      }
    }

    // main block
    hull() {
      for(y=[rear*motor_hole_spacing/2,hotend_pos_y-hotend_clamped_height+rounded_radius+hotend_clearance]) {
        translate([motor_hole_spacing/2*left,y,block_height/2]) {
          hole(rounded_radius*2,block_height,resolution);
        }
      }
      for(y=[motor_side/2-hotend_rounded_corner_radius,hotend_rounded_corner_pos_y]) {
        translate([hotend_rounded_corner_pos_x,y,block_height/2]) {
          hole(hotend_rounded_corner_radius*2,block_height,resolution);
        }
      }
    }
  }

  module holes() {
    tensioner_wiggle = .4;
    translate([0,idler_screw_pos_y,idler_screw_pos_z]) {
      for(side=[front,rear]) {
        // tensioner screw
        translate([0,tensioner_wiggle/2*side,0]) {
          rotate([0,90,0]) {
            rotate([0,0,22.5]) {
              hole(m3_diam,motor_side*2,8);
            }
          }
        }
        // tensioner captive nut
        translate([hobbed_pulley_diam*.6,tensioner_wiggle/2*side,0]) {
          rotate([0,90,0]) {
            rotate([0,0,90]) {
              hole(m3_nut_diam,6,6);
            }
          }
        }
      }
    }

    // motor mount holes
    for(side=[top,bottom]) {
      translate([motor_hole_spacing/2,motor_hole_spacing/2*side,0]) {
        hole(motor_screw_diam,motor_len,resolution);

        translate([0,0,plate_thickness+motor_len/2]) {
          hole(motor_screw_head_diam,motor_len,resolution);
        }
      }
    }
    translate([-motor_hole_spacing/2,-motor_hole_spacing/2,0]) {
      hole(motor_screw_diam,motor_len,resolution);

      translate([0,0,plate_thickness+motor_len/2]) {
        //hole(motor_screw_head_diam,motor_len,resolution);
      }
    }

    // motor shoulder + slack
    mount_shoulder_width = motor_shoulder_diam/2+abs(hinge_space_pos_x)+1;
    intersection() {
      hull() {
        rotate([0,0,22.5]) {
          hole(motor_shoulder_diam+0.5,plate_thickness*2+0.05,resolution);
        }
        hole(2,(plate_thickness+motor_shoulder_diam/2+2)*2,resolution);
      }
      translate([motor_shoulder_diam/2-mount_shoulder_width/2+1,0,0]) {
        cube([mount_shoulder_width,motor_shoulder_diam+1,motor_len],center=true);
      }
    }

    // idler arm motor shoulder clearance
    intersection() {
      translate([-0.5,0,0]) {
        hull() {
          hole(motor_shoulder_diam+0.5,motor_shoulder_height*2,resolution);
          hole(2,(motor_shoulder_height+motor_shoulder_diam/2)*2,resolution);
        }
      }
      translate([hinge_space_pos_x-motor_side/2,0,0]) {
        cube([motor_side+0.05,motor_side+0.05,motor_len],center=true);
      }
    }

    // pulley clearance
    hole(hobbed_pulley_diam+2,motor_len,resolution);
    pulley_clearance = hobbed_pulley_diam+3;
    hull() {
      translate([hinge_space_pos_x,0,0]) {
        cube([1,pulley_clearance,motor_len],center=true);
      }

      translate([rounded_radius,0,0]) {
        cube([1,pulley_clearance,motor_len],center=true);
      }
    }
    // hobbed pulley access
    translate([motor_side*.6,0,plate_thickness+motor_len/2]) {
      rotate([0,0,0]) {
        hole(motor_side,motor_len,4);
      }
    }

    // hinge space between idler and hobbed pulley
    hull() {
      translate([hinge_space_pos_x,hinge_pos_y+hinge_space_width/2,0]) {
        hole(hinge_space_width,motor_len,resolution);

        translate([0,motor_side,0]) {
          cube([hinge_space_width,1,motor_len],center=true);
        }
      }
    }

    // hinge space between idler and motor mount screw
    translate([hinge_space_pos_x-hinge_space_width/2-3,hinge_pos_y+0.5,0]) {
      hull() {
        hole(1,motor_len,resolution);

        translate([-(motor_screw_head_diam/2-motor_screw_diam/2),motor_screw_head_diam/2,0]) {
          hole(1,motor_len,resolution);
        }
      }

      hull() {
        translate([-(motor_screw_head_diam/2-motor_screw_diam/2),motor_screw_head_diam/2,0]) {
          hole(1,motor_len,resolution);
          translate([-motor_side,0,0]) {
            cube([hinge_space_width,1,motor_len],center=true);
          }
        }
      }
    }

    translate([idler_pos_x,0,0]) {
      // idler shaft
      hole(idler_bearing_inner,motor_len,resolution);

      // idler bearing
      translate([0,0,idler_pos_z]) {
        hole(idler_bearing_outer+1.5,idler_bearing_height+idler_washer_thickness*2,resolution);
      }

      // captive idler nut/bolt
      hull() {
        rotate([0,0,90]) {
          translate([0,0,idler_nut_pos_z]) {
            hole(idler_nut_diam,idler_nut_thickness,6);

            translate([0,0,-motor_len/2]) {
              hole(idler_nut_diam,idler_nut_thickness,6);
            }
          }
        }
      }
    }

    bevel_dist = extrusion_height*3;
    translate([idler_pos_x,0,0]) {
      // created a bevel in case the first few layers are melted into a flange
      hull() {
        rotate([0,0,90]) {
          hole(idler_nut_diam,motor_shoulder_height,6);
        }
        rotate([0,0,90]) {
          hole(idler_nut_diam+bevel_dist*2,0.05,36);
        }
      }
    }

    // filament path
    translate([filament_pos_x,0,filament_pos_z]) {
      rotate([90,0,0]) {
        rotate([0,0,22.5]) {
          hole(filament_opening,50,8);
        }
      }
    }

    // hotend void
    hotend_res = resolution*2;
    above_height = hotend_height_above_groove+hotend_clearance*2;
    translate([filament_pos_x,hotend_pos_y,filament_pos_z]) {
      rotate([-90,0,0]) {
        translate([0,0,-hotend_clamped_height]) {
          rotate([0,0,180/hotend_res])
            hole(hotend_groove_diam+hotend_clearance,hotend_clamped_height*2,hotend_res);
          translate([0,-hotend_diam/2,0]) {
            cube([hotend_groove_diam,hotend_diam,hotend_clamped_height*2],center=true);
          }
        }

        translate([0,0,-above_height/2+hotend_clearance]) {
          rotate([0,0,180/hotend_res])
            hole(hotend_diam+hotend_clearance,above_height,hotend_res);
          translate([0,-hotend_diam/2,0]) {
            cube([hotend_diam,hotend_diam,above_height],center=true);
          }

          // zip tie restraint
          zip_tie_hole(hotend_diam + hotend_rounded_corner_radius*2);
        }

        translate([0,0,-hotend_clamped_height-10+hotend_clearance]) {
          rotate([0,0,180/hotend_res])
            hole(hotend_diam+hotend_clearance,20,hotend_res);
          translate([0,-hotend_diam/2,0]) {
            cube([hotend_diam,hotend_diam,20],center=true);
          }
        }
      }
    }
  }

  module bridges() {
    translate([hinge_space_pos_x-hinge_space_width/2-idler_nut_diam/2-1,0,idler_nut_pos_z+idler_nut_thickness/2+extrusion_height]) {
      cube([idler_nut_diam+2,idler_nut_diam+3,extrusion_height*2],center=true);
    }
  }

  % motor();
  % translate([0,0,filament_pos_z]) {
    rotate([0,180,0]) {
      hobbed_pulley();
    }
  }
  % translate([filament_pos_x,0,filament_pos_z]) {
    rotate([90,0,0]) {
      hole(filament_diam,50,16);
    }
  }
  % translate([idler_pos_x,0,idler_pos_z]) {
    hole(idler_bearing_outer,idler_bearing_height,32);
  }

  difference() {
    body();
    holes();
  }
  bridges();
}

direct_drive();
//assembly();