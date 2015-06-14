include <util.scad>
include <config.scad>
include <positions.scad>
include <hotends.scad>
use <motor_clamp.scad>

bearing_body_diam = bearing_diam+wall_thickness*2;
space_between_bearing_bodies = x_rod_spacing - bearing_body_diam;
space_between_bearings = 1;
x_carriage_width = bearing_len*2 + space_between_bearings;
carriage_plate_thickness = 5;
carriage_plate_pos_y     = bearing_body_diam/2*front;
carriage_screw_diam = m3_diam;
carriage_nut_diam = m3_nut_diam;
carriage_nut_thickness = 2;

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

idler_diam  = 16;
idler_pos_z = motor_pulley_diameter/2-idler_diam/2;

idler_diam  = 10;
idler_pos_z = -2;

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
          translate([extrusion_height,bearing_diam/2,0]) {
            cube([x_carriage_width,bearing_diam,0.05],center=true);
          }
        }
      }
    }
  }
}

module plain_carriage() {
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
    plain_carriage_holes();

    translate([0,(bearing_body_diam/2+carriage_plate_thickness/2)*front,0]) {
      // mounting holes
      for(z=[0,belt_clamp_center_screw_offset_z]) {
        for(side=[left,center,right]) {
          translate([carriage_screw_spacing/2*side,0,z]) {
            rotate([90,0,0]) {
              rotate([0,0,22.5]) {
                hole(carriage_screw_diam,bearing_body_diam,8);
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

module motor_clamp_carriage() {
  clamp_pos_x = -x_carriage_width/2+motor_clamp_mount_width/2;
  clamp_pos_y = carriage_plate_pos_y-carriage_plate_thickness/2-motor_side/2-3;
  clamp_pos_z = x_rod_spacing/2+bearing_body_diam/2-motor_side/2-wall_thickness;
  module body() {
    // bearing holders
    for(side=[top,bottom]) {
      translate([0,0,x_rod_spacing/2*side]) {
        hull() {
          translate([0,-carriage_plate_thickness/2,0]) {
            rotate([0,90,0]) {
              rotate([0,0,rotation]) {
                hole(bearing_body_diam,x_carriage_width,resolution);
              }
            }
          }
          translate([0,0,0]) {
            rotate([0,90,0]) {
              rotate([0,0,rotation]) {
                hole(bearing_body_diam,x_carriage_width,resolution);
              }
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
                  rotate([0,0,rotation]) {
                    hole(bearing_body_diam,motor_clamp_mount_width,resolution);
                  }
                }
              }

              translate([0,-bearing_body_diam/2,bearing_body_diam/2*side]) {
                cube([motor_clamp_mount_width,motor_clamp_mount_width,bearing_body_diam],center=true); {
                }
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
    // mounting holes
    for(side=[left,right]) {
      translate([carriage_screw_spacing/2*side,(bearing_body_diam/2+carriage_plate_thickness/2)*front,0]) {
        rotate([90,0,0]) {
          rotate([0,0,22.5]) {
            hole(carriage_screw_diam,bearing_body_diam,8);
          }
          translate([0,0,10]) {
            rotate([0,0,90]) {
              hole(carriage_nut_diam,carriage_nut_thickness*2+20,6);
            }
          }
        }
      }
    }

    // clamp
    translate([clamp_pos_x,clamp_pos_y,clamp_pos_z]) {
      rotate([0,0,180]) {
        rotate([-90,0,0]) {
          motor_clamp_holes();
        }
      }
    }
  }

  color("LightBlue") difference() {
    body();
    holes();
  }

  translate([clamp_pos_x+motor_clamp_mount_width/2+10,clamp_pos_y,clamp_pos_z]) {
    rotate([0,90,0]) {
      //% motor();
    }
  }
}

module e3d_hotend() {
  module body() {
    hotend_mount_height    = hotend_height_above_groove + hotend_groove_height + hotend_height_below_groove;

    translate([0,0,-hotend_height_above_groove/2]) {
      hole(hotend_mount_diam,hotend_height_above_groove,resolution);
    }
    translate([0,0,-hotend_height_above_groove-hotend_groove_height/2]) {
      hole(hotend_groove_diam,hotend_groove_height+1,resolution);
    }
    translate([0,0,-hotend_height_above_groove-hotend_groove_height-hotend_height_below_groove/2-10]) {
      hole(hotend_mount_diam,hotend_height_below_groove+20,resolution);
    }

    num_fins      = 11;
    fin_thickness = 1;
    fin_spacing   = 2.5;

    translate([0,0,-hotend_dist_to_heatsink_bottom+fin_thickness/2]) {
      for(z=[0:10]) {
        translate([0,0,fin_spacing*z]) {
          hole(hotend_heatsink_diam,fin_thickness,resolution);
        }
      }
    }

    translate([0,0,-hotend_len]) {
      hull() {
        translate([0,0,0.5]) {
          hole(.5,1,36);
        }
        translate([0,0,3.5]) {
          hole(4,2,36);
        }
      }

      translate([0,-20/2+4.5,5+11.5/2]) {
        cube([16,20,11.5],center=true);
      }
    }
  }

  module holes() {
    //hole(filament_diam,hotend_len*3,8);
  }

  difference() {
    body();
    holes();
  }
}

module e3d_clamp_carriage() {
  clamp_pos_x = -x_carriage_width/2+motor_clamp_mount_width/2;
  clamp_pos_y = carriage_plate_pos_y-carriage_plate_thickness/2-motor_side/2-3;
  clamp_pos_z = x_rod_spacing/2+bearing_body_diam/2-motor_side/2-wall_thickness;

  carriage_height = x_rod_spacing + bearing_body_diam;

  hotend_x = 0;
  hotend_y = -bearing_diam/2-carriage_plate_thickness-hotend_heatsink_diam/2;
  hotend_z = -carriage_height/2+hotend_dist_to_heatsink_bottom;

  fan_side         = 30;
  fan_diam         = fan_side-wall_thickness*2;
  fan_screw_diam   = 2.6;
  fan_screw_depth  = 7;
  fan_thickness    = 10;
  fan_pos_y        = hotend_y;
  fan_pos_z        = -carriage_height/2+fan_side/2;
  fan_hole_spacing = 24;
  heatsink_pos_z   = hotend_z-hotend_len+hotend_nozzle_to_bottom_fin+hotend_heatsink_height/2;
  heatsink_pos_z   = hotend_z-hotend_dist_to_heatsink_bottom+hotend_heatsink_height/2;

  rounded_diam = 8;

  hotend_holder_diam = hotend_diam+wall_thickness*4;
  hotend_holder_width = x_carriage_width/2 + hotend_holder_diam/2;

  module hotend_mount_body() {
    translate([-x_carriage_width/2+hotend_holder_width/2,-bearing_body_diam/4-carriage_plate_thickness/2,-carriage_height/2+bearing_body_diam/2]) {
      cube([hotend_holder_width,bearing_body_diam/2+carriage_plate_thickness,bearing_body_diam],center=true);
    }
    hull() {
      translate([-x_carriage_width/2+hotend_holder_width/2,-bearing_body_diam/2,hotend_z-hotend_height_above_groove/2]) {
        cube([hotend_holder_width,carriage_plate_thickness,0.1],center=true);
      }
      translate([0,hotend_y,hotend_z-hotend_height_above_groove/2]) {
        hole(hotend_mount_diam+wall_thickness*3,0.1,resolution);
      }
      translate([0,hotend_y,fan_pos_z]) {
        hole(hotend_holder_diam,fan_side,resolution);
      }
      translate([-x_carriage_width/2+wall_thickness*2,fan_pos_y,fan_pos_z]) {
        for(y=[front,rear]) {
          for(z=[top,bottom]) {
            translate([0,(fan_side/2-rounded_diam/2)*y,(fan_side/2-rounded_diam/2)*z]) {
              rotate([0,90,0]) {
                hole(rounded_diam,wall_thickness*4,resolution);
              }
            }
          }
        }
      }
    }
  }

  module hotend_mount_holes() {
    // hotend mount
    hotend_groove_depth = (hotend_diam - hotend_groove_diam)/2;
    translate([0,hotend_y,hotend_z-hotend_height_above_groove-hotend_groove_height/2]) {
      zip_tie_hole(hotend_groove_diam+wall_thickness*3);
    }

    translate([0,hotend_y,hotend_z-hotend_len/2]) {
      hull() {
        for(r=[0,-60]) {
          rotate([0,0,r]) {
            translate([20,1,0]) {
              cube([40,2,hotend_len+10],center=true);
            }
          }
        }
      }
    }
    translate([hotend_groove_diam*.8,hotend_y-hotend_groove_diam,hotend_z-hotend_len/2]) {
      //cube([hotend_groove_diam,hotend_groove_diam*1.5,hotend_len+1],center=true);
    }

    groove_slop = 0.1;
    translate([0,hotend_y,hotend_z-groove_slop/2]) {
      hole(hotend_mount_diam,hotend_height_above_groove*2,resolution);

      translate([20,0,0]) {
        cube([40,hotend_mount_diam-0.1,hotend_height_above_groove*2],center=true);
      }
    }
    translate([0,hotend_y,hotend_z-hotend_height_above_groove-hotend_groove_height/2]) {
      hole(hotend_groove_diam,hotend_groove_height*2,resolution);

      translate([20,0,0]) {
        cube([40,hotend_groove_diam-0.1,hotend_groove_height*2],center=true);
      }
    }
    translate([0,hotend_y,hotend_z-hotend_height_above_groove-hotend_groove_height-10+groove_slop/2]) {
      hole(hotend_mount_diam,20,resolution);

      translate([20,0,0]) {
        cube([40,hotend_mount_diam-0.1,20],center=true);
      }
    }
    hull() {
      translate([-x_carriage_width/2,fan_pos_y,fan_pos_z]) {
        rotate([0,90,0]) {
          hole(fan_diam,fan_thickness*3,resolution);
        }
      }
      translate([0,hotend_y,fan_pos_z]) {
        hole(hotend_diam,1,resolution);
      }
    }
    translate([-x_carriage_width/2,fan_pos_y,fan_pos_z]) {
      for(y=[front,rear]) {
        for(z=[top,bottom]) {
          translate([0,fan_hole_spacing/2*y,fan_hole_spacing/2*z]) {
            rotate([0,90,0]) {
              hole(fan_screw_diam,fan_screw_depth*2,8);
            }
          }
        }
      }
    }
    translate([0,hotend_y,heatsink_pos_z-0.05]) {
      hole(hotend_diam,hotend_heatsink_height+0.1,resolution);

      translate([20,0,0]) {
        cube([40,hotend_diam-0.4,hotend_heatsink_height+0.1],center=true);
      }
    }
  }

  module body() {
    hotend_mount_body();
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

    // mount plate
    translate([0,carriage_plate_pos_y,0]) {
      cube([x_carriage_width,carriage_plate_thickness,x_rod_spacing],center=true);
    }

    // clamp
    translate([clamp_pos_x,0,0]) {
    }
  }

  module holes() {
    hotend_mount_holes();
    plain_carriage_holes();

    // mounting holes
    for(side=[left,right]) {
      translate([carriage_screw_spacing/2*side,(bearing_body_diam/2+carriage_plate_thickness/2)*front,0]) {
        rotate([90,0,0]) {
          hole(carriage_screw_diam,bearing_body_diam,8);
          translate([0,0,40]) {
            hole(carriage_nut_diam,carriage_nut_thickness*2+80,6);
          }
        }
      }
    }
  }

  color("LightBlue") difference() {
    body();
    holes();
  }

  translate([clamp_pos_x+motor_clamp_mount_width/2+10,clamp_pos_y,clamp_pos_z]) {
    rotate([0,90,0]) {
      //% motor();
    }
  }

  translate([hotend_x,hotend_y,hotend_z]) {
    // hotend
    % e3d_hotend();
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
    tooth_diam = 1.4;
    // belt teeth
    translate([0,belt_clamp_depth/2,0]) {
      translate([-20+1,0,.5]) {
        cube([40,belt_width*2,1],center=true);
      }
      for(i=[0:20]) {
        translate([-2*i,0,0]) {
          rotate([90,0,0]) {
            rotate([0,0,90]) {
              hole(tooth_diam,belt_width*2,6);
            }
          }
        }
      }
    }
  }

  difference() {
    body();
    holes();
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

module clamp_assembly() {
  translate([motor_x,motor_y,motor_z]) {
    rotate([0,90,0]) {
      //% motor();
    }
  }

  //plain_carriage();
  motor_clamp_carriage();

  translate([0,0.1,0]) {
    belt_clamp();
  }

  // x rods
  for(side=[top,bottom]) {
    translate([0,0,x_rod_spacing/2*side]) {
      rotate([0,90,0]) {
        //% hole(8,200,36);
      }
    }
  }

  translate([40,0,idler_pos_z+idler_diam/2+belt_thickness/2]) {
    % cube([50,belt_width,belt_thickness],center=true);
  }

  // clearance check for twisted belt
  /*
  */
  % hull() {
    translate([-50,0,(motor_pulley_diameter/2+belt_thickness/2)*bottom]) {
      cube([1,belt_thickness,belt_width],center=true);
    }
    translate([50,0,idler_pos_z+(idler_diam/2+belt_thickness/2)*bottom]) {
      cube([1,belt_thickness,belt_width],center=true);
    }
  }
  % hull() {
    translate([-50,0,(motor_pulley_diameter/2+belt_thickness/2)*bottom]) {
      cube([1,belt_width,belt_thickness],center=true);
    }
    translate([50,0,idler_pos_z+(idler_diam/2+belt_thickness/2)*bottom]) {
      cube([1,belt_width,belt_thickness],center=true);
    }
  }

  // motor pulleys
  % translate([50*left,0,0]) {
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

module e3d_plate() {
  translate([x_rod_spacing,0,0]) {
    translate([0,0,-belt_clamp_pos_y+belt_clamp_depth/2]) {
      rotate([0,0,180]) {
        rotate([90,0,0]) {
          //belt_clamp();
        }
      }
    }
  }

  translate([-x_rod_spacing,0,x_carriage_width/2]) {
    rotate([0,-90,0]) {
      e3d_clamp_carriage();
    }
  }
}

module clamp_plate() {
  translate([x_rod_spacing,0,0]) {
    rotate([0,-90,0]) {
      //plain_carriage();
    }
    translate([0,0,-belt_clamp_pos_y+belt_clamp_depth/2]) {
      rotate([0,0,180]) {
        rotate([90,0,0]) {
          belt_clamp();
        }
      }
    }
  }

  translate([-x_rod_spacing,0,x_carriage_width/2]) {
    rotate([0,-90,0]) {
      motor_clamp_carriage();
    }
  }
}

//motor_clamp_carriage();
//e3d_clamp_carriage();

//clamp_plate();
//clamp_assembly();
e3d_plate();
