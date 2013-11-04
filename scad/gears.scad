da6 = 1 / cos(180 / 6) / 2;
da8 = 1 / cos(180 / 8) / 2;

// Copyright 2011 Cliff L. Biffle.
// This file is licensed Creative Commons Attribution-ShareAlike 3.0.
// http://creativecommons.org/licenses/by-sa/3.0/

// You can get this file from http://www.thingiverse.com/thing:3575
include <config.scad>
include <positions.scad>
use <inc/parametric_involute_gear_v5.0.scad>
//use <inc/nema.scad>
use <inc/spur_generator.scad>

//include <configuration.scad>
//include <positions.scad>

// M6
ext_shaft_diam = 6;
ext_shaft_nut_diam = 10;
ext_shaft_nut_height = 4.5;

// M5
ext_shaft_diam = 5;
ext_shaft_nut_diam = 8.1;
ext_shaft_nut_height = 3.5;

// Here's an example.
large_tooth_num = 71;
small_tooth_num = 13;
/* use this ratio for NEMA17?
large_tooth_num = 38;
small_tooth_num = 13;
*/
//gear_dist = 35;
// printed 51 and 9
// 7 and 41
// 9 and 41
// 11 and 49
gear_pitch = fit_spur_gears(large_tooth_num, small_tooth_num, gear_dist);

small_tooth_height = 7;
small_gear_height  = 15;

large_gear_thickness = small_tooth_height;

module large_gear() {
  difference() {
    // Simple Test:
    gear (circular_pitch=gear_pitch,
      gear_thickness = large_gear_thickness,
      rim_thickness = large_gear_thickness,
      rim_width = 3,
      //hub_thickness = 17,
      hub_thickness = large_gear_thickness-0.5+ext_shaft_nut_height,
      hub_diameter = ext_shaft_nut_diam + 7,
      number_of_teeth = large_tooth_num,
      circles=4,
      bore_diameter = 0);
    cylinder(r=ext_shaft_diam/2,$fn=36,h=50,center=true);
    translate([0,0,large_gear_thickness-1+ext_shaft_nut_height]) {
      cylinder(r=da6*ext_shaft_nut_diam,h=ext_shaft_nut_height*2,center=true,$fn=6); // nut trap for m6 nut
    }
  }
}

module small_gear() {
  set_screw_nut_diam = 6;
  difference() {
    gear (
      circular_pitch  = gear_pitch,
      gear_thickness  = small_tooth_height,
      rim_thickness   = small_tooth_height,
      hub_thickness   = small_gear_height,
      circles         = 0,
      number_of_teeth = small_tooth_num,
      rim_width       = 2,
      bore_diameter   = 0,
      //hub_diameter    = 21
      hub_diameter    = gear_outer_radius(small_tooth_num,gear_pitch) * 2 + min_material_thickness * 2.5
    );

    // flatted motor hole
    difference() {
      cylinder(r=5.3/2,$fn=18,h=90,center=true);
      //% rotate([0,0,22.5]) cylinder(r=4.5*da8,$fn=8,h=90,center=true);
      //% rotate([0,0,22.5]) cylinder(r=5*da8,$fn=8,h=90,center=true);
      translate([2.65,0,0]) cube([1,10,100],center=true);
    }

    // m3 set screw
    // m3 nut == 5.5mm * 3mm
    translate([2.25,0,small_gear_height-3.5]) {
      rotate([0,90,0]) cylinder(r=set_screw_nut_diam*da6,h=5,$fn=6,center=true);
      translate([0,0,2.1]) cube([5,set_screw_nut_diam,3],center=true);
      translate([10,0,0]) rotate([90,0,0]) rotate([0,90,0]) cylinder(r=3*da6,h=20,$fn=6,center=true);
      //% translate([1.25,0,0]) rotate([0,90,0]) cylinder(r=5.5*da6,h=2.5,$fn=6,center=true);
    }
  }
}

module assembly() {
  large_gear();

  translate([gear_dist,0,0]) small_gear();
}

module plate() {
  large_gear();

  translate([gear_dist + 10,0,15]) {
    rotate([180,0,0]) small_gear();
  }
}

//plate();
assembly();
