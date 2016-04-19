include <util.scad>
include <config.scad>
include <positions.scad>
include <hotends.scad>
use <motor_clamp.scad>

rounded_diam = 4;

bearing_body_diam = bearing_diam+wall_thickness*3;
bearing_body_wall = wall_thickness*3;
space_between_bearing_bodies = x_rod_spacing - bearing_body_diam;
space_between_bearings = 1;
x_carriage_width = bearing_len*2 + space_between_bearings;
carriage_plate_thickness = 5;
carriage_plate_pos_y     = (lower_bearing_diam/2+bearing_body_wall/2)*front;
carriage_screw_diam = m3_diam;
carriage_nut_diam = m3_nut_diam;
carriage_nut_thickness = 2;

belt_clamp_width  = x_carriage_width*.4;
belt_clamp_height = space_between_bearing_bodies/2+carriage_nut_diam/2;
belt_clamp_depth  = bearing_body_diam/2-carriage_plate_thickness/2 + belt_opening_width/2;

motor_clamp_mount_thickness = 5;
motor_clamp_wall_thickness  = 3;

// motor position
motor_y = (bearing_body_diam/2+carriage_plate_thickness/2+motor_side/2)*front;
motor_z = motor_side/2+m3_nut_diam/2+.5;

belt_clamp_pos_x = 0;
belt_clamp_pos_y = carriage_plate_pos_y + carriage_plate_thickness/2 + belt_clamp_depth/2;
belt_clamp_pos_z = 0;
belt_clamp_center_screw_offset_z = space_between_bearing_bodies/2-carriage_nut_diam/2-1;

echo("belt_clamp_center_screw_offset_z: ", belt_clamp_center_screw_offset_z);

motor_x = motor_len/2 - hotend_diam;

echo("MOTOR PULLEY DIAMETER: ", motor_pulley_diameter);

motor_pos_z = pulley_offset_z;
idler_pos_z = pulley_offset_z;

anchor_side = top;
anchor_side = bottom;

idler_diam  = 10;
idler_belt_pos_z  = idler_pos_z + idler_diam/2;
motor_belt_pos_z  = motor_pos_z + anchor_side*motor_pulley_diameter/2;

tensioner_screw_hole_diam    = 3.25;
tensioner_nut_hole_diam      = m3_nut_diam+0.2;
tensioner_hole_depth         = x_carriage_width/2-2;
tensioner_clamp_gap          = 0.25;
tensioner_screw_belt_spacing = belt_thickness + extrusion_width*2 + tensioner_nut_hole_diam/2;
tensioner_clamp_height       = wall_thickness + belt_thickness/2 + tensioner_screw_belt_spacing + tensioner_screw_hole_diam/2 + wall_thickness;
tensioner_clamp_width        = belt_width + wall_thickness*2;
tensioner_clamp_length       = tensioner_hole_depth - 5;
tensioner_screw_pos_z        = motor_belt_pos_z + (anchor_side * tensioner_screw_belt_spacing);
tensioner_clamp_offset       = anchor_side*tensioner_screw_hole_diam/2 + anchor_side*wall_thickness - anchor_side*tensioner_clamp_height/2;
// pos Z is relative to tensioner screw position
tensioner_clamp_pos_z        = tensioner_screw_pos_z + tensioner_clamp_offset;

module bearing_hole(bearing_diam) {
  bearing_resolution = 12;

  // bearing hole
  rotate([0,90,0]) {
    hole(bearing_diam,x_carriage_width*2,bearing_resolution);
  }

  // bevels
  for (end=[left,right]) {
    translate([x_carriage_width/2*end,0,0]) {
      rotate([0,90*end,0]) {
        hull() {
          translate([0,0,1.5+0.05]) {
            hole(bearing_diam+1,3,bearing_resolution);
          }
          hole(bearing_diam-0.05,3,bearing_resolution);
        }
      }
    }
  }

  // be able to slip carriage on without removing X rods
  hull() {
    for (end=[top,bottom]) {
      rotate([33*end,0,0])
      translate([-extrusion_height,bearing_diam/2,0]) {
        cube([x_carriage_width,bearing_diam,0.05],center=true);
      }
    }
  }
}

module plain_carriage_holes() {
  translate([0,0,x_rod_spacing/2*anchor_side]) {
    bearing_hole(bearing_diam);
  }
  translate([0,0,x_rod_spacing/2*-anchor_side]) {
    bearing_hole(lower_bearing_diam);
  }
}

module bearing_body(bearing_diam,side) {
  bearing_body_diam = bearing_diam+bearing_body_wall;

  hull() {
    rotate([0,90,0]) {
      hole(bearing_body_diam,x_carriage_width,resolution);
    }
    translate([0,(carriage_plate_pos_y-carriage_plate_thickness/2+bearing_body_diam/2),0]) {
      rotate([0,90,0]) {
        hole(bearing_body_diam,x_carriage_width,resolution);
      }
    }
  }
}

module motor_clamp_carriage() {
  clamp_pos_x = x_carriage_width/2-motor_clamp_mount_width/2;
  clamp_pos_y = carriage_plate_pos_y-carriage_plate_thickness/2-motor_side/2-3;
  clamp_pos_z = x_rod_spacing/2+bearing_body_diam/2-motor_side/2-wall_thickness;

  module body() {
    // bearing holders
    translate([0,0,x_rod_spacing/2*anchor_side]) {
      bearing_body(bearing_diam,top);
    }
    translate([0,0,x_rod_spacing/2*-anchor_side]) {
      bearing_body(lower_bearing_diam,bottom);

      translate([0,-lower_bearing_diam/4,lower_bearing_diam/4*anchor_side]) {
        cube([x_carriage_width,lower_bearing_diam/2,lower_bearing_diam/2+bearing_body_wall],center=true);
      }
    }

    hull() {
      translate([0,0,anchor_side*x_rod_spacing/2]) {
        translate([0,-carriage_plate_thickness/2,0]) {
          rotate([0,90,0]) {
            hole(bearing_body_diam,x_carriage_width,resolution);
          }
        }
        translate([0,0,0]) {
          rotate([0,90,0]) {
            hole(bearing_body_diam,x_carriage_width,resolution);
          }
        }

      }
      translate([0,0,tensioner_clamp_pos_z-anchor_side*tensioner_clamp_height/2+anchor_side*rounded_diam/2]) {
        translate([0,tensioner_clamp_width/2-rounded_diam/2,0]) {
          rotate([0,90,0]) {
            hole(rounded_diam+tensioner_clamp_gap*2+wall_thickness*2,x_carriage_width,resolution);
          }
        }
        translate([0,-bearing_body_diam/2,0]) {
          cube([x_carriage_width,1,rounded_diam+tensioner_clamp_gap*2+wall_thickness*2],center=true);
        }
      }
    }

    // mount plate
    translate([0,carriage_plate_pos_y,0]) {
      translate([0,rounded_diam/4,0]) {
        cube([x_carriage_width,carriage_plate_thickness+rounded_diam/2,x_rod_spacing],center=true);
      }
    }

    // clamp
      /*
    translate([clamp_pos_x,0,0]) {
      translate([0,clamp_pos_y,clamp_pos_z]) {
        rotate([-90,0,0]) {
          motor_clamp_body();
        }

        translate([0,motor_side/4+wall_thickness,0]) {
          cube([motor_clamp_mount_width,motor_side/2,motor_side],center=true);
        }
      }

      // bearing body brace
      for(side=[top,bottom]) {
        hull() {
          translate([0,clamp_pos_y+motor_side*.25,clamp_pos_z+(motor_side/2+wall_thickness/2)*side]) {
            cube([motor_clamp_mount_width,1,wall_thickness],center=true);
          }

          translate([0,-carriage_plate_thickness/2,x_rod_spacing/2*side]) {
            intersection() {
              translate([0,0,0]) {
                rotate([0,90,0]) {
                  hole(bearing_body_diam,motor_clamp_mount_width,resolution);
                }
              }

              translate([0,-bearing_body_diam/2,bearing_body_diam/2*side]) {
                cube([motor_clamp_mount_width,motor_clamp_mount_width,bearing_body_diam],center=true);
              }
            }
          }
        }
      }

      // mount plate brace
      hull() {
        translate([0,clamp_pos_y+motor_side/2+wall_thickness/2,clamp_pos_z]) {
          cube([motor_clamp_mount_width,wall_thickness,motor_side],center=true);
        }
        translate([0,carriage_plate_pos_y,0]) {
          cube([motor_clamp_mount_width,carriage_plate_thickness,x_rod_spacing],center=true);
        }
        translate([0,clamp_pos_y+motor_side*.25,clamp_pos_z-motor_side/2-wall_thickness/2]) {
          cube([motor_clamp_mount_width,1,wall_thickness],center=true);
        }
        translate([0,clamp_pos_y+motor_side*.25,clamp_pos_z+motor_side/2+wall_thickness/2]) {
          cube([motor_clamp_mount_width,1,wall_thickness],center=true);
        }
      }
    }
      */
  }

  module holes() {
    plain_carriage_holes();

    // motor clamp
    translate([clamp_pos_x,clamp_pos_y,clamp_pos_z]) {
      rotate([0,0,180]) {
        rotate([-90,0,0]) {
          motor_clamp_holes();
        }
      }
    }

    // tensioner cavity
    translate([x_carriage_width/2,0,tensioner_clamp_pos_z]) {
      hull() {
        for(y=[front,rear]) {
          for(z=[top,bottom]) {
            translate([0,(tensioner_clamp_width/2-rounded_diam/2)*y,(tensioner_clamp_height/2-rounded_diam/2)*z]) {
              rotate([0,90,0]) {
                hole(rounded_diam+tensioner_clamp_gap*2,tensioner_hole_depth*2,resolution);
              }
            }
          }
        }
      }
      hull() {
        for(y=[front,rear]) {
          for(z=[top,bottom]) {
            translate([1,(tensioner_clamp_width/2-rounded_diam/2)*y,(tensioner_clamp_height/2-rounded_diam/2)*z]) {
              rotate([0,90,0]) {
                hole(rounded_diam+tensioner_clamp_gap*2+extrusion_width*2,2,resolution);
                hole(1,4+extrusion_width*8,resolution);
              }
            }
          }
        }
      }
    }

    // tensioner screw
    tensioner_screw_length = (x_carriage_width - tensioner_hole_depth - extrusion_height) * 2;
    translate([-x_carriage_width/2,0,tensioner_screw_pos_z]) {
      rotate([0,90,0]) {
        hole(tensioner_screw_hole_diam,tensioner_screw_length,resolution);
        hole(tensioner_nut_hole_diam,x_carriage_width-2,6);
      }
    }

    translate([0,0,motor_belt_pos_z]) {
      // belt teeth
      translate([-x_carriage_width/2,-2,0]) {
        belt_teeth(x_carriage_width/2,anchor_side);
      }

      // belt access
      translate([-x_carriage_width/4-0.05,0,0]) {
        hull() {
          translate([0,belt_width*.6,0]) {
            cube([x_carriage_width/2,1,1],center=true);
          }
          translate([0,bearing_body_diam/2,0]) {
            cube([x_carriage_width/2,1,10],center=true);
          }
        }
      }
    }

    translate([0,carriage_plate_pos_y+carriage_plate_thickness/2,0]) {
      hull() {
        translate([0,rounded_diam/2,0]) {
          translate([0,0,tensioner_clamp_pos_z+-anchor_side*(tensioner_clamp_height/2+tensioner_clamp_gap+wall_thickness+rounded_diam/2)]) {
            rotate([0,90,0]) {
              hole(rounded_diam,x_carriage_width+1,resolution);
            }
          }
          translate([0,0,-anchor_side*(x_rod_spacing/2-lower_bearing_diam/2-bearing_body_wall/2-rounded_diam/2)]) {
            rotate([0,90,0]) {
              hole(rounded_diam,x_carriage_width+1,resolution);
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

  translate([0,0,motor_belt_pos_z+belt_thickness/2]) {
    //cube([1000,6,belt_thickness],center=true);
  }

  translate([x_carriage_width/2+tensioner_clamp_length*2,0,tensioner_clamp_pos_z]) {
    vertical_belt_clamp();
  }

  translate([clamp_pos_x-motor_clamp_mount_width/2-10,clamp_pos_y,clamp_pos_z]) {
    rotate([0,-90,0]) {
      //% motor();
    }
  }

  for(side=[top,bottom]) {
    translate([-25,0,side*(motor_belt_pos_z+anchor_side*belt_thickness/2)]) {
      % cube([50,belt_width,belt_thickness],center=true);
    }
    translate([25,0,side*(idler_belt_pos_z+belt_thickness/2)]) {
      % cube([50,belt_width,belt_thickness],center=true);
    }
  }

  // motor pulleys
  % translate([50*left,0,motor_pos_z]) {
    rotate([90,0,0]) {
      hole(motor_pulley_diameter,belt_opening_width+wall_thickness,36);
    }
  }
  // idler pulleys
  % translate([50*right,0,idler_pos_z]) {
    rotate([90,0,0]) {
      hole(idler_diam,belt_opening_width+wall_thickness,36);
    }
  }
}

module belt_teeth(leng,side=bottom) {
  tooth_diam  = 1.4;
  tooth_pitch = 2;
  num_teeth = floor(leng / tooth_pitch);
  // belt teeth
  translate([0,belt_width/2,0]) {
    translate([0,0,side*.5]) {
      cube([tooth_pitch*(2*num_teeth+1),belt_width*2,1],center=true);
    }
    for(side=[left,right]) {
      for(i=[0:num_teeth]) {
        translate([2*i*side,0,0]) {
          rotate([90,0,0]) {
            rotate([0,0,90]) {
              hole(tooth_diam,belt_width*2,6);
            }
          }
        }
      }
    }
  }
}

module vertical_belt_clamp() {
  module body() {
    hull() {
      for(z=[top,bottom]) {
        for(y=[front,rear]) {
          translate([0,(tensioner_clamp_width/2-rounded_diam/2)*y,(tensioner_clamp_height/2-rounded_diam/2)*z]) {
            rotate([0,90,0]) {
              hole(rounded_diam,tensioner_clamp_length,resolution);
            }
          }
        }
      }
    }
  }

  module holes() {
    translate([0,0,-tensioner_clamp_offset]) {
      rotate([0,90,0]) {
        hole(tensioner_screw_hole_diam,tensioner_clamp_length+1,16);
      }

      for(side=[left,right]) {
        translate([side*(tensioner_clamp_length/2+0.5),0,0]) {
          rotate([0,90,0]) {
            hull() {
              hole(tensioner_screw_hole_diam+1,1,16);
              hole(tensioner_screw_hole_diam,2,16);
            }
          }
        }
      }

      translate([tensioner_clamp_length/2+1,0,-anchor_side*(tensioner_screw_belt_spacing-belt_thickness)]) {
        mirror([0,0,0]) {
          belt_teeth(tensioner_clamp_length*2,-anchor_side);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

motor_clamp_carriage();
