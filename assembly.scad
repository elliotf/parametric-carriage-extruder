da6 = 1 / cos(180 / 6) / 2;
da8 = 1 / cos(180 / 8) / 2;

// motor mount plate too thin for 8mm screws (thickness is 3, looks to be short by <1mm)
// Get rid of hotend mount plate recess, or make it more shallow? -- This would let the mount plate screw holes be more sturdy
// hotend recess diameter too large (somehow 16*da8 comes out more like 17; but it might be a good thing -- turns out it was a human problem)
// tricky bridge near filament broken again; need to make sure lone bridge is a multiple of filament width
// provide bridging for the carriage mount holes (going from larger to smaller diameter)
// hobbed bolt is in the filament path too much (was 0.75 into the filament, going to 0.5)
// extruder hobbed bolt and rear motor shaft bumping into carriage; extruder is not deep enough or not high enough

include <gears.scad>
include <inc/nema.scad>

// 608
bearing_height = 7;
bearing_outer  = 22;
bearing_inner  = 8;

// 625
bearing_height = 5;
bearing_outer  = 16;
bearing_inner  = 5;

// 626
bearing_height = 6;
bearing_outer  = 19;
bearing_inner  = 6;

filament_diam = 3;

ext_shaft_length  = 60;
ext_shaft_diam    = 5; // m5 threaded rod
ext_shaft_diam    = 6; // m6 bolt
ext_shaft_opening = bearing_outer - 3;
ext_shaft_opening = ext_shaft_diam + 3;

carriage_hole_spacing = 30;
carriage_hole_small_diam    = 3.2;
carriage_hole_large_diam    = 6.2;
carriage_hole_support_thickness = 8;
carriage_clearance = 25;

motor_screw_spacing = 26;

hotend_length = 63;
hotend_diam   = 16;
hotend_mount_hole_depth = 5;
hotend_mount_screw_hole_spacing = 24;
hotend_mount_screw_diam = 4;
hotend_mount_length = 37.5*2;
hotend_mount_width = 28;

mount_plate_thickness = 3;
bottom_thickness = 4;
body_bottom_pos = -motor_side/2-bottom_thickness;
total_depth = mount_plate_thickness + motor_height + 1;
total_width = motor_side + motor_side*1.4;
total_height = motor_side + bottom_thickness;

filament_from_carriage = hotend_diam / 2 + 11; // make sure the hotend can clear the carriage
filament_x = ext_shaft_diam/2 + filament_diam/2 - .5;
filament_y = total_depth - filament_from_carriage;

//625
idler_bearing_height = bearing_height;
idler_bearing_outer  = bearing_outer;
idler_bearing_inner  = bearing_inner;

// 608
idler_bearing_height = 7;
idler_bearing_outer  = 22;
idler_bearing_inner  = 8;

//626
idler_bearing_height = 6;
idler_bearing_outer  = 19;
idler_bearing_inner  = 6;

idler_width     = idler_bearing_height+14;
idler_thickness = idler_bearing_inner+3+1;
idler_shaft_diam = idler_bearing_inner;
idler_shaft_length = idler_width*2;
idler_x = filament_x + idler_bearing_outer/2 + filament_diam/2;

idler_screw_spacing = (idler_width - idler_bearing_height - 1);
idler_screw_from_shaft = 14;

idler_crevice_width = idler_thickness + 0.5;
idler_crevice_length = total_depth - (filament_y - idler_width/2) + 2;
idler_crevice_depth = 5;
idler_crevice_x = idler_x - 0.5;
idler_crevice_y = total_depth - idler_crevice_length / 2 + 0.5;
idler_crevice_z = body_bottom_pos + bottom_thickness + idler_crevice_depth/2 + 2.75;

idler_length    = idler_bearing_outer+16;
idler_length    = motor_side - 2.75;
idler_length    = -1*(idler_crevice_z - idler_crevice_depth/2 - motor_side/2);

hotend_groove_thickness = 5.8;
hotend_groove_diam      = 13;
hotend_groove_overlap   = 10;
hotend_top_thickness = 0;
hotend_z = idler_crevice_z - hotend_top_thickness - hotend_groove_thickness;

module assembly() {
  //gear_assembly();
  translate([0,0,0]) extruder_body();

  // motor
  % translate([-gear_dist,21.25,0]) rotate([90,0,0]) nema14();

  // extruder shaft
  % translate([0,ext_shaft_length/2-15,0]) rotate([90,0,0]) rotate([0,0,22.5])
    cylinder(r=ext_shaft_diam/2,h=ext_shaft_length,$fn=8,center=true);

  // filament
  % translate([filament_x,filament_y,0]) cylinder(r=3/2,h=60,$fn=36,center=true);

  // hotend
  % translate([filament_x,filament_y,body_bottom_pos-hotend_length/2+hotend_mount_hole_depth]) hotend();

  // carriage clearance
  //translate([0,total_depth,-ext_shaft_diam/2-carriage_clearance/2]) cube([carriage_hole_spacing,.5,carriage_clearance],center=true);
  translate([filament_x,total_depth/2,-ext_shaft_diam/2-carriage_clearance-3/2]) {
    for(side=[-1,1]) {
      % translate([carriage_hole_spacing/2*side,0,0]) rotate([90,0,0]) cylinder(r=3/2,h=total_depth,center=true);
    }
  }
}

module hotend() {
  difference() {
    cylinder(r=hotend_diam/2,h=hotend_length,center=true, $fn=13);

    // groove
    translate([0,0,hotend_length/2-5-hotend_groove_thickness/2]) difference() {
      cylinder(r=hotend_diam/2+0.05,h=hotend_groove_thickness,center=true, $fn=13);
      cylinder(r=6.3,h=hotend_groove_thickness,center=true, $fn=13);
    }
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
  difference() {
    extruder_body_base();
    extruder_body_holes();
  }
  bridges();
}

module extruder_body_base() {
  // motor plate
  translate([-motor_side*0.3,mount_plate_thickness/2,0])
    cube([total_width,mount_plate_thickness,motor_side],center=true);

  block_depth = total_depth-mount_plate_thickness;
  // main block
  translate([motor_side*0.2,block_depth/2+mount_plate_thickness,0])
    cube([motor_side*1.4,block_depth,motor_side],center=true);

  // bottom
  translate([-motor_side*0.3,total_depth/2,body_bottom_pos+bottom_thickness/2])
    cube([total_width,total_depth,bottom_thickness],center=true);

  translate([filament_x,filament_y,idler_screw_from_shaft-4]) {
    for (side=[-1,1]) {
      translate([0,(idler_screw_spacing/2)*side,0]) rotate([0,90,0]) cylinder(r=18*da6,h=45,$fn=6,center=true);
    }
  }

  // hotend groove
  translate([filament_x,filament_y-total_depth/4,hotend_z-hotend_groove_thickness]) {
    translate([0,0,0])
      cube([hotend_diam+hotend_groove_overlap,total_depth,hotend_groove_thickness],center=true);
  }
}
module idler_bearing() {
  difference() {
    cylinder(r=idler_bearing_outer/2,h=idler_bearing_height,center=true);
    cylinder(r=idler_bearing_inner/2,h=idler_bearing_height*2,center=true);
  }
}

module idler() {
  difference() {
    translate([0,0,0]) cube([idler_thickness,idler_width,idler_length],center=true);

    translate([0,0,(idler_length - motor_side)/2]) {
      // holes for screws
      for(side=[-1,1]) {
        translate([-idler_thickness/2,idler_screw_spacing/2*side,idler_screw_from_shaft]) {
          rotate([0,0,0]) rotate([0,90,0]) cylinder(r=da6*3.2,h=idler_thickness*3,$fn=6,center=true);
        }
      }

      rotate([90,0,0]) rotate([0,0,22.5]) cylinder(r=da8*(idler_shaft_diam),h=idler_shaft_length,$fn=8,center=true);
      //translate([-idler_thickness/2,0,0]) cube([idler_thickness,idler_shaft_length,idler_shaft_diam],center=true);

      // hole for bearing
      cube([idler_bearing_outer,idler_bearing_height+1,idler_bearing_outer+2],center=true);

      // idler bearing
      % rotate([90,0,0]) idler_bearing();
    }
  }
}

translate([idler_crevice_x+0.25,filament_y,idler_crevice_z - idler_crevice_depth/2 + idler_length/2]) {
  //idler();
}

module extruder_body_holes() {
  // shaft hole
  translate([0,0,0]) rotate([90,0,0]) cylinder(r=ext_shaft_opening/2,h=100,$fn=36,center=true);
  translate([bearing_outer/2,motor_height/2,0]) cube([bearing_outer,motor_height*2,ext_shaft_opening],center=true);

  // large opening
  translate([motor_side/2+bearing_outer/2-1,motor_height/2,idler_crevice_z+idler_crevice_depth/2+motor_side/2])
    cube([motor_side,motor_height*2,motor_side],center=true);

  // filament path
  translate([filament_x,filament_y,0]) rotate([0,0,22.5]) cylinder(r=4/2,$fn=8,h=50,center=true);

  translate([0,bearing_height/2,0]) {
    translate([0,-0.05,0]) {
      // gear-side bearing
      rotate([90,0,0]) cylinder(r=bearing_outer/2+0.1,h=bearing_height,center=true);

      // round the sharp corner from the gear-side bearing
      //translate([11,0,0]) rotate([90,0,0]) rotate([0,0,22.5]) cylinder(r=10.8,$fn=8,h=bearing_height,center=true);
    }

    % translate([0,0,0]) rotate([90,0,0]) bearing();
  }


  // gear-side filament support bearing
  translate([0,filament_y-bearing_height-1.5,0]) {
    rotate([90,0,0])
      cylinder(r=bearing_outer/2+0.1,h=bearing_height+1,center=true);
    % rotate([90,0,0]) bearing();
  }
  translate([0,bearing_height,0]) {
    rotate([90,0,0])
      cylinder(r=bearing_outer/2-1,h=20,center=true);
    translate([bearing_outer/2,0,0]) cube([bearing_outer-2,20,bearing_outer-2],center=true);
  }

  translate([bearing_outer*.25,filament_y-bearing_height-1.5,0])
    cube([bearing_outer/2+0.1,bearing_height+1,bearing_outer+0.2],center=true);

  // idler bearing access
  translate([bearing_outer/2+ext_shaft_diam/2+filament_x-4,filament_y+bearing_height-1.25,0]) rotate([90,0,0]) rotate([0,0,22.5])
    cylinder(r=bearing_outer/2+1,h=bearing_height*5,$fn=8,center=true);

  // carriage-side filament support bearing
  translate([0,filament_y+bearing_height*2+1,0]) rotate([90,0,0])
    cylinder(r=bearing_outer/2+0.1,h=bearing_height*3,center=true);
  //% translate([0,filament_y+bearing_height+1.2,0]) rotate([90,0,0]) bearing();

  // idler crevice
  translate([idler_crevice_x,idler_crevice_y,idler_crevice_z+idler_crevice_depth/2])
    cube([idler_crevice_width,idler_crevice_length,idler_crevice_depth*2],center=true);

  // idler screw holes for idler screws
  translate([filament_x,filament_y,idler_screw_from_shaft]) {
    for (side=[-1,1]) {
      translate([0,idler_screw_spacing/2*side,0]) rotate([0,90,0]) cylinder(r=3.2*da6,h=45,$fn=6,center=true);
    }
  }

  // captive nut recesses for idler screws
  translate([-4,filament_y,idler_screw_from_shaft]) {
    for (side=[-1,1]) {
      translate([0,idler_screw_spacing/2*side,0]) rotate([0,90,0]) cylinder(r=5.7*da6,h=4,$fn=6,center=true);
      translate([0,idler_screw_spacing/2*side,5]) cube([4,5.7,10],center=true);
    }
  }

  // material saving

  // top center front by large gear
  translate([10,0,motor_side/2+4]) {
    rotate([20,25,0]) cube([40,50,22],center=true);
  }
  // bottom front
  translate([filament_x+4,-12,body_bottom_pos-7]) {
    //rotate([45,0,0]) cylinder(r=20,h=100,center=true);
  }
  translate([filament_x+4,-2,body_bottom_pos-7]) {
    rotate([50,-10,0]) cube([50,20,80],center=true);
  }

  // center back
  translate([0,total_depth+5.5,motor_side/2+2]) {
    rotate([15,0,0]) cube([50,20,50],center=true);
  }
  translate([-motor_side/2,total_depth+6,10]) {
    rotate([10,0,10]) cube([50,20,motor_side+10],center=true);
  }

  // space between motor and extruder shaft
  translate([-gear_dist/2-6,mount_plate_thickness+motor_height/2+10,motor_side/2-12]) {
    rotate([0,11,0]) cube([20,motor_height+20,motor_side+5],center=true);
  }

  // right front corner
  translate([28,0,-total_height/2]) {
    rotate([0,0,-36]) cube([20,60,30],center=true);
  }
  // bottom
  translate([20,-8,body_bottom_pos/2]) {
    rotate([16,0,45]) cube([70,20,50],center=true);
  }
  translate([20,-7,body_bottom_pos/2]) {
    rotate([-16,0,40]) cube([50,20,40],center=true);
  }

  // right rear corner
  translate([36.5,total_depth,body_bottom_pos]) {
    rotate([0,0,30]) cube([20,40,60],center=true);
  }
  translate([36,total_depth,body_bottom_pos]) {
    rotate([0,5,30]) cube([20,40,60],center=true);
  }
  translate([36,total_depth,body_bottom_pos+bottom_thickness+5]) {
    rotate([0,-10,30]) cube([20,40,60],center=true);
  }

  // bottom motor end
  translate([-gear_dist-motor_side/2,total_depth/2,body_bottom_pos-3.75]) {
    rotate([10,40,0]) cube([30,total_height*2,20],center=true);
  }
  translate([-gear_dist-motor_side/2+9,total_depth,body_bottom_pos]) {
    rotate([0,0,60]) cube([total_depth*2,20,20],center=true);
  }

  // top motor end
  translate([-gear_dist-motor_side/2,0,motor_side/2]) {
    rotate([0,45,0]) cube([5,10,10],center=true);
  }

  // motor
  translate([-gear_dist,mount_plate_thickness/2,0]) rotate([90,0,0]){
    // motor shoulder
    cylinder(r=motor_shoulder_diam/2+1,h=mount_plate_thickness*2,center=true);

    // motor mounting holes
    for (x=[-1,1]) {
      for (y=[-1,1]) {
        translate([motor_screw_spacing/2*x,motor_screw_spacing/2*y,0]) cylinder(r=3.2*da6,h=mount_plate_thickness*2,$fn=6,center=true);
      }
    }
  }

  // hotend
  translate([filament_x,filament_y,body_bottom_pos+hotend_mount_hole_depth/2]) {
    // hotend mount hole
    rotate([0,0,22.5])
      cylinder(r=da8*hotend_diam+0.05,h=hotend_mount_hole_depth,$fn=8,center=true);
    translate([0,(total_depth-filament_y)/2,0])
      cube([hotend_diam,total_depth-filament_y+0.5,hotend_mount_hole_depth],center=true);
    translate([0,0,-hotend_groove_thickness]) {
      rotate([0,0,22.5]) cylinder(r=hotend_groove_diam*da8,$fn=8,h=hotend_groove_thickness+1,center=true);
      translate([0,(total_depth-filament_y)/2,0]) {
        cube([hotend_groove_diam,total_depth-filament_y+1,hotend_groove_thickness+1],center=true);
      }
    }

    /*
    // plate is not symmetric, skew to one side
    translate([-1.5,0,0]) {
      // hotend plate recess
      cube([hotend_mount_length,hotend_mount_width,0],center=true);

      // hotend plate screw holes
      for (side=[-1,1]) {
        translate([side*hotend_mount_screw_hole_spacing,0,0]) {
          // screw holes
          cylinder(r=hotend_mount_screw_diam*da6+0.05,$fn=6,h=total_height,center=true);
          % cylinder(r=hotend_mount_screw_diam/2,$fn=72,h=10,center=true);

          // captive nut recesses for hotend mounting plate
          translate([0,0,bottom_thickness+49]) cylinder(r=7.3*da6,$fn=6,h=6.4+100,center=true);
        }
      }
    }
    */
  }

  // filament guide top recess
  translate([filament_x,filament_y,motor_side/2]) rotate([0,0,22.5])
    cylinder(r=6.25/2,$fn=8,h=10,center=true);

  // carriage mounting holes
  /*
  translate([filament_x,total_depth/2,body_bottom_pos+bottom_thickness/2+1]) {
    for (side=[-1,1]) {
      translate([side*carriage_hole_spacing/2,-carriage_hole_support_thickness,0]) rotate([90,0,0]) rotate([0,0,22.5])
        cylinder(r=carriage_hole_large_diam*da8,$fn=8,h=total_depth,center=true);

      translate([side*carriage_hole_spacing/2,total_depth/2,0]) rotate([90,0,0])
        cylinder(r=carriage_hole_small_diam*da6,$fn=6,h=total_depth,center=true);
    }
  }
  */
}

module hotend_groove() {
  translate([filament_x,0,body_bottom_pos-hotend_groove_thickness/2]) {
    difference() {
      translate([0,total_depth/2,0])
        cube([hotend_diam+hotend_groove_overlap,total_depth,hotend_groove_thickness],center=true);
      translate([0,filament_y,0]) {
        rotate([0,0,22.5]) cylinder(r=hotend_groove_diam*da8,$fn=8,h=hotend_groove_thickness+1,center=true);
        translate([0,(total_depth-filament_y)/2,0]) {
          cube([hotend_groove_diam,total_depth-filament_y+1,hotend_groove_thickness+1],center=true);
        }
      }
    }
  }
      /*
  translate([filament_x,filament_y,body_bottom_pos-hotend_groove_thickness/2]) {
    // hotend groove
    difference() {
      union() {
        rotate([0,0,22.5]) cylinder(r=(hotend_diam+hotend_groove_overlap)*da8,$fn=8,h=hotend_groove_thickness,center=true);
        translate([0,(total_depth-filament_y)/2,0]) {
          cube([hotend_diam+hotend_groove_overlap,total_depth-filament_y,hotend_groove_thickness],center=true);
        }
      }
      rotate([0,0,22.5]) cylinder(r=hotend_groove_diam*da8,$fn=8,h=hotend_groove_thickness+1,center=true);
      translate([0,(total_depth-filament_y)/2,0]) {
        cube([hotend_groove_diam,total_depth-filament_y+1,hotend_groove_thickness+1],center=true);
      }
    }
  }
      */
}

//hotend_groove();

bridge_thickness = 0.3;

module bridges(){
  // gear support bearing
  translate([-0.5*(bearing_outer-bearing_outer)-1,bearing_height+bridge_thickness/3,0])
    cube([bearing_outer,bridge_thickness,bearing_outer],center=true);

  // hobbed support bearing bridge
  translate([0,bridge_thickness/2+filament_y-bearing_height/2-1.25,0]) {
    difference() {
      translate([-0.5*(bearing_outer-bearing_outer)-1,0,0])
        cube([bearing_outer,bridge_thickness,bearing_outer],center=true);

      // force the bridging direction by having two bridges
      translate([0+ext_shaft_diam/2+0.05,0,0]) cube([0.1,bridge_thickness*2,bearing_outer],center=true);
    }
    % translate([3.1,0,0]) cube([0.6*9,bridge_thickness*2,2]);
  }

  // carriage mounting hole diameter drop
  /*
  translate([filament_x,total_depth-carriage_hole_support_thickness,body_bottom_pos+bottom_thickness/2+1]) {
    for (side=[-1,1]) {
      //translate([side*carriage_hole_spacing/2,carriage_hole_support_thickness,0])
      translate([side*carriage_hole_spacing/2,0,0])
        # cube([carriage_hole_large_diam+0.5,bridge_thickness,carriage_hole_large_diam+0.5],center=true);
    }
  }
  */
}

//rotate([90,0,0]) assembly();
assembly();
