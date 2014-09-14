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
    height_groove_and_above = hotend_clamped_height;
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
    hole(filament_diam,hotend_length*3,8);
  }

  difference() {
    body();
    holes();
  }
}

module hotend_hole() {
  hotend_clearance = 0.15;

  hotend_res = resolution/2;

  above_height = hotend_height_above_groove+hotend_clearance*2;

  rotate([0,0,180/hotend_res]) {
    translate([0,0,-hotend_clamp_height]) {
      hole(hotend_groove_diam+hotend_clearance,hotend_clamp_height*2,hotend_res);
    }

    translate([0,0,-above_height/2+hotend_clearance]) {
      hole(hotend_diam+hotend_clearance,above_height,hotend_res);
    }

    translate([0,0,-hotend_clamped_height-10+hotend_clearance]) {
      hole(hotend_diam,20,hotend_res);
    }

    hole(filament_diam+1,200,hotend_res);
  }
}

module idler_hole() {
  idler_x = hotend_clamp_removable_width;
  idler_y = idler_bearing_y - hotend_y + hotend_motor_offset_y;
  idler_z = 0;

  hull() {
    translate([idler_x,,idler_z]) {
      translate([0,idler_y-idler_bearing_inner*.25,0]) {
        cube([idler_width+1,idler_bearing_inner+0.5,idler_bearing_outer+wall_thickness],center=true);
      }

      translate([0,-motor_side/2+.95,hotend_clamp_height/2+0.5]) {
        cube([idler_width+1,2,motor_side+1],center=true);
      }
    }
  }
}

module bearing() {
  difference() {
    cylinder(r=bearing_outer/2,h=bearing_height,center=true);
    cylinder(r=bearing_inner/2,h=bearing_height+0.05,center=true);
  }
}

module idler_bearing() {
  difference() {
    hole(idler_bearing_outer,idler_bearing_height,36);
    hole(idler_bearing_inner,idler_bearing_height*2,36);
  }
}

module carriage() {
  module body() {
    // bearing holders
    for(side=[top,bottom]) {
      translate([0,0,x_rod_spacing/2*side]) {
        rotate([0,90,0]) {
          hole(bearing_body_diam,x_carriage_width,resolution);
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
    translate([hotend_clamp_x,hotend_clamp_y-idler_groove_material/2,hotend_clamp_z]) {
      cube([hotend_clamp_width,motor_side+idler_groove_material,hotend_clamp_height],center=true);
    }

    // motor and mounts
    dist_from_motor_to_carriage_end = x_carriage_width/2-motor_x;
    motor_mount_depth = motor_side-motor_hole_spacing;

    motor_mount_post_diam = motor_screw_diam+wall_thickness*2;
    screw_area_width  = dist_from_motor_to_carriage_end;
    screw_area_depth  = motor_mount_post_diam/2+(motor_side/2-motor_hole_spacing/2) + 3.5;
    screw_area_height = m3_nut_diam+wall_thickness*1.5;
    screw_area_offset_y = screw_area_depth/2-motor_mount_post_diam/2;
    hull() {
      translate([motor_x+dist_from_motor_to_carriage_end/2,0,x_rod_spacing/2]) {
        rotate([0,90,0]) {
          hole(bearing_body_diam,dist_from_motor_to_carriage_end,resolution);
        }
      }
      translate([motor_x+dist_from_motor_to_carriage_end/2,motor_y+motor_hole_spacing/2,motor_z+motor_hole_spacing/2]) {
        rotate([0,90,0]) rotate([0,0,22.5]) {
          hole(motor_screw_diam+wall_thickness*2,dist_from_motor_to_carriage_end,8);
        }
      }
    }

    // captive nut area for idler
    translate([motor_x+dist_from_motor_to_carriage_end/2,motor_y+motor_hole_spacing/2+screw_area_offset_y,motor_z+motor_hole_spacing/2+screw_area_height/2-wall_thickness/2]) {
      cube([screw_area_width,screw_area_depth,screw_area_height],center=true);
    }
  }

  module holes() {
    for(side=[top,bottom]) {
      translate([0,0,x_rod_spacing/2*side]) {
        // bearing hole
        rotate([0,90,0]) {
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
            rotate([0,90,0]) rotate([0,0,22.5]) {
              hole(motor_screw_diam,x_carriage_width*2,8);
            }
          }
        }
      }
    }

    nut_hole_depth = carriage_plate_thickness-3;
    translate([0,bearing_body_diam/2*front,0]) {
      // center belt clamp mount hole
      translate([0,0,belt_clamp_center_screw_offset_z]) {
        rotate([90,0,0]) {
          rotate([0,0,90]) {
            hole(carriage_screw_diam,bearing_body_diam,6);
            hole(carriage_nut_diam,nut_hole_depth*2,6);
          }
        }
      }

      // belt clamp mount holes
      for(side=[left,right]) {
        translate([carriage_screw_spacing/2*side,0,0]) {
          rotate([90,0,0]) {
            rotate([0,0,90]) {
              hole(carriage_screw_diam,bearing_body_diam,6);
              hole(carriage_nut_diam,nut_hole_depth*2,6);
            }
          }
        }
      }
    }

    translate([motor_x,motor_y,motor_z]) {
      idler_hole();
    }

    hull() {
      for(side=[top,bottom]) {
        translate([idler_screw_x,motor_y+motor_side/2+2,idler_screw_z+0.75*side]) {
          rotate([90,0,0]) {
            rotate([0,0,90]) {
              hole(m3_nut_diam,m3_nut_height*2,6);
            }
          }
        }
      }
    }

    hull() {
      for(side=[top,bottom]) {
        translate([idler_screw_x,motor_y+motor_side/2+2,idler_screw_z+0.75*side]) {
          rotate([90,0,0]) {
            rotate([0,0,22.5]) {
              hole(m3_diam,100,8);
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
  motor_x       = 0;
  motor_y       = 0;
  motor_z       = 0;
  motor_screw_z = -motor_hole_spacing/2;
  carriage_clearance = 0.4;
  tensioner_arm_offset_y = (hotend_motor_offset_y+motor_side/2+hotend_clamp_removable_width/2+1)*front;
  offset_x = hotend_clamp_removable_width/2;
  offset_y = 0;
  offset_z = -motor_side/2+hotend_clamp_height/2;

  idler_x = hotend_clamp_removable_width;
  idler_y = idler_bearing_y - hotend_y + hotend_motor_offset_y;
  idler_z = 0;

  hinge_width = hotend_clamp_removable_width-2;

  module body() {
    translate([offset_x,offset_y-carriage_clearance/2-idler_groove_material/2,offset_z]) {
      cube([hotend_clamp_removable_width,motor_side-carriage_clearance+idler_groove_material,hotend_clamp_height],center=true);
    }
  }

  module holes() {
    translate([hotend_clamp_removable_width,hotend_motor_offset_y,hotend_motor_offset_z]) {
      hotend_hole();
    }

    for(side=[left,right]) {
      translate([0,motor_hole_spacing/2*side,motor_screw_z]) {
        rotate([0,90,0]) {
          rotate([0,0,22.5]) {
            hole(motor_screw_diam,motor_len*2,8);
          }
        }
      }
    }

    rotate([0,90,0]) {
      hole(motor_shoulder_diam+1,motor_shoulder_height*2+0.5,32);
    }

    /*
    hull() {
      translate([idler_x,idler_y-idler_bearing_inner*.25,idler_z]) {
        translate([0,0.5,0]) {
          cube([idler_width+1,idler_bearing_inner+1,idler_bearing_outer+wall_thickness],center=true);
        }


        translate([0,-idler_bearing_outer/2+0.5,hotend_clamp_height/2+1]) {
          cube([idler_width+1,2,motor_side],center=true);
        }
      }
    }
    */

    idler_hole();
  }

  color("Khaki") difference() {
    body();
    holes();
  }
}

module belt_clamp() {
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
          cube([x_carriage_width+1,1,carriage_nut_diam*2],center=true);
        }
      }
    }
  }

  color("Plum") difference() {
    body();
    holes();
  }
}

module idler_arm() {
  bearing_x = idler_bearing_x - motor_x;
  bearing_y = idler_bearing_y - motor_y;
  bearing_z = idler_bearing_z - motor_z;

  offset_z  = hotend_clamp_height/2+0.5;

  screw_x   = idler_screw_x - motor_x;
  screw_z   = idler_screw_z - motor_z;

  arm_length_above_motor = 0;
  arm_thickness = idler_bearing_height+wall_thickness*3;
  arm_depth     = hotend_clamp_height;
  arm_length    = motor_side+hotend_clamped_height+arm_length_above_motor;
  arm_length    = motor_side;
  hinge_gap     = 1;
  arm_x = hotend_clamp_removable_width;
  arm_y = (motor_side/2 + arm_depth/2 + hinge_gap)*front;
  arm_z = -hotend_clamped_height/2+arm_length_above_motor/2;
  arm_z = 0;

  bearing_clearance = .5;
  arm_side_thickness = arm_thickness/2 - idler_bearing_height/2 - bearing_clearance;

  module body() {
    hull() {
      translate([bearing_x,0,0]) {
        translate([0,bearing_y-idler_bearing_inner*.25,bearing_z]) {
          cube([idler_width,idler_bearing_inner,idler_bearing_inner+wall_thickness*2],center=true);
        }

        translate([0,bearing_y-idler_bearing_inner*.25,offset_z+arm_length/2-1]) {
          cube([idler_width,idler_bearing_inner,2],center=true);
        }

        translate([0,-motor_side/2+1,offset_z]) {
          cube([idler_width,2,motor_side],center=true);
        }
      }
    }
  }

  module holes() {
    translate([bearing_x,bearing_y,bearing_z]) {
      rotate([0,90,0]) rotate([0,0,22.5]) {
        hole(idler_bearing_inner-1,idler_width-1,8);
      }
      translate([0,idler_bearing_inner,0]) {
        cube([idler_width-1,idler_bearing_inner*2,idler_bearing_inner-1],center=true);
      }
      rotate([0,90,0]) rotate([0,0,22.5]) {
        hole(idler_bearing_outer+4, idler_bearing_height+1, 8);
      }
    }

    hull() {
      for(side=[top,bottom]) {
        translate([screw_x,0,screw_z+0.75*side]) {
          rotate([90,0,0]) rotate([0,0,22.5]) {
            hole(idler_screw_diam,100,8);
          }
        }
      }
    }
  }

  color("LightGreen") difference() {
    body();
    holes();

    % translate([bearing_x,bearing_y,bearing_z]) {
      rotate([0,90,0]) {
        idler_bearing();
      }
    }
  }
}

module assembly() {
  translate([motor_x,motor_y,motor_z]) {
    rotate([0,90,0]) {
      % motor();
    }
  }

  carriage();

  //translate([hotend_x-0.05,hotend_y,hotend_z]) {
  translate([motor_x-0.05,motor_y,motor_z]) {
    hotend_clamp();
  }

  translate([0,0.05,0]) {
    belt_clamp();
  }

  % translate([hotend_x,motor_y,motor_z]) {
    rotate([0,90,0]) {
      hole(hobbed_effective_diam,hobbed_depth,36);
    }
  }

  translate([motor_x,motor_y+0.05,motor_z]) {
    idler_arm();
  }

  translate([hotend_x,hotend_y,hotend_z]) {
    % hotend();
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

assembly();
