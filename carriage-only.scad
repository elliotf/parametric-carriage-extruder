include <util.scad>
include <config.scad>
include <positions.scad>
include <hotends.scad>
use <motor_clamp.scad>

rounded_diam = 4;

bearing_body_diam = bearing_diam+wall_thickness*3;
space_between_bearing_bodies = x_rod_spacing - bearing_body_diam;
space_between_bearings = 1;
x_carriage_width = bearing_len*2 + space_between_bearings;
carriage_plate_thickness = 5;
carriage_plate_pos_y     = bearing_body_diam/2*front;
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

motor_belt_pos_z  = motor_pos_z + motor_pulley_diameter/2;

tensioner_screw_hole_diam = 3.25;
tensioner_clamp_gap = 0.2;
tensioner_clamp_height = wall_thickness + belt_thickness + wall_thickness + m3_nut_diam/2 + tensioner_screw_hole_diam/2 + wall_thickness;
tensioner_clamp_width  = belt_width + wall_thickness*2;
tensioner_screw_belt_spacing = belt_thickness/2 + wall_thickness + extrusion_width + m3_nut_diam/2;
tensioner_screw_pos_z = motor_belt_pos_z + tensioner_screw_belt_spacing;
tensioner_clamp_pos_z = tensioner_screw_pos_z + tensioner_screw_hole_diam/2 + wall_thickness - tensioner_clamp_height/2;

idler_diam  = 10;
idler_belt_pos_z  = idler_pos_z + idler_diam/2;

module plain_carriage_holes() {
  for(side=[top,bottom]) {
    translate([0,0,x_rod_spacing/2*side]) {
      // bearing hole
      rotate([0,90,0]) {
        hole(bearing_diam,x_carriage_width*2,resolution);
      }

      // bevels
      for (end=[left,right]) {
        translate([x_carriage_width/2*end,0,0]) {
          rotate([0,90*end,0]) {
            hull() {
              translate([0,0,1.5+0.05]) {
                hole(bearing_diam+1,3,resolution);
              }
              hole(bearing_diam-0.05,3,resolution);
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
  }
}

module belt_clamp() {
  body_rounded_diam = carriage_screw_diam + wall_thickness*2;

  idler_side             = -motor_side;
  zip_tie_width          = 3;
  zip_tie_thickness      = 2;
  doubled_belt_thickness = belt_thickness*3 - 0.1;
  idler_belt_pos_z       = idler_pos_z+idler_diam/2+belt_thickness/2;

  module body() {
    reinforcement_length = 6;
    translate([0,0,belt_clamp_height/2-carriage_nut_diam/2-0.5]) {
      // main body
      hull() {
        for(side=[left,right]) {
          for(end=[front,rear]) {
            translate([(belt_clamp_width/2-body_rounded_diam/2)*side,0,(belt_clamp_height/2-body_rounded_diam/2)*end]) {
              rotate([90,0,0]) {
                rotate([0,0,22.5/4]) {
                  hole(body_rounded_diam,belt_clamp_depth,32);
                }
              }
            }
          }
        }
      }

      // belt opening reinforcement
      hull() {
        for(end=[front,rear]) {
          translate([belt_clamp_width/2-body_rounded_diam/2,1,(belt_clamp_height/2-body_rounded_diam/2)*end]) {
            rotate([90,0,0]) {
              rotate([0,0,22.5/4]) {
                hole(body_rounded_diam,belt_clamp_depth,32);
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    translate([0,belt_opening_width/2,0]) {
      for(z=[0]) {
        for(side=[left,right]) {
          translate([carriage_screw_spacing/2*side,0,z]) {
            rotate([90,0,0]) {
              rotate([0,0,22.5]) {
                hole(carriage_screw_diam,bearing_body_diam*2,8);
              }
            }
          }
        }
      }
    }

    belt_retainer_offset_x = -3;
    motor_side             = -1;
    motor_belt_pos_z       = motor_pulley_diameter/2+belt_thickness/2;

    // belt path
    translate([carriage_nut_diam*.85*motor_side+belt_retainer_offset_x,0,motor_belt_pos_z]) {
      translate([x_carriage_width/2*motor_side,0,0]) {
        cube([x_carriage_width,belt_opening_width+0.05,belt_thickness],center=true);
      }
      // belt teeth
      for (i = [0:17]) {
        translate([(-0.05+i*belt_tooth_distance)*motor_side,0,-belt_tooth_height/2-belt_thickness/2]) {
          cube([belt_tooth_distance*belt_tooth_ratio,belt_opening_width+0.05,belt_tooth_height+0.05],center=true);
        }
      }

      // belt slack space
      hull() {
        translate([.4*-motor_side,0,belt_thickness/2*motor_side]) {
          rotate([90,0,0]) {
            //cube([belt_thickness*2,belt_opening_width+0.05,carriage_nut_diam+belt_thickness*2],center=true);
            rotate([0,0,22.5/4]) {
              hole(belt_thickness*2,belt_opening_width+0.05,32);
            }
          }

          translate([10*-motor_side,0,20*-motor_side]) {
            rotate([90,0,0]) {
              hole(belt_thickness*2,belt_opening_width+0.05,16);
            }
          }
        }
      }
    }

    // idler belt retainer
    zip_tie_cavity_diam          = 6;
    zip_tie_cavity_rounded_width = 6 + zip_tie_cavity_diam;
    zip_tie_cavity_total_width   = zip_tie_cavity_rounded_width + 1;
    zip_tie_cavity_offset        = .5;
    translate([belt_retainer_offset_x,0,idler_belt_pos_z]) {
      translate([0,0,-belt_thickness/2+doubled_belt_thickness/2]) {
        translate([carriage_screw_spacing/2+50,0,0]) {
          cube([carriage_screw_spacing/2+100,belt_opening_width+0.05,doubled_belt_thickness],center=true);
        }

        translate([carriage_screw_spacing/4-belt_thickness*4.5,0,0]) {
          intersection() {
            zip_tie_hole(belt_width,zip_tie_width,zip_tie_thickness);
            translate([-19.95,-19.95,0]) {
              cube([40,40,40],center=true);
            }
          }
          translate([zip_tie_cavity_total_width/2+zip_tie_cavity_offset/2,(belt_width/2+zip_tie_thickness/2)*front,0]) {
            cube([zip_tie_cavity_total_width+zip_tie_cavity_offset,zip_tie_thickness,zip_tie_width],center=true);
          }
          translate([(belt_width/2+zip_tie_thickness/2)*left,5,0]) {
            cube([zip_tie_thickness,10,zip_tie_width],center=true);
          }

          hull() {
            for(side=[top,bottom]) {
              for(x=[zip_tie_cavity_diam/2,zip_tie_cavity_rounded_width-zip_tie_cavity_diam/2]) {
                translate([zip_tie_cavity_offset+x,0,1*side]) {
                  rotate([90,0,0]) {
                    hole(zip_tie_cavity_diam,belt_opening_width+0.05,32);
                  }
                }
              }
            }
            translate([zip_tie_cavity_offset+zip_tie_cavity_total_width-.5,0,0]) {
              cube([1,belt_opening_width+0.05,belt_thickness*3],center=true);
            }
          }
        }
      }
    }
  }

  difference() {
    translate([0,belt_clamp_pos_y,0]) {
      body();
    }
    holes();
  }
}

module motor_clamp_carriage() {
  clamp_pos_x = x_carriage_width/2-motor_clamp_mount_width/2;
  clamp_pos_y = carriage_plate_pos_y-carriage_plate_thickness/2-motor_side/2-3;
  clamp_pos_z = x_rod_spacing/2+bearing_body_diam/2-motor_side/2-wall_thickness;

  module body() {
    // bearing holders
    for(side=[top,bottom]) {
      translate([0,0,x_rod_spacing/2*side]) {
        hull() {
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

    hull() {
      translate([0,0,x_rod_spacing/2]) {
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
      //translate([0,0,motor_pos_z-motor_pulley_diameter/2+rounded_diam/2+belt_width/2]) {
      translate([0,0,tensioner_clamp_pos_z-tensioner_clamp_height/2+rounded_diam/2]) {
        translate([0,tensioner_clamp_width/2-rounded_diam/2,0]) {
        //translate([0,bearing_body_diam/2-rounded_diam/2-tensioner_clamp_gap-wall_thickness,0]) {
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
      cube([x_carriage_width,carriage_plate_thickness,x_rod_spacing],center=true);
    }

    // clamp
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
    tensioner_hole_depth = x_carriage_width/2-2;
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
        hole(m3_nut_diam+0.2,x_carriage_width-2,6);
      }
    }

    translate([0,0,motor_belt_pos_z]) {
      // belt teeth
      translate([-x_carriage_width/2,-2,0]) {
        belt_teeth(x_carriage_width/2);
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
  }

  color("LightBlue") difference() {
    body();
    holes();
  }

  translate([clamp_pos_x-motor_clamp_mount_width/2-10,clamp_pos_y,clamp_pos_z]) {
    rotate([0,-90,0]) {
      //% motor();
    }
  }

  translate([25,0,idler_belt_pos_z+belt_thickness/2]) {
    % cube([50,belt_width,belt_thickness],center=true);
  }
  translate([-25,0,motor_belt_pos_z+belt_thickness/2]) {
    % cube([50,belt_width,belt_thickness],center=true);
  }

  // clearance check for twisted belt
  % hull() {
    translate([-50,0,motor_pos_z-motor_pulley_diameter/2-belt_thickness/2]) {
      cube([1,belt_thickness,belt_width],center=true);
    }
    translate([50,0,idler_pos_z-idler_diam/2-belt_thickness/2]) {
      cube([1,belt_thickness,belt_width],center=true);
    }
  }
  % hull() {
    translate([-50,0,motor_pos_z-motor_pulley_diameter/2-belt_thickness/2]) {
      cube([1,belt_width,belt_thickness],center=true);
    }
    translate([50,0,idler_pos_z-idler_diam/2-belt_thickness/2]) {
      cube([1,belt_width,belt_thickness],center=true);
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

module belt_teeth(leng) {
  tooth_diam  = 1.4;
  tooth_pitch = 2;
  num_teeth = floor(leng / tooth_pitch);
  // belt teeth
  translate([0,belt_width/2,0]) {
    translate([0,0,.5]) {
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
  rounded_diam = 4;
  module body() {
    hull() {
      for(z=[top,bottom]) {
        for(y=[front,rear]) {
          translate([0,(belt_clamp_depth/2-rounded_diam/2)*y,(belt_clamp_height/2-rounded_diam/2)*z]) {
            rotate([0,90,0]) {
              hole(rounded_diam,belt_clamp_width,resolution);
            }
          }
        }
      }
    }
  }

  module holes() {
    translate([belt_clamp_width/2,0,0]) {
      belt_teeth(belt_clamp_width);
    }
  }

  difference() {
    body();
    holes();
  }
}

motor_clamp_carriage();

translate([x_carriage_width/2-belt_clamp_width/2,0,idler_belt_pos_z]) {
  //vertical_belt_clamp();
}
