// You can get this file from http://www.thingiverse.com/thing:3575
include <../scad/config.scad>
include <../scad/positions.scad>
use <../scad/main.scad>

rotate([90,0,0]) extruder_body();

translate([40,0,hotend_diam/2+filament_from_carriage/2]) rotate([-90,0,0]) groove_mount_plug();

translate([30,-idler_width,4.5])
  rotate([0,90,0]) idler();

% translate([0,0,-0.5]) cube([150,150,1],center=true);
