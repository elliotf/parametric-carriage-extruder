// Get rid of hotend mount plate recess, or make it more shallow? -- This would let the mount plate screw holes be more sturdy
// hotend recess diameter too large (somehow 16*da8 comes out more like 17; but it might be a good thing -- turns out it was a human problem)
// tricky bridge near filament broken again; need to make sure lone bridge is a multiple of filament width
// provide bridging for the carriage mount holes (going from larger to smaller diameter)
// hobbed bolt is in the filament path too much (was 0.75 into the filament, going to 0.5)

include <util.scad>
include <config.scad>
include <gears.scad>
include <positions.scad>

total_depth = mount_plate_thickness + motor_len + 1;
total_width = motor_side + motor_side*1.4;
total_width = motor_side/2 + gear_dist + hotend_mount_screw_hole_spacing + filament_x + hotend_mount_screw_nut/2 + min_material_thickness;
total_width = motor_side/2 + -motor_x + hotend_mount_screw_hole_spacing + filament_x + hotend_mount_screw_nut/2 + min_material_thickness;
total_height = motor_side + bottom_thickness;

filament_y = total_depth - filament_from_carriage;

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
  //gear_assembly();
  translate([0,0,0]) extruder_body();

  // motor
  % position_motor() rotate([90,0,0]) motor();

  // extruder shaft
  % translate([0,ext_shaft_length/2-15,0]) rotate([90,0,0]) rotate([0,0,22.5])
    cylinder(r=ext_shaft_diam/2,h=ext_shaft_length,center=true);

  // hobbed whatnot
  % translate([0,filament_y,0]) rotate([90,0,0]) rotate([0,0,22.5])
    cylinder(r=hobbed_diam/2+0.05,h=hobbed_width,center=true);

  // filament
  % translate([filament_x,filament_y,0]) cylinder(r=3/2,h=60,$fn=8,center=true);

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

module extruder_body_base() {
  // motor plate
  translate([0,-mount_plate_thickness/2,0]) hull() {
    position_motor()
      cube([motor_side,mount_plate_thickness,motor_side],center=true);

    translate([-idler_thickness,motor_y,-bottom_thickness/2])
      cube([main_body_width,mount_plate_thickness,main_body_height],center=true);
  }

  // main block
  hull() {
    translate([main_body_x,total_depth/2,main_body_z])
      cube([main_body_width,total_depth,main_body_height],center=true);

    translate([motor_x+motor_side/2+1,total_depth-2.5,main_body_z])
      cube([2,5,main_body_height],center=true);
  }

  // material for idler groove/crevice
  translate([idler_x,total_depth/2,body_bottom_pos+bottom_thickness+idler_crevice_depth/2])
    cube([idler_thickness*2+5,total_depth,idler_crevice_depth],center=true);

  // bottom
  translate([0,total_depth/2,body_bottom_pos+bottom_thickness/2]) {
    hull() {
      translate([main_body_x,0,0])
        cube([main_body_width+idler_thickness*2,total_depth,bottom_thickness],center=true);
      translate([idler_x,0,0])
        cube([idler_thickness*2+5,total_depth,bottom_thickness],center=true);
    }
  }
}

module extruder_body() {
  difference() {
    extruder_body_base();
    extruder_body_holes();
  }
  color("lightblue") bridges();
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
    translate([-idler_thickness/2,0,0]) rotate([0,0,22.5])
      cylinder(r=(idler_bearing_height+0.5)*da8,$fn=8,h=100,center=true);

    translate([-0.5,0,0]) {
      rotate([90,0,0]) rotate([0,0,22.5]) cylinder(r=da8*(idler_shaft_diam),h=idler_shaft_length,$fn=8,center=true);
      // idler bearing
      % rotate([90,0,0]) idler_bearing();
    }
  }
}

module extruder_body_holes() {
  // shaft hole
  translate([0,total_depth/2,0]) rotate([90,0,0]) rotate([0,0,11.25])
    hole(ext_shaft_opening,total_depth);
  translate([bearing_outer/2,motor_len/2,0])
    cube([bearing_outer,motor_len*2,ext_shaft_opening],center=true);

  // filament path
  translate([filament_x,filament_y,0]) rotate([0,0,22.5])
    hole(filament_diam+1,50,8);

  translate([0,gear_side_bearing_y,0]) {
    // gear-side bearing
    rotate([90,0,0]) rotate([0,0,11.25]) hole(bearing_outer,bearing_height);

    % translate([0,0,0]) rotate([90,0,0]) bearing();
  }

  // carriage-side filament support bearing
  translate([0,total_depth,0]) rotate([90,0,0])
    hole(bearing_outer,(filament_from_carriage-hobbed_width/2)*2);

  // idler crevice
  translate([idler_crevice_x,total_depth,idler_crevice_z])
    cube([idler_crevice_width,idler_crevice_length*2,idler_crevice_depth+0.05],center=true);

  // idler screw holes for idler screws
  translate([filament_x,filament_y,idler_screw_from_shaft]) {
    for (side=[-1,1]) {
      translate([0,idler_screw_spacing/2*side,0]) rotate([0,90,0])
        hole(idler_screw_diam,45,6);
    }
  }

  // captive nut recesses for idler screws
  translate([-2.5,filament_y,idler_screw_from_shaft]) {
    for (side=[-1,1]) {
      translate([0,idler_screw_spacing/2*side,0]) rotate([0,90,0])
        hole(idler_screw_nut_diam,idler_screw_nut_thickness+spacer*1.5,6);
      translate([0,idler_screw_spacing/2*side,5])
        cube([idler_screw_nut_thickness+spacer*1.5,idler_screw_nut_diam,10],center=true);
    }
  }

  // motor holes
  position_motor() {
    translate([0,-mount_plate_thickness/2,0]) rotate([90,0,0]){
      // motor shoulder
      hole(motor_shoulder_diam+1,mount_plate_thickness*2);

      // motor mounting holes
      for (x=[-1,1]) {
        for (y=[-1,1]) {
          translate([motor_hole_spacing/2*x,motor_hole_spacing/2*y,0]) rotate([0,0,22.5])
            hole(m3_diam+0.1,mount_plate_thickness+1,8);
        }
      }

      translate([-motor_side/2,0,0])
        cube([motor_side+motor_hole_spacing/2,motor_side*3,mount_plate_thickness+1],center=true);
    }
  }

  // hotend
  translate([filament_x,filament_y,body_bottom_pos]) {
    // hotend mount hole
    translate([0,0,hotend_mount_height]) rotate([0,0,22.5]) cylinder(r=da8*hotend_diam+0.05,h=hotend_mount_hole_depth*2,$fn=8,center=true);

    for (side = [0, 1]) {
      for (a = [60:60:159]) {
        rotate([0, 0, a+side*180])
          translate([0, 12.5, 5])
            hole(m3_diam, 12, 8);
      }
    }
  }

  // filament guide retainer top recess
  translate([filament_x,filament_y,main_body_z+main_body_height/2]) rotate([0,0,22.5])
    cylinder(r=6.25/2,$fn=8,h=15,center=true);

  // carriage mounting holes
  opening_thickness = 4;
  translate([filament_x,total_depth,body_bottom_pos+bottom_thickness/2]) {
    for (side=[-1,1]) {
      translate([side*carriage_hole_spacing/2,-carriage_hole_support_thickness-opening_thickness/2-extrusion_height/2,0]) {
        rotate([90,0,0]) rotate([0,0,90])
          hole(m3_nut_diam,opening_thickness,6);
        translate([0,0,-4])
          cube([m3_nut_diam,opening_thickness,6],center=true);
      }

      translate([side*carriage_hole_spacing/2,-total_depth/2,0]) rotate([90,0,0])
        hole(carriage_hole_small_diam,total_depth+2,10);
    }
  }
}

module bridges(){
  bridge_thickness = extrusion_height;

  // gear support bearing
  translate([main_body_x,gear_side_bearing_y+bearing_height/2+bridge_thickness/2,0])
    cube([main_body_width,bridge_thickness,bearing_outer+1],center=true);

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

  translate([motor_x,-3.5,motor_z]) {
    //rotate([90,0,0]) small_gear();
  }

  translate([0,-3,0]) {
    //rotate([-90,0,0]) rotate([180,0,0]) rotate([0,0,45]) large_gear();
  }
}

full_assembly();
//assembly();
