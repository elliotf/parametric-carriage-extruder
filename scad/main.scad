/*

TODO:
  carriage screw holes
  calibration piece
    m3 holes/nuts in different orientations ?

MAYBE:
  fan mount holes?
  more bracing for idler retainer?

*/

include <util.scad>
include <config.scad>
include <gears.scad>
include <positions.scad>

module motor() {
  translate([0,0,-motor_len/2]) {
    cube([motor_side,motor_side,motor_len],center=true);

    // shaft
    translate([0,0,motor_len/2+motor_shaft_len/2+motor_shoulder_height])
      cylinder(r=5/2,h=motor_shaft_len,center=true);

    // shoulder
    translate([0,0,motor_len/2+motor_shoulder_height/2])
      cylinder(r=motor_shoulder_diam/2,h=motor_shoulder_height,center=true); // shoulder

    // short shaft
    translate([0,0,-motor_len/2-motor_short_shaft_len/2])
      cylinder(r=5/2,h=motor_short_shaft_len,center=true);
  }
}

module assembly() {
  translate([0,0,0]) extruder_body();

  // motor
  % position_motor() rotate([90,0,0]) motor();

  // extruder shaft
  % translate([0,ext_shaft_length/2-15,0]) rotate([90,0,0]) rotate([0,0,22.5])
    cylinder(r=ext_shaft_diam/2,h=ext_shaft_length,center=true);

  // hobbed whatnot
  % translate([0,filament_y,0]) rotate([90,0,0]) {
    difference() {
      cylinder(r=hobbed_outer_diam/2,h=hobbed_depth,center=true,$fn=18);
      rotate_extrude() {
        translate([hobbed_outer_diam/2+.9,0,0])
          circle(r=3/2,$fn=16);
      }
    }
    cylinder(r=hobbed_effective_diam/2,h=hobbed_depth-1,center=true,$fn=18);
  }

  // filament
  % translate([filament_x,filament_y,0]) cylinder(r=3/2,h=60,$fn=16,center=true);

  // hotend
  % translate([filament_x,filament_y,hotend_z-hotend_length/2]) {
    //cylinder(r=hotend_diam/2,h=hotend_length,center=true);
  }

  translate([filament_x,filament_y,-main_body_height_below_shaft-bottom_plate_height-hotend_retainer_height-0.1]) {
    hotend_retainer();
  }

  translate([idler_x,idler_y,0.05]) {
    idler();
    idler_shaft();
  }
}

module bearing() {
  difference() {
    cylinder(r=bearing_outer/2,h=bearing_height,center=true);
    cylinder(r=bearing_inner/2,h=bearing_height+0.05,center=true);
  }
}

module gear_assembly() {
  translate([0,gear_side_bearing_y-bearing_height/2-.5,0])
    rotate([90,0,0])
      rotate([0,0,125])
        large_gear();

  translate([motor_x,-3,motor_z]) {
    rotate([90,0,0])
      small_gear();
  }
}

module extruder_body() {
  module body() {
    translate([main_body_x,main_body_y,main_body_z])
      cube([main_body_width,main_body_depth,main_body_height],center=true);

    // mounting plate
    hull() {
      translate([0,mount_plate_thickness/2,0]) {
        translate([main_body_x,0,main_body_z])
          cube([main_body_width,mount_plate_thickness,main_body_height],center=true);

      }

      position_motor() {
        for(side=[top,bottom]) {
          translate([motor_hole_spacing/2,-mount_plate_thickness/2,motor_hole_spacing/2*side]) {
            rotate([90,0,0])
              hole(motor_screw_diam+6,mount_plate_thickness,16);
          }
        }
      }
    }

    // hotend plate
    translate([filament_x,main_body_y,bottom_plate_z]) {
      cube([total_width,main_body_depth,bottom_plate_height],center=true);
    }

    // idler groove
    translate([idler_retainer_x,main_body_depth/2,-main_body_height_below_shaft]) {
      cube([idler_retainer_width,main_body_depth,idler_retainer_height*2],center=true);
    }

    // carriage brace
    brace_depth = main_body_depth - filament_y - hotend_diam/2 - 0.5;
    brace_angle_length = sqrt(pow(brace_depth,2)*2);
    translate([filament_x,main_body_depth-brace_depth/2,bottom_plate_z]) {
      intersection() {
        scale([.66,1,1])
        hull() {
          translate([0,brace_depth/2,0])
            rotate([90,0,0])
              hole(bottom_plate_height+brace_depth*2-4,1,64);

          translate([0,-brace_depth/2+.5,0])
            rotate([90,0,0]) rotate([0,0,11.25/2])
              hole(bottom_plate_height,1,32);
        }
        translate([0,0,-brace_depth]) {
          cube([brace_depth*2,brace_depth,brace_depth*2],center=true);
        }
      }
    }

    % for (side=[left,right]) {
      translate([filament_x+carriage_hole_spacing/2*side,main_body_depth,carriage_hole_z])
        rotate([90,0,0]) {
          hole(carriage_hole_diam,carriage_hole_depth*2,16);
        }
    }
  }

  difference() {
    body();
    extruder_body_holes();
  }

  % translate([0,carriage_side_bearing_y,0]) {
    rotate([90,0,0]) {
      cylinder(r=bearing_outer/2,h=bearing_height,center=true);
    }
  }

  color("lightblue") bridges();
}

module sloped_bearing_hole() {
  rotate([90,0,0]) rotate([0,0,11.25]) {
    hole(bearing_outer, bearing_height, 16);
  }
}

module extruder_body_holes() {
  // main shaft
  translate([0,main_body_depth/2,0]) {
    rotate([90,0,0]) rotate([0,0,11.25])
      hole(ext_shaft_opening,main_body_depth+1,16);

    translate([main_body_width_idler_side/2+1,0,0])
      cube([main_body_width_idler_side+2,main_body_depth+1,ext_shaft_opening],center=true);
  }


  // gear side bearing
  translate([0,gear_side_bearing_y,0]) {
    sloped_bearing_hole();
  }

  carriage_side_bearing_hole_depth = (main_body_depth-carriage_side_bearing_y)*2+bearing_height;
  translate([0,carriage_side_bearing_y,0]) {
    sloped_bearing_hole();
  }

  translate([0,main_body_depth,0]) {
    // carriage side bearing
    rotate([90,0,0]) rotate([0,0,11.25])
      hole(bearing_outer,carriage_side_bearing_hole_depth,16);

    // easier to insert carriage side bearing, can unscrew shaft while mounted
    translate([main_body_width_idler_side,0,main_body_height_above_shaft])
      cube([main_body_width_idler_side*2+bearing_outer,carriage_side_bearing_hole_depth-bearing_height*2,main_body_height_above_shaft*2],center=true);
  }


  // motor
  position_motor() {
    union() {
      for(side=[top,bottom])
        translate([motor_hole_spacing/2,-mount_plate_thickness/2,motor_hole_spacing/2*side])
          rotate([90,0,0])
            hole(motor_screw_diam,mount_plate_thickness+1,8);

      translate([0,-mount_plate_thickness/2,0])
        rotate([90,0,0])
          hole(motor_shoulder_diam+4,mount_plate_thickness+1,32);
    }
  }

  // filament
  translate([filament_x,filament_y,0]) rotate([0,0,22.5])
    hole(filament_opening_diam,1000,8);

  // idler tensioners
  translate([filament_x,filament_y,idler_screw_from_shaft]) {
    for (side=[left,right]) {
      translate([-filament_diam-min_material_thickness*3,idler_screw_spacing/2*side,0]) {
        // idler screws
        rotate([0,90,0]) rotate([0,0,22.5])
          hole(idler_screw_diam, main_body_width*2,8);

        // captive nuts
        rotate([0,90,0])
          hole(idler_screw_nut_diam, idler_screw_nut_thickness,6);
        translate([0,0,idler_screw_nut_diam/2])
          cube([idler_screw_nut_thickness,idler_screw_nut_diam,idler_screw_nut_diam],center=true);
      }
    }
  }

  // hotend
  translate([filament_x,filament_y,hotend_z-hotend_height_above_groove/2-0.05]) {
    intersection() {
      rotate([0,0,22.5])
        hole(hotend_diam,hotend_height_above_groove+.1,8);
      translate([0,hotend_diam*.825,0])
        cube([hotend_diam+1,hotend_diam,hotend_height_above_groove+2],center=true);
    }
    rotate([0,0,11.25/2])
      hole(hotend_diam,hotend_height_above_groove+.1,32);
  }

  // hotend mount holes, captive nuts
  translate([filament_x,filament_y,hotend_z+min_material_thickness]) {
    for (side=[left,right]) {
      for (end=[front,rear]) {
        rotate([0,0,30*end])
          translate([hotend_screw_spacing/2*side,0,0]) {
            rotate([0,0,end*-30-22.5*end])
              translate([0,0,-5])
                hole(hotend_screw_diam,10,8);
            rotate([0,0,90*end]) {
              translate([0,0,-hotend_nut_thickness/2]) {
                hole(hotend_nut_diam,hotend_nut_thickness,6);
                rotate([0,0,-120*end]) {
                  translate([10*side,0,0])
                  cube([20,hotend_nut_diam,hotend_nut_thickness],center=true);
                }
              }
            }
          }
      }
    }
  }

  // carriage mount holes
  for (side = [left,right]) {
    translate([filament_x+carriage_hole_spacing/2*side,main_body_depth,carriage_hole_z]) {
      rotate([90,0,0]) {
        hole(carriage_hole_diam,carriage_hole_depth*2,16);
      }

      translate([0,-carriage_hole_depth+m3_nut_thickness,0]) {
        translate([25*side,0,0]) {
          cube([50,m3_nut_thickness+0.1,m3_nut_diam+0.1],center=true);
        }

        rotate([90,0,0]) {
          hole(m3_nut_diam+0.1,m3_nut_thickness+0.1,6);
        }
      }
    }
  }
}

module hotend_retainer(groove_height=jhead_hotend_groove_height) {
  retainer_sides = hotend_screw_spacing + m3_diam + min_material_thickness*3;

  module position_screws() {
    for (side=[left,right]) {
      for (end=[front,rear]) {
        rotate([0,0,30*end]) {
          translate([hotend_screw_spacing/2*side,0,0]) {
            rotate([0,0,-30*end])
              child(0);
          }
        }
      }
    }
  }

  module body() {
    hull() {
      position_screws() {
        hole(m3_diam+0.1+min_material_thickness*5,hotend_groove_height,8);
      }
    }
  }

  module holes() {
    // groove hole for main shaft
    rotate([0,0,11.25])
      hole(hotend_groove_diam,hotend_groove_height+1,16);
    translate([0,retainer_sides*.6,0]) {
      cube([hotend_groove_diam,retainer_sides*1.2,hotend_groove_height+1],center=true);

      rotate([0,0,22.5])
        hole(retainer_sides*.75,hotend_groove_height+1,8);
    }

    difference = e3d_hotend_groove_height - groove_height + 0.1;
    // groove for jhead hotend
    translate([0,0,hotend_groove_height/2]) {
      rotate([0,0,11.25])
        hole(hotend_diam+0.1,difference*2,16);
      translate([0,retainer_sides*.6,0]) {
        cube([hotend_diam+0.1,retainer_sides*1.2,difference*2],center=true);

        rotate([0,0,22.5])
          hole(retainer_sides*.75,difference*2,8);
      }
    }

    rotate([0,0,11.25])
      hole(hotend_groove_diam,hotend_groove_height+1,16);

    // screw holes
    position_screws() {
      hole(m3_diam+0.1,hotend_groove_height*2,16);
    }
  }

  translate([0,0,hotend_groove_height/2]) {
    difference() {
      body();
      holes();
    }
  }
}

module idler_bearing() {
  difference() {
    cylinder(r=idler_bearing_outer/2,h=idler_bearing_height,center=true);
    cylinder(r=idler_bearing_inner/2,h=idler_bearing_height*2,center=true);
  }
}

module idler_shaft() {
  rotate([-90,0,0])
    rotate([0,0,22.5]) {
      hole(idler_shaft_diam,idler_shaft_length,8);
    }
}

module idler() {
  lower_half_length = main_body_height_below_shaft;
  upper_half_length = idler_screw_from_shaft + idler_screw_diam/2 + min_material_thickness*2 + 5;
  total_length = lower_half_length + upper_half_length;
  idler_shaft_opening = idler_bearing_inner + 0.2;

  module body() {
    translate([idler_offset_from_bearing,0,0]) {
      hull() {
        cube([idler_thickness,idler_width,idler_bearing_outer + min_material_thickness*2],center=true);

        translate([idler_thickness/2-.5,0,-lower_half_length+total_length/2]) {
            cube([1,idler_width,total_length],center=true);
        }
      }
    }
  }

  module holes() {
    // main bearing hole
    cube([idler_thickness+10,idler_bearing_height+0.5,idler_bearing_outer+1],center=true);

    // idler shaft hole
    rotate([90,0,0]) rotate([0,0,22.5])
      hole(idler_shaft_opening,idler_shaft_length+0.1,8);
    translate([-(idler_thickness/2+idler_bearing_inner/2),0,0])
      cube([idler_thickness+idler_shaft_opening,idler_shaft_length+0.1,idler_shaft_opening],center=true);

    // elongated idler screw holes
    for (side=[left,right]) {
      translate([idler_offset_from_bearing + idler_thickness/2,idler_screw_spacing/2*side,idler_screw_from_shaft]) {
        hull() {
          for (offset=[-15,15]) {
            rotate([0,-90+offset,0])
              translate([0,0,idler_thickness])
                hole(idler_screw_diam,idler_thickness*2,18);
          }
        }
      }
    }
  }

  difference() {
    body();
    holes();

    % rotate([90,0,0]) {
      difference() {
        hole(idler_bearing_outer,idler_bearing_height,32);
        hole(idler_bearing_inner,idler_bearing_height+1,16);
      }
    }
  }
}

module bridges(){
  bridge_thickness = extrusion_height;

  // gear support bearing
  translate([main_body_x,gear_side_bearing_y+bearing_height/2-bridge_thickness/2,0])
    cube([main_body_width-0.5,bridge_thickness,bearing_outer+1],center=true);
  gear_bearing_support = bearing_height/2+gear_side_bearing_y;
  translate([0,gear_bearing_support/2-0.1,0]) {
    rotate([90,0,0]) difference() {
      hole(bearing_outer-bearing_lip_width-1,gear_bearing_support-0.2,36);
      hole(bearing_outer-bearing_lip_width-min_material_thickness*3,gear_bearing_support,36);
    }
  }

  // carriage hole diameter change
  for (side = [left,right]) {
    translate([filament_x+carriage_hole_spacing/2*side,main_body_depth-carriage_hole_depth+m3_nut_thickness*1.5+extrusion_height-0.1,carriage_hole_z]) {
      cube([m3_nut_diam+0.2,extrusion_height,m3_nut_diam+0.2],center=true);
    }
  }
}

module full_assembly() {
  assembly();
  //gear_assembly();
}

full_assembly();
//assembly();
