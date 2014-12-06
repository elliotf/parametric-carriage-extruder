include <util.scad>
include <config.scad>
include <positions.scad>

bearing_body_diam = bearing_diam+wall_thickness*2;
space_between_bearing_bodies = x_rod_spacing - bearing_body_diam;
space_between_bearings = 1;
x_carriage_width = bearing_len*2 + space_between_bearings;
carriage_plate_thickness = 5;
carriage_plate_pos_y     = bearing_body_diam/2*front;
carriage_screw_diam = m3_diam;
carriage_nut_diam = m3_nut_diam;
carriage_nut_height = 2;

belt_clamp_width  = x_carriage_width;
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

module carriage() {
  module body() {
    // bearing holders
    for(side=[top,bottom]) {
      translate([0,0,x_rod_spacing/2*side]) {
        hull() {
          //for(z=[0,carriage_plate_thickness/2*side]) {
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

        translate([0,-bearing_body_diam/4,-bearing_body_diam/4*side]) {
          cube([x_carriage_width,bearing_body_diam/2,bearing_body_diam/2],center=true);
        }
      }
    }

    // mount plate
    translate([0,carriage_plate_pos_y,0]) {
      cube([x_carriage_width,carriage_plate_thickness,x_rod_spacing],center=true);
    }
  }

  module holes() {
    for(side=[top,bottom]) {
      translate([0,0,x_rod_spacing/2*side]) {
        // bearing hole
        rotate([0,90,0]) {
          hole(bearing_diam,x_carriage_width+1,90);
        }

        // zip tie holes
        for(x=[left,0,right]) {
          translate([x*(x_carriage_width/2-bearing_len/2),0,0]) {
            rotate([0,90,0]) {
              //zip_tie_hole(bearing_body_diam);
            }
          }
        }

        // bevels
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
          for (end=[top,bottom]) {
            rotate([33*end,0,0])
            translate([extrusion_height,bearing_diam/2,0]) {
              cube([x_carriage_width,bearing_diam,0.05],center=true);
            }
          }
        }
      }
    }

    nut_hole_depth = carriage_plate_thickness-3;
    translate([0,(bearing_body_diam/2+carriage_plate_thickness/2)*front,0]) {
      // mounting holes
      for(z=[0,belt_clamp_center_screw_offset_z]) {
        for(side=[left,center,right]) {
          translate([carriage_screw_spacing/2*side,0,z]) {
            rotate([90,0,0]) {
              rotate([0,0,22.5]) {
                hole(carriage_screw_diam,bearing_body_diam,8);
              }
              rotate([0,0,90]) {
                //hole(carriage_nut_diam,carriage_nut_height*2,6);
              }
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

module belt_clamp() {
  module body() {
    //translate([0,-bearing_body_diam/2+carriage_plate_thickness+belt_clamp_depth/2,belt_clamp_height/2-carriage_nut_diam/2-0.5]) {
    translate([0,0,belt_clamp_height/2-carriage_nut_diam/2-0.5]) {
      cube([belt_clamp_width,belt_clamp_depth,belt_clamp_height],center=true);
    }
  }

  module bridges() {
    /*
    for(side=[left,center,right]) {
      translate([carriage_screw_spacing/2*side,0,1]) {
        rotate([90,0,0]) {
          difference() {
            hole(carriage_nut_diam,belt_clamp_depth,6);
            hole(carriage_screw_diam,bearing_body_diam,resolution);
          }
        }
      }
    }
    */
  }

  module holes() {
    translate([0,belt_opening_width/2,0]) {
      /*
      // center clamp screw hole
      translate([0,0,belt_clamp_center_screw_offset_z + 1]) {
        rotate([90,0,0]) rotate([0,0,90]) {
          hole(carriage_screw_diam,bearing_body_diam*2,resolution);
        }
      }

      // clamp screw holes
      for(side=[left,right]) {
        translate([carriage_screw_spacing/2*side,0,1]) {
          rotate([90,0,0]) {
            hole(carriage_screw_diam,bearing_body_diam*2,6);
          }
        }
      }
      */

      for(z=[0,belt_clamp_center_screw_offset_z]) {
        for(side=[left,center,right]) {
          translate([carriage_screw_spacing/2*side,0,z]) {
            rotate([90,0,0]) {
              hole(carriage_screw_diam,bearing_body_diam*2,resolution);
            }
          }
        }
      }
    }

    for (side=[left,right]) {
      // belt path
      translate([carriage_nut_diam*side,0,motor_pulley_diameter/2+belt_thickness/2]) {
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
      translate([(carriage_nut_diam+belt_thickness/2)*side,0,motor_pulley_diameter/2+carriage_nut_diam/2+belt_thickness]) {
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
          cube([x_carriage_width+1,1,carriage_nut_diam],center=true);
        }
      }
    }
  }

  color("Plum") {
    difference() {
      translate([0,belt_clamp_pos_y,0]) {
        body();
      }
      holes();
    }
    translate([0,belt_clamp_pos_y,0]) {
      bridges();
    }
  }
}

module motor_clamp() {
  module body() {
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}

module assembly() {
  translate([motor_x,motor_y,motor_z]) {
    rotate([0,90,0]) {
      % motor();
    }
  }

  carriage();

  translate([0,0.1,0]) {
    belt_clamp();
  }

  // x rods
  for(side=[top,bottom]) {
    translate([0,0,x_rod_spacing/2*side]) {
      rotate([0,90,0]) {
        % hole(8,200,36);
      }
    }
  }

  % translate([0,0,(motor_pulley_diameter/2+belt_thickness/2)*bottom]) {
    cube([100,belt_width,belt_thickness],center=true);
  }

  // idler/motor pulleys
  for (side=[top,bottom]) {
    % translate([100/2*side,0,0]) {
      rotate([90,0,0]) {
        hole(motor_pulley_diameter,belt_opening_width+wall_thickness,36);
      }
    }
  }
}

module plate() {
  rotate([0,-90,0]) {
    carriage();
  }
}

plate();
//assembly();
