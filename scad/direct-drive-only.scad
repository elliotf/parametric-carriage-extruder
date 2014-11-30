include <util.scad>
include <config.scad>
include <positions.scad>
//use     <main.scad>

module motor() {
  module body() {
    translate([0,0,-motor_len/2]) {
      //cube([motor_side,motor_side,motor_len],center=true);

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
  }

  module holes() {
    // mount holes
    for (side=[left,right]) {
      for(end=[top, bottom]) {
        translate([motor_hole_spacing/2*side,motor_hole_spacing/2*end,0]) {
          hole(3,motor_len*3,12);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module hobbed_pulley() {
  module body() {
    translate([0,0,hobbed_pulley_height/2-hob_dist_from_end]) {
      hole(hobbed_pulley_diam,hobbed_pulley_height,36);
    }
  }

  module holes() {
    rotate_extrude() {
      translate([hobbed_pulley_diam/2+hob_width/2-(hob_depth),0,0]) {
        circle(hob_width/2,$fn=36);
      }
    }

    hole(motor_shaft_diam,motor_len/2,36);
  }

  difference() {
    body();
    holes();
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
        cube([idler_width+1,idler_bearing_inner+1,idler_bearing_outer+wall_thickness],center=true);
      }

      translate([0,-motor_side/2+1.2,hotend_clamp_height/2+0.5]) {
        cube([idler_width+1,2.5,motor_side+1],center=true);
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





motor_screw_head_diam = 6;
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

hotend_clearance = 0.15;
hotend_pos_y      = -motor_hole_spacing/2-motor_screw_head_diam/2;

idler_screw_pos_y = motor_side/2-wall_thickness-m3_nut_diam/2;
idler_screw_pos_z = filament_pos_z - filament_opening/2 - extrusion_height - m3_diam/2;
idler_washer_thickness = 1;

echo("Idler screw length at least ", idler_shaft_support*2 + 1 + idler_bearing_height + 3);

module direct_drive() {
  rounded_radius = motor_side/2 - motor_hole_spacing/2;
  resolution     = 64;
  block_height = idler_pos_z + idler_bearing_height/2 + idler_washer_thickness + idler_shaft_support;
  block_height = idler_pos_z + idler_bearing_height/2;

  module body() {
    hotend_rounded_corner_radius = wall_thickness;
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
    // flat for captive idler nut
    translate([hotend_diam/2,motor_side/2,plate_thickness/2+block_height/2+0.025]) {
      //cube([12,motor_side,block_height-plate_thickness+0.05],center=true);
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
    intersection() {
      hull() {
        for(x=[0,-.5]) {
          translate([x,0,0]) {
            rotate([0,0,22.5]) {
              hole(motor_shoulder_diam+0.5,motor_shoulder_height*2+0.05,resolution);
            }

          }
        }
        hole(2,(motor_shoulder_height+motor_shoulder_diam/2+2)*2,resolution);
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
        /*
        hull() {
          hole(idler_bearing_outer+1,idler_bearing_height+idler_washer_thickness*2,resolution);
          translate([-idler_bearing_outer/2,0,0]) {
            cube([idler_bearing_outer,idler_bearing_outer+1,idler_bearing_height+idler_washer_thickness*2],center=true);
          }
        }
        */
        hole(idler_bearing_outer,idler_bearing_height+idler_washer_thickness*2,resolution);
        /*
        rotate_extrude($fn=resolution) {
          translate([idler_bearing_inner/2+1,idler_washer_thickness/2]) {
            //square([.5,idler_bearing_height+idler_washer_thickness],center=true);
          }
          hull() {
            translate([idler_bearing_inner/2+2,idler_washer_thickness/2]) {
              square([1,idler_bearing_height+idler_washer_thickness],center=true);
            }
            translate([idler_bearing_outer/2+1.5,idler_washer_thickness/2-0.5]) {
              //square([0.05,idler_bearing_height+idler_washer_thickness+1],center=true);
            }
            translate([idler_bearing_outer/2,idler_washer_thickness/2-0.5]) {
              square([2,idler_bearing_height+idler_washer_thickness+1],center=true);
            }
          }
        }
        */
      }

      // idler nut
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

    // hotend
    hotend_res = resolution*2;
    above_height = hotend_height_above_groove+hotend_clearance*2;
    translate([filament_pos_x,hotend_pos_y,filament_pos_z]) {
      rotate([-90,0,0]) {
        //% hotend();
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
            rotate_extrude($fn=resolution) {
              translate([hotend_groove_diam/2 + 6,0]) {
                square([2,3],center=true);
              }
            }
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

    /*
    translate([idler_pos_x,0,idler_pos_z]) { 
      difference() {
        hole(idler_bearing_inner+extrusion_width*3,idler_bearing_height+4,resolution);
        hole(idler_bearing_inner,idler_bearing_height+4.05,resolution);
      }
    }
    */
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
