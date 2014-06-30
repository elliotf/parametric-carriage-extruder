include <util.scad>
include <config.scad>
include <gears.scad>
include <positions.scad>

total_depth = mount_plate_thickness + motor_len + 1;
total_width = motor_side + motor_side*1.4;
total_width = motor_side/2 + gear_dist + hotend_mount_screw_hole_spacing + filament_x + hotend_mount_screw_nut/2 + min_material_thickness;
total_width = motor_side/2 + -motor_x + hotend_mount_screw_hole_spacing + filament_x + hotend_mount_screw_nut/2 + min_material_thickness;
total_height = motor_side + bottom_thickness;

idler_width     = idler_bearing_height+14;
idler_thickness = idler_bearing_inner+3+1;
idler_shaft_diam = idler_bearing_inner;
idler_shaft_length = idler_width*2;
idler_x = filament_x + idler_bearing_outer/2 + filament_diam/2;

idler_screw_spacing = (idler_width - idler_bearing_height - 2);

idler_crevice_width = idler_thickness + .5;
idler_crevice_length = total_depth - (filament_y - idler_width/2) + 2;
idler_crevice_depth = 2.5;
idler_crevice_depth = ext_shaft_hotend_dist -bearing_outer/2;
idler_crevice_x = idler_x - .25;
idler_crevice_y = total_depth - idler_crevice_length / 2;
idler_crevice_z = body_bottom_pos+bottom_thickness+idler_crevice_depth/2;

idler_lower_half = ext_shaft_hotend_dist;
idler_upper_half = idler_screw_from_shaft+idler_screw_diam/2+3;
idler_thumb_lever_thickness = 3;
idler_thumb_lever_length = 6;

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
  //% translate([filament_x,filament_y,body_bottom_pos-hotend_length/2+hotend_mount_hole_depth]) cylinder(r=hotend_diam/2,h=hotend_length,center=true);

  translate([idler_x,filament_y,0.1]) {
    //idler();
  }
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
    rotate([90,0,0])
      hole(ext_shaft_opening,main_body_depth+1,32);

    translate([main_body_width_idler_side/2+1,0,0])
      cube([main_body_width_idler_side+2,main_body_depth+1,ext_shaft_opening],center=true);
  }

  // bearings
  translate([0,gear_side_bearing_y,0]) {
    rotate([90,0,0])
      hole(bearing_outer,bearing_height,64);
  }
  translate([0,total_depth,0]) {
    rotate([90,0,0]) rotate([0,0,11.25])
      hole(bearing_outer,(total_depth-carriage_side_bearing_y)*2+bearing_height,16);
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
}

module material_savings() {
  translate([bearing_outer/2+8,0,0]) rotate([0,0,-40]) {
    // right front
    translate([total_depth,0,body_bottom_pos+bottom_thickness/2])
      cube([total_depth*2,total_depth*3,total_depth],center=true);

    // right front top
    translate([0,0,body_bottom_pos+bottom_thickness]) rotate([0,-45,0]) translate([bottom_thickness-0.5,0,0])
      cube([bottom_thickness*2,total_depth*3,bottom_thickness*1.25],center=true);

    // right front bottom
    translate([0,0,body_bottom_pos]) rotate([0,45,0]) translate([bottom_thickness-0.5,0,0])
      cube([bottom_thickness*2,total_depth*3,bottom_thickness*1.25],center=true);
  }

  translate([motor_x-motor_side/2,mount_plate_thickness,0]) rotate([0,0,-40]) {
    // left rear
    translate([-total_depth,0,body_bottom_pos+bottom_thickness/2])
      cube([total_depth*2,total_depth*3,total_depth],center=true);

    /*
    // right rear top
    translate([0,0,body_bottom_pos+bottom_thickness]) rotate([0,45,0]) translate([-total_depth+1,0,0])
      cube([total_depth*2,total_depth*3,bottom_thickness*1.25],center=true);
      */

    // right rear bottom
    translate([0,0,body_bottom_pos]) rotate([0,-45,0]) translate([-bottom_thickness+1,0,0])
      cube([bottom_thickness*2,total_depth*3,bottom_thickness*1.25],center=true);
  }

  // left front bottom rounded
  translate([motor_x-motor_side/2,0,body_bottom_pos+bottom_thickness/2]) rotate([0,-45,0])
    translate([-bottom_thickness,0,0])
      cube([bottom_thickness*2,total_depth*3,bottom_thickness*2],center=true);

  // left front top rounded
  translate([motor_x-motor_side/2,0,body_bottom_pos+bottom_thickness+motor_side]) rotate([0,45,0])
    translate([-bottom_thickness+2,0,0])
      cube([bottom_thickness*2,total_depth*3,bottom_thickness*2],center=true);
}

module idler_bearing() {
  difference() {
    cylinder(r=idler_bearing_outer/2,h=idler_bearing_height,center=true);
    cylinder(r=idler_bearing_inner/2,h=idler_bearing_height*2,center=true);
  }
}

module idler() {
  difference() {
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
      // idler bearing
      % rotate([90,0,0]) idler_bearing();
    }
  }
}

module bridges(){
  bridge_thickness = extrusion_height;

  // gear support bearing
  translate([main_body_x,gear_side_bearing_y+bearing_height/2-bridge_thickness/2,0])
    cube([main_body_width-0.5,bridge_thickness,bearing_outer+1],center=true);
  gear_bearing_support = bearing_height/2+gear_side_bearing_y;
  for(side=[top,bottom]) {
    translate([1,gear_bearing_support/2,side*(ext_shaft_opening/2-0.5)])
      cube([bearing_outer-2.5,gear_bearing_support,extrusion_width],center=true);
  }

  // carriage mounting hole diameter drop
  translate([filament_x,total_depth-carriage_hole_support_thickness,body_bottom_pos+bottom_thickness/2]) {
    for (side=[-1,1]) {
      translate([side*carriage_hole_spacing/2,0,0])
        cube([carriage_hole_large_diam+0.5,bridge_thickness,carriage_hole_large_diam+0.5],center=true);
    }
  }
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
