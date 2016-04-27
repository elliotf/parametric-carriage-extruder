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
x_carriage_width = 40;
x_carriage_width = 30;
carriage_plate_thickness = 6;
carriage_plate_pos_y     = (lower_bearing_diam/2+bearing_body_wall/2)*front;
carriage_plate_pos_y     = (belt_width/2+carriage_plate_thickness/2+2)*front;
carriage_plate_pos_y     = (idler_bearing_height+carriage_plate_thickness/2)*front;
carriage_plate_pos_y     = (belt_opening_width/2+carriage_plate_thickness/2)*front;
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

anchor_side = bottom;
anchor_side = top;

idler_diam  = 10;
idler_belt_pos_z  = idler_pos_z + idler_diam/2;
motor_belt_pos_z  = motor_pos_z + anchor_side*motor_pulley_diameter/2;

tensioner_screw_hole_diam    = 3.5;
tensioner_nut_hole_diam      = m3_nut_diam+0.3;
tensioner_hole_depth         = x_carriage_width/2-4;
tensioner_clamp_gap          = 0.4;
tensioner_screw_belt_spacing = belt_thickness + extrusion_width*2 + tensioner_nut_hole_diam/2;
tensioner_clamp_height       = wall_thickness + belt_thickness/2 + tensioner_screw_belt_spacing + tensioner_screw_hole_diam/2 + wall_thickness;
tensioner_clamp_width        = belt_width + wall_thickness*2;
tensioner_clamp_length       = tensioner_hole_depth - 5;
tensioner_screw_pos_z        = motor_belt_pos_z + (anchor_side * tensioner_screw_belt_spacing);
tensioner_clamp_offset       = anchor_side*tensioner_screw_hole_diam/2 + anchor_side*wall_thickness - anchor_side*tensioner_clamp_height/2;
// pos Z is relative to tensioner screw position
tensioner_clamp_pos_z        = tensioner_screw_pos_z + tensioner_clamp_offset;
tensioner_hole_width         = tensioner_clamp_width + tensioner_clamp_gap*2;
tensioner_hole_height        = tensioner_clamp_height + tensioner_clamp_gap*2;
tensioner_body_width         = tensioner_hole_width+wall_thickness*2;
tensioner_body_height        = tensioner_hole_height+wall_thickness*2;

motor_clamp_pos_x = -x_carriage_width/2+motor_clamp_mount_width/2;
motor_clamp_pos_y = carriage_plate_pos_y-carriage_plate_thickness/2-motor_side/2-5;
motor_clamp_pos_z = x_rod_spacing/2+bearing_body_diam/2-motor_side/2-wall_thickness;
motor_clamp_pos_z = x_rod_spacing/2+lower_bearing_diam/2+bearing_body_wall/2-motor_side/2-wall_thickness;
motor_clamp_pos_z = x_rod_spacing/2-lower_bearing_diam/2;
motor_clamp_pos_z = motor_side*0.35; // probably ought to be based on the length of the hotend below the motor

bearing_resolution = 12;

module bearing_hole(bearing_diam,len) {

  // bearing hole
  rotate([0,90,0]) {
    hole(bearing_diam,len*2,bearing_resolution);
  }

  // bevels
  for (end=[left,right]) {
    translate([len/2*end,0,0]) {
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
      translate([extrusion_height,bearing_diam/2,0]) {
        cube([len,bearing_diam,0.05],center=true);
      }
    }
  }
}

module plain_carriage_holes() {
  translate([0,0,x_rod_spacing/2*anchor_side]) {
    bearing_hole(bearing_diam,x_carriage_width);
  }
  translate([motor_clamp_pos_x,0,x_rod_spacing/2*-anchor_side]) {
    bearing_hole(lower_bearing_diam,motor_clamp_mount_width);
  }
}

module body2d() {
  module bearing_body_2d(scoped_bearing_diam,side) {
    bearing_body_diam = scoped_bearing_diam+bearing_body_wall;

    hull() {
      accurate_circle(bearing_body_diam,bearing_resolution);

      translate([(carriage_plate_pos_y-carriage_plate_thickness/2+bearing_diam/2+bearing_body_wall/2),0]) {
        accurate_circle(bearing_body_diam,bearing_resolution);
      }
    }
  }

  module body() {
    // bearing holders
    translate([0,x_rod_spacing/2*anchor_side]) {
      bearing_body_2d(bearing_diam,top);
    }
    translate([0,x_rod_spacing/2*-anchor_side]) {
      bearing_body_2d(lower_bearing_diam,top);

      translate([-lower_bearing_diam/4,lower_bearing_diam/4*anchor_side]) {
        square([lower_bearing_diam/2,lower_bearing_diam/2+bearing_body_wall],center=true);
      }
    }

    hull() {
      translate([0,anchor_side*x_rod_spacing/2]) {
        accurate_circle(bearing_body_diam,bearing_resolution);

        translate([carriage_plate_pos_y,0]) {
          square([carriage_plate_thickness,1],center=true);
        }
      }

      // tensioner body
      if (screw_tensioner) {
        translate([0,tensioner_clamp_pos_z-anchor_side*(tensioner_body_height/2-rounded_diam/2)]) {
          translate([tensioner_body_width/2-rounded_diam/2,0]) {
            accurate_circle(rounded_diam,resolution);
          }
        }
      } else {
        translate([0,tensioner_clamp_pos_z-anchor_side*(tensioner_body_height/2-rounded_diam/2)]) {
          translate([belt_width/2-rounded_diam/2,0]) {
            accurate_circle(rounded_diam,resolution);
          }
        }
      }
      translate([carriage_plate_pos_y,tensioner_clamp_pos_z]) {
        square([carriage_plate_thickness,tensioner_body_height],center=true);
      }
    }
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}

module motor_clamp_carriage() {
  module body() {
    //body3d();

    translate([-x_carriage_width/2,0,0]) {
      rotate([0,0,90]) {
        rotate([90,0,0]) {
          linear_extrude(height=x_carriage_width, convexity=10) {
            body2d();
          }
        }
      }
    }

    hull() {
      // mount plate
      for (side=[front,rear]) {
        translate([x_carriage_width/4-0.5,carriage_plate_pos_y+side*(carriage_plate_thickness/2-rounded_diam/2),tensioner_clamp_pos_z-anchor_side*(tensioner_body_height/2+rounded_diam/2)]) {
          rotate([0,90,0]) {
            hole(rounded_diam,x_carriage_width/2+1,resolution);
          }
        }

        translate([motor_clamp_pos_x+motor_clamp_mount_width/2-0.5,carriage_plate_pos_y+side*(carriage_plate_thickness/2-rounded_diam/2),(x_rod_spacing/2-lower_bearing_diam/2-bearing_body_wall/2-rounded_diam/2)*-anchor_side]) {
          rotate([0,90,0]) {
            hole(rounded_diam,1,resolution);
          }
        }
      }
    }
    translate([motor_clamp_pos_x,carriage_plate_pos_y,0]) {
      cube([motor_clamp_mount_width,carriage_plate_thickness,x_rod_spacing],center=true);
    }
    // go easier on a printer by rounding hard 90 degree corners
    translate([0,carriage_plate_pos_y+rounded_diam/4,tensioner_clamp_pos_z-anchor_side*tensioner_body_height/2]) {
      cube([x_carriage_width,carriage_plate_thickness+rounded_diam/2,rounded_diam],center=true);
    }
    translate([motor_clamp_pos_x,carriage_plate_pos_y+carriage_plate_thickness/2,-anchor_side*(x_rod_spacing/2-lower_bearing_diam/2-bearing_body_wall/2)]) {
      cube([motor_clamp_mount_width,rounded_diam,rounded_diam],center=true);
    }

    // clamp
    //translate([(carriage_plate_pos_y-carriage_plate_thickness/2+bearing_body_diam/2),0]) {
    translate([motor_clamp_pos_x,0,0]) {
      translate([0,motor_clamp_pos_y,motor_clamp_pos_z]) {
        rotate([-90,0,0]) {
          motor_clamp_body();
        }
      }

      // anchor motor clamp to carriage
      hull() {
        translate([0,carriage_plate_pos_y-carriage_plate_thickness,motor_clamp_pos_z-motor_side/2]) {
          cube([motor_clamp_mount_width,carriage_plate_thickness*3,wall_thickness*2],center=true);
        }
        translate([0,carriage_plate_pos_y-carriage_plate_thickness,x_rod_spacing/2+bearing_diam/2]) {
          cube([motor_clamp_mount_width,carriage_plate_thickness*3,bearing_body_wall],center=true);
        }
      }
      hull() {
        translate([0,motor_clamp_pos_y+motor_side/4,motor_clamp_pos_z+motor_side/2]) {
          cube([motor_clamp_mount_width,motor_side/2,wall_thickness*2],center=true);
        }
        translate([0,0,x_rod_spacing/2]) {
          rotate([0,90,0]) {
            hole(lower_bearing_diam+bearing_body_wall,motor_clamp_mount_width,bearing_resolution);
          }
        }
      }
      translate([0,carriage_plate_pos_y-carriage_plate_thickness/2,motor_clamp_pos_z-motor_side/2-wall_thickness]) {
        cube([motor_clamp_mount_width,rounded_diam,rounded_diam],center=true);
      }
    }
  }

  module holes() {
    plain_carriage_holes();

    // motor clamp
    translate([motor_clamp_pos_x,motor_clamp_pos_y,motor_clamp_pos_z]) {
      rotate([0,0,180]) {
        rotate([-90,0,0]) {
          motor_clamp_holes();
        }
      }
    }

    translate([0,carriage_plate_pos_y-carriage_plate_thickness/2-rounded_diam/2,motor_clamp_pos_z-motor_side/2-wall_thickness-rounded_diam/2]) {
      rotate([0,90,0]) {
        hole(rounded_diam,x_carriage_width+1,resolution);
      }
    }

    // trim non-clamp bearing side to provide clearance for titan gear
    translate([motor_clamp_mount_width,0,(lower_bearing_diam/2+bearing_body_wall/2+x_rod_spacing/2-0.05)*-anchor_side]) {
      cube([x_carriage_width,x_carriage_width,2*(lower_bearing_diam+bearing_body_wall)],center=true);
    }

    // tensioner cavity
    if (screw_tensioner) {
      translate([x_carriage_width/2,0,tensioner_clamp_pos_z]) {
        hull() {
          for(y=[front,rear]) {
            for(z=[top,bottom]) {
              translate([0,(tensioner_hole_width/2-rounded_diam/2)*y,(tensioner_clamp_height/2-rounded_diam/2)*z]) {
                rotate([0,90,0]) {
                  hole(rounded_diam,tensioner_hole_depth*2,resolution);
                }
              }
            }
          }
        }
        hull() {
          for(y=[front,rear]) {
            for(z=[top,bottom]) {
              translate([1,(tensioner_hole_width/2-rounded_diam/2)*y,(tensioner_clamp_height/2-rounded_diam/2)*z]) {
                rotate([0,90,0]) {
                  hole(rounded_diam+extrusion_width*2,2,resolution);
                  hole(1,4+extrusion_width*8,resolution);
                }
              }
            }
          }
        }
      }

      // tensioner screw
      //tensioner_screw_length = (x_carriage_width - tensioner_hole_depth - extrusion_height) * 2;
      translate([x_carriage_width/2+extrusion_height,0,tensioner_screw_pos_z]) {
        rotate([0,90,0]) {
          hole(tensioner_screw_hole_diam,tensioner_hole_depth*2+18,resolution);
        }
      }
      translate([-x_carriage_width/2,0,tensioner_screw_pos_z]) {
        rotate([0,90,0]) {
          hole(tensioner_nut_hole_diam,x_carriage_width-10,6);
          translate([0,0,-0.5]) {
            hull() {
              hole(tensioner_nut_hole_diam+1,1,6);
              hole(tensioner_nut_hole_diam,2,6);
            }
          }
        }
      }
    } else {
      // slack for belts
      translate([0,belt_width/2-2,motor_belt_pos_z+belt_thickness/2*anchor_side]) {
        hull() {
          rotate([90,0,0]) {
            hole(belt_width,belt_width*2,resolution);
          }
          cube([belt_width*2,belt_width*2,belt_thickness],center=true);
        }
      }
    }

    translate([-4,0,motor_belt_pos_z]) {
      // belt teeth
      translate([-x_carriage_width/2,-2,0]) {
        belt_teeth(x_carriage_width/2,anchor_side);
      }

      // belt access
      if (screw_tensioner) {
        translate([-x_carriage_width/2,0,anchor_side*belt_thickness/2]) {
          hull() {
            translate([0,belt_width*.6,-anchor_side*5]) {
              cube([x_carriage_width,1,11],center=true);
            }
            translate([0,bearing_body_diam/2,0]) {
              cube([x_carriage_width+15,1,10],center=true);
            }
          }
        }
      } else {
        translate([x_carriage_width/2+8,-2,anchor_side*belt_thickness]) {
          belt_teeth(x_carriage_width/2,-anchor_side);
        }

        hull() {
          translate([0,belt_width/2+rounded_diam/2,rounded_diam*anchor_side]) {
            rotate([0,90,0]) {
              hole(rounded_diam,x_carriage_width*2,resolution);
            }
            translate([0,0,rounded_diam*-anchor_side]) {
              cube([x_carriage_width*2,rounded_diam,rounded_diam*2],center=true);
            }
            rotate([40*anchor_side,0,0]) {
              translate([0,rounded_diam,0]) {
                cube([x_carriage_width*2,rounded_diam*2,rounded_diam],center=true);
              }
            }
          }
        }
      }
    }

    // opening for unanchored side of belt
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

  if (screw_tensioner) {
    translate([x_carriage_width/2+tensioner_clamp_length/2,0,tensioner_clamp_pos_z]) {
      vertical_belt_clamp();
    }
  }

  translate([motor_clamp_pos_x+motor_clamp_mount_width/2+5,motor_clamp_pos_y,motor_clamp_pos_z]) {
    rotate([0,90,0]) {
      % motor();
    }
  }

  for(side=[top,bottom]) {
    translate([-25,0,motor_pos_z+side*(motor_pulley_diameter/2+belt_thickness/2)]) {
      % cube([50,belt_width,belt_thickness],center=true);
    }
    translate([25,0,idler_pos_z+side*(idler_diam/2+belt_thickness/2)]) {
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
              hole(rounded_diam,tensioner_clamp_length-1,resolution);
              hole(rounded_diam-1,tensioner_clamp_length,resolution);
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

module plate() {
  translate([0,0,x_carriage_width/2]) {
    rotate([0,0,90]) {
      rotate([0,-90,0]) {
        motor_clamp_carriage();
      }
    }
  }

  if (screw_tensioner) {
    translate([-bearing_diam-bearing_body_wall-tensioner_clamp_width/2,anchor_side*x_rod_spacing/2,tensioner_clamp_length/2]) {
      rotate([0,0,90]) {
        rotate([0,90,0]) {
          vertical_belt_clamp();
        }
      }
    }
  }
}


motor_clamp_carriage();
//plate();
