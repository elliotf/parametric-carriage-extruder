include <util.scad>
include <config.scad>
include <gears.scad>
include <positions.scad>

module motor() {
  translate([0,0,-motor_len/2]) {
    cube([motor_side,motor_side,motor_len],center=true);

    // shaft
    translate([0,0,motor_len/2+motor_shaft_len/2+motor_shoulder_height])
      cylinder(r=5/2,h=motor_shaft_len,center=true,$fn=16);

    // shoulder
    translate([0,0,motor_len/2+motor_shoulder_height/2])
      cylinder(r=motor_shoulder_diam/2,h=motor_shoulder_height,center=true); // shoulder

    // short shaft
    translate([0,0,-motor_len/2-motor_short_shaft_len/2])
      cylinder(r=5/2,h=motor_short_shaft_len,center=true);
  }

  // mount holes
  for (side=[left,right]) {
    for(end=[top, bottom]) {
      translate([motor_hole_spacing/2*side,motor_hole_spacing/2*end,0]) {
        hole(3,20,12);
      }
    }
  }
}

module hotend() {
  module body() {
    height_groove_and_above = hotend_height_above_groove + hotend_groove_height;
    height_below_groove = hotend_length - height_groove_and_above;

    translate([0,0,-hotend_height_above_groove/2]) {
      hole(hotend_diam,hotend_height_above_groove,90);
    }
    translate([0,0,-hotend_height_above_groove-hotend_groove_height/2]) {
      hole(hotend_groove_diam,hotend_groove_height,90);
    }
    translate([0,0,-height_groove_and_above-height_below_groove/2]) {
      hole(hotend_diam,height_below_groove,90);
    }
  }

  module holes() {
    hole(3,hotend_length*3,36);
  }

  difference() {
    body();
    holes();
  }
}

module hotend_hole() {
  hole(hotend_groove_diam,hotend_clamp_height*4,90);
  hole(hotend_diam,hotend_height_above_groove*2,90);
}

module bearing() {
  difference() {
    cylinder(r=bearing_outer/2,h=bearing_height,center=true);
    cylinder(r=bearing_inner/2,h=bearing_height+0.05,center=true);
  }
}

module idler_bearing() {
  difference() {
    cylinder(r=idler_bearing_outer/2,h=idler_bearing_height,center=true);
    cylinder(r=idler_bearing_inner/2,h=idler_bearing_height*2,center=true);
  }
}

module carriage() {
  module body() {
    // bearing holders
    for(side=[top,bottom]) {
      translate([0,0,x_rod_spacing/2*side]) {
        rotate([0,90,0]) {
          hole(bearing_body_diam,x_carriage_width,90);
        }

        translate([0,-bearing_body_diam/4,-bearing_body_diam/4*side]) {
          cube([x_carriage_width,bearing_body_diam/2,bearing_body_diam/2],center=true);
        }
      }
    }

    // mount plate
    translate([0,(bearing_body_diam/2)*front+carriage_plate_thickness/2,0]) {
      cube([x_carriage_width,carriage_plate_thickness,x_rod_spacing],center=true);
    }

    // hotend mount
    translate([hotend_clamp_x,hotend_clamp_y,hotend_clamp_z]) {
      cube([hotend_clamp_width,motor_side,hotend_clamp_height],center=true);
    }

    translate([hotend_x,hotend_y,hotend_z]) {
      % hotend();
    }

    // motor and mounts
    dist_from_motor_to_carriage_end = x_carriage_width/2-motor_x;
    motor_mount_depth = motor_side-motor_hole_spacing;
    translate([motor_x,motor_y,motor_z]) {
      rotate([0,90,0]) {
        % motor();
      }

      translate([dist_from_motor_to_carriage_end/2,motor_hole_spacing/2,motor_hole_spacing/2]) {
        translate([0,motor_mount_depth/4,0]) {
          cube([dist_from_motor_to_carriage_end,motor_mount_depth/2,motor_mount_depth],center=true);
        }
        rotate([0,90,0]) {
          hole(motor_mount_depth,dist_from_motor_to_carriage_end,90);
        }
      }
    }

    % translate([idler_bearing_x,idler_bearing_y,idler_bearing_z]) {
      rotate([0,90,0]) {
        idler_bearing();
      }
    }
  }

  module holes() {
    for(side=[top,bottom]) {
      translate([0,0,x_rod_spacing/2*side]) {
        // bearing hole
        rotate([0,90,0]) {
          % hole(8,200,36);
          hole(bearing_diam,x_carriage_width+1,90);
        }

        // flanges
        for (end=[left,right]) {
          translate([x_carriage_width/2*end,0,0]) {
            rotate([0,90*end,0]) {
              hull() {
                translate([0,0,1.5]) {
                  hole(bearing_diam+1,3,90);
                }
                hole(bearing_diam,3,90);
              }
            }
          }
        }

        // be able to slip carriage on without removing X rods
        hull() {
          for (side=[top,bottom]) {
            rotate([33*side,0,0])
            translate([-extrusion_height,bearing_diam/2,0]) {
              cube([x_carriage_width,bearing_diam,0.05],center=true);
            }
          }
        }
      }
    }

    // hotend clamp
    translate([hotend_x,hotend_y,hotend_z]) {
      hotend_hole();
    }

    // motor mount holes
    translate([motor_x,motor_y,motor_z]) {
      for (side=[left,right]) {
        for (end=[top,bottom]) {
          translate([0,motor_hole_spacing/2*side,motor_hole_spacing/2*end]) {
            rotate([0,90,0]) {
              hole(motor_screw_diam,x_carriage_width*2,16);
            }
          }
        }
      }
    }

    // belt clamp mount holes
    translate([0,bearing_body_diam/2*front,0]) {
      translate([0,0,belt_clamp_center_screw_offset_z]) {
        rotate([90,0,0]) {
          rotate([0,0,90]) {
            hole(carriage_screw_diam,bearing_body_diam,6);
            hole(carriage_nut_diam,carriage_nut_height*2,6);
          }
        }
      }

      for(side=[left,right]) {
        translate([carriage_screw_spacing/2*side,0,0]) {
          rotate([90,0,0]) {
            rotate([0,0,90]) {
              hole(carriage_screw_diam,bearing_body_diam,6);
              hole(carriage_nut_diam,carriage_nut_height*2,6);
            }
          }
        }
      }
    }
  }

  color("LightBlue") difference() {
    body();
    holes();
  }
}

module hotend_clamp() {
  offset_between_hotend_and_motor_hole_z = -hotend_z-motor_hole_spacing/2;

  module body() {
    translate([hotend_clamp_removable_width/2*left,-hotend_motor_offset_y,hotend_clamp_height/2*bottom]) {
      cube([hotend_clamp_removable_width,motor_side,hotend_clamp_height],center=true);
    }
  }

  module holes() {
    hotend_hole();

    for(side=[left,right]) {
      translate([0,-hotend_motor_offset_y+motor_hole_spacing/2*side,offset_between_hotend_and_motor_hole_z]) {
        rotate([0,90,0]) {
          hole(motor_screw_diam,motor_len*2,16);
        }
      }
    }
  }

  color("Khaki") difference() {
    body();
    holes();
  }
}

module belt_clamp(pulley_diam=motor_pulley_diameter) {
  module body() {
    translate([0,-bearing_body_diam/2+carriage_plate_thickness+belt_clamp_depth/2,belt_clamp_height/2-carriage_nut_diam/2-0.5]) {
      cube([belt_clamp_width,belt_clamp_depth,belt_clamp_height],center=true);
    }
  }

  module holes() {
    translate([0,belt_opening_width/2,0]) {
      // center clamp screw hole
      translate([0,0,belt_clamp_center_screw_offset_z]) {
        rotate([90,0,0]) rotate([0,0,90]) {
            hole(carriage_screw_diam,bearing_body_diam,6);
            hole(carriage_nut_diam,carriage_nut_height*2,6);
        }
      }

      // clamp screw holes
      for(side=[left,right]) {
        translate([carriage_screw_spacing/2*side,0,0]) {
          rotate([90,0,0]) {
              hole(carriage_screw_diam,bearing_body_diam,6);
              hole(carriage_nut_diam,belt_opening_width*2-2,6);
          }
        }
      }
    }

    // MAYBE TODO: support different diameter for motor and idler pulleys
    for (side=[left,right]) {
      // belt path
      translate([carriage_nut_diam*side,0,pulley_diam/2+belt_thickness/2]) {
        translate([x_carriage_width/2*side,0,0]) {
          # cube([x_carriage_width,belt_opening_width+0.05,belt_thickness],center=true);
        }
        // belt teeth
        for (i = [0:15]) {
          translate([(-0.05+i*belt_tooth_distance)*side,0,1.45*side]) {
            cube([belt_tooth_distance*belt_tooth_ratio,belt_opening_width+0.05,belt_thickness/2+belt_tooth_height],center=true);
          }
        }
      }

      // belt slack space
      translate([(carriage_nut_diam+belt_thickness/2)*side,0,pulley_diam/2+carriage_nut_diam/2+belt_thickness]) {
        cube([belt_thickness*4,belt_opening_width+0.05,carriage_nut_diam+belt_thickness*2],center=true);
      }
    }

    // twisted belt clearance
    hull() {
      translate([0,belt_opening_width/2*front,0]) {
        translate([0,0,(carriage_nut_diam/2+1)*bottom]) {
          cube([x_carriage_width+1,1,1],center=true);
        }

        translate([0,belt_opening_width+0.5,-carriage_nut_diam/2]) {
          cube([x_carriage_width+1,1,carriage_nut_diam*2],center=true);
        }
      }
    }
  }

  color("Plum") difference() {
    body();
    holes();

    % translate([0,0,(pulley_diam/2+belt_thickness/2)*bottom]) {
      cube([100,belt_width,belt_thickness],center=true);
    }
    // idler/motor pulleys 
    for (side=[top,bottom]) {
      % translate([100/2*side,0,0]) {
        rotate([90,0,0]) {
          hole(pulley_diam,belt_opening_width+wall_thickness,36);
        }
      }
    }
  }
}

module assembly() {
  carriage();

  translate([hotend_x-0.05,hotend_y,hotend_z]) {
    hotend_clamp();
  }

  translate([0,0.05,0]) {
    belt_clamp();
  }
}

assembly();
