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
      cylinder(r=hobbed_outer_diam/2,h=hobbed_depth,center=true,$fn=36);
      rotate_extrude() {
        translate([hobbed_outer_diam/2+.9,0,0])
          circle(r=3/2,$fn=16);
      }
    }
    cylinder(r=hobbed_effective_diam/2,h=hobbed_depth-1,center=true,$fn=36);
  }

  // filament
  % translate([filament_x,filament_y,0]) cylinder(r=3/2,h=60,$fn=16,center=true);

  // hotend
  % translate([filament_x,filament_y,hotend_z-hotend_length/2]) {
    //cylinder(r=hotend_diam/2,h=hotend_length,center=true);
  }

  % for (side=[left,right]) {
    translate([filament_x+carriage_hole_spacing/2*side,main_body_depth,carriage_hole_z])
      rotate([90,0,0])
        hole(3,30,8);
  }

  //translate([idler_x,filament_y,0.1]) {
    //idler();
  //}
}

module bearing() {
  difference() {
    cylinder(r=bearing_outer/2,h=bearing_height,center=true);
    cylinder(r=bearing_inner/2,h=bearing_height+0.05,center=true);
  }
}

module gear_assembly() {
  translate([0,-2.5,0]) rotate([90,0,0]) large_gear();

  translate([-1 * gear_dist,-2,0]) {
    rotate([90,0,0]) small_gear();
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

    // hotend mount

    // idler groove
    bottom_plate_height = hotend_height_above_groove + min_material_thickness*2;
    translate([filament_x,main_body_y,bottom*(main_body_height_below_shaft)]) {
      translate([0,0,-bottom_plate_height/2+min_material_thickness])
        cube([total_width,main_body_depth,bottom_plate_height],center=true);
    }
  }

  difference() {
    body();
    extruder_body_holes();
  }

  color("lightblue") bridges();
}

module extruder_body_holes() {
  // main shaft
  translate([0,main_body_depth/2,0]) {
    rotate([90,0,0]) rotate([0,0,11.25])
      hole(ext_shaft_opening,main_body_depth+1,16);

    translate([main_body_width_idler_side/2+1,0,0])
      cube([main_body_width_idler_side+2,main_body_depth+1,ext_shaft_opening],center=true);
  }

  // idler bearing access
  translate([filament_x+idler_bearing_outer*.375,main_body_depth,0]) {
    rotate([90,0,0]) rotate([0,0,22.5])
      hole(idler_bearing_outer, motor_len*2,8);
  }

  // bearings
  translate([0,gear_side_bearing_y,0]) {
    rotate([90,0,0]) rotate([0,0,11.25])
      hole(bearing_outer,bearing_height,16);
  }
  translate([0,main_body_depth,0]) {
    rotate([90,0,0]) rotate([0,0,11.25])
      hole(bearing_outer,(main_body_depth-carriage_side_bearing_y)*2+bearing_height,16);
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
      translate([-filament_diam-min_material_thickness,idler_screw_spacing/2*side,0]) {
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
  translate([filament_x,filament_y,hotend_z-hotend_height_above_groove]) {
    intersection() {
      rotate([0,0,22.5])
        hole(hotend_diam,hotend_height_above_groove*2,8);
      translate([0,hotend_diam*.825,0])
        cube([hotend_diam+1,hotend_diam,hotend_height_above_groove*2+1],center=true);
    }
    rotate([0,0,11.25/2])
      hole(hotend_diam,hotend_height_above_groove*2,32);
  }
  translate([filament_x,filament_y,hotend_z+min_material_thickness]) {
    for (side=[left,right]) {
      for (end=[front,rear]) {
        rotate([0,0,30*end])
          translate([12.5*side,0,0]) {
            rotate([0,0,90*end]) {
              translate([0,0,-5])
                hole(3,10,6);
              translate([0,0,-m3_nut_thickness/2]) {
                hole(m3_nut_diam,m3_nut_thickness,6);
                rotate([0,0,-120*end]) {
                  translate([10*side,0,0])
                  cube([20,m3_nut_diam,m3_nut_thickness],center=true);
                }
              }
            }
          }
      }
    }
  }
}

module idler_bearing() {
  difference() {
    cylinder(r=idler_bearing_outer/2,h=idler_bearing_height,center=true);
    cylinder(r=idler_bearing_inner/2,h=idler_bearing_height*2,center=true);
  }
}

module idler() {
  % difference() {
    union() {
      translate([0,0,-idler_lower_half/2])
        cube([idler_thickness,idler_width,idler_lower_half],center=true);

      translate([0,0,idler_upper_half/2])
        cube([idler_thickness,idler_width,idler_upper_half+0.05],center=true);

      translate([idler_thickness/2-idler_thumb_lever_thickness/2,0,idler_upper_half+idler_thumb_lever_length/2])
        cube([idler_thumb_lever_thickness,idler_width,idler_thumb_lever_length+0.05],center=true);
    }

    // holes for screws
    for(side=[-1,1]) {
      translate([(idler_thickness)/2,idler_screw_spacing/2*side,idler_screw_from_shaft]) {
        hull() {
          rotate([0,-85,0]) translate([0,0,(idler_thickness)/2+1]) rotate([0,0,90])
            hole(idler_screw_diam,idler_thickness+2.05,6);
          rotate([0,-95,0]) translate([0,0,(idler_thickness)/2+1]) rotate([0,0,90])
            hole(idler_screw_diam,idler_thickness+2.05,6);
        }
      }
    }

    // hole for bearing
    cube([idler_bearing_outer,idler_bearing_height+0.5,idler_bearing_outer+2],center=true);
    translate([-idler_thickness/2,0,0]) rotate([0,0,22.5]) cylinder(r=(idler_bearing_height+0.5)*da8,$fn=8,h=100,center=true);

    translate([-0.5,0,0]) {
      rotate([90,0,0]) rotate([0,0,22.5]) cylinder(r=da8*(idler_shaft_diam),h=idler_shaft_length,$fn=8,center=true);
    }
  }
  % rotate([90,0,0]) idler_bearing();
}

module bridges(){
  bridge_thickness = extrusion_height;

  // gear support bearing
  translate([main_body_x,gear_side_bearing_y+bearing_height/2-bridge_thickness/2,0])
    cube([main_body_width-0.5,bridge_thickness,bearing_outer+1],center=true);
  gear_bearing_support = bearing_height/2+gear_side_bearing_y-extrusion_height;
  translate([0,gear_bearing_support/2,0]) {
    difference() {
      union() {
        rotate([90,0,0]) rotate([0,0,11.25])
          hole(ext_shaft_opening-.5,gear_bearing_support,16);
        translate([bearing_outer/4-1,0,0])
          cube([bearing_outer/2-.5,gear_bearing_support,ext_shaft_opening-.5],center=true);
      }
      rotate([90,0,0]) rotate([0,0,11.25])
        hole(ext_shaft_opening-1.3,gear_bearing_support+1,16);
      translate([bearing_outer/4-1,0,0])
        cube([bearing_outer/2-1.3,gear_bearing_support+1,ext_shaft_opening-1.3],center=true);
    }
  }
  translate([0,gear_bearing_support/2-0.1,0]) {
    rotate([90,0,0]) difference() {
      hole(bearing_outer*.8,gear_bearing_support-0.2,16);
      hole(bearing_outer*.8-0.5,gear_bearing_support,16);
    }
  }

  // carriage mounting hole diameter drop
  /*
  translate([filament_x,total_depth-carriage_hole_support_thickness,body_bottom_pos+bottom_thickness/2]) {
    for (side=[-1,1]) {
      translate([side*carriage_hole_spacing/2,0,0])
        cube([carriage_hole_large_diam+0.5,bridge_thickness,carriage_hole_large_diam+0.5],center=true);
    }
  }
  */
}

module full_assembly() {
  assembly();

  translate([motor_x,-10,motor_z]) {
    rotate([-90,0,0]) small_gear();
  }

  translate([0,-3,0]) {
    rotate([-90,0,0]) rotate([180,0,0]) rotate([0,0,185]) large_gear();
  }
}

//full_assembly();
assembly();
