// You can get this file from http://www.thingiverse.com/thing:3575
include <../scad/positions.scad>
use <../scad/main.scad>

translate([-10,0,0])
  rotate([0,0,180])
    rotate([90,0,0])
      extruder_body();

translate([30,-10,idler_thickness/2+idler_offset_from_bearing])
  rotate([0,90,0])
    idler();

translate([-40,-20,idler_shaft_diam/2])
  idler_shaft();

translate([-40,20,0])
  rotate([0,0,180])
    hotend_retainer();

% translate([0,0,-.5]) cube([150,150,1],center=true);
