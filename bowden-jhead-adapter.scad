use <polyScrewThread.scad>
use <knurledFinishLib.scad>

///// feeder mechanim
outer_plate_width = 5.75;
inner_plate_width = 3.75;
total_width = 2*outer_plate_width + inner_plate_width;
total_d = 40;
margin_h = 5;

///// original feeder bowden clamp
nut_d = 16.75;
nut_outer_d = 2*sqrt(pow(nut_d/2,2) + pow(total_width/2,2)) + 4;
nut_h = 6.15;
clamp_d = 14.5;
clamp_mid_d = 2*sqrt(pow(clamp_d/2,2) + pow(inner_plate_width/2,2));
clamp_h = 3.75;
clamp_full_h=8.25;
clamp_ring_d = 11;
clamp_ring_h = 1.5;
screw_d = 9;
screw_mid_d = 2*sqrt(pow(screw_d/2,2) + pow(inner_plate_width/2,2));
screw_h = 9;
filament_d = 4.0;
bowden_d = 7.0;

///// owen's hot-end clamp params
baseHeight = 0; //6 is good
tubeRadius = 3.1;
tR_Allow = 0.8; //adjustment for above for clearance. Printers put too much inside holes usually - use 0.8
threadLength = 20;
threadBottom = clamp_h;
tighteningConeTopRadius = 4.7;
tighteningConeHeight = 10;
topOfTighteningConeHeight = 3;
tighteningConeOpening = 1.7;
tighteningConeInnerRatio = 0.9;
riserTubeRadius = 7.5;
riserTubeSkirt = clamp_mid_d/2 - riserTubeRadius; // leave
capInsideDiameter = 2*riserTubeRadius + 0.2; // usually double riserTubeRadius + 1
capTopThickness = 4;
capHeight = threadLength + capTopThickness;
capOuterDiameter = 24.5;
stlClearance = 0.02; //Used to make edges to overlap by a small amount to prevent errors in the STL output
tubeCentre = [0, 0, -stlClearance];

///// other params
$fn = 36;
PI=3.141592;


/////////////////// VIEWING ////////////////////////
//exploded_view() original_clamp(); 
//exploded_view() new_clamp(); 
////////////////////////////////////////////////////////


/////////////////// PRINTING //////////////////////
new_clamp(); 
//tighteningCone();
//cap();
////////////////////////////////////////////////////////


module exploded_view() {
  feeder_box();
  color([1.0,0.2,0.2]) translate([0,0,outer_plate_width + inner_plate_width/2]) rotate([-90,0,0]) child(0);
}

module feeder_box() {
  outer_plate();
  translate([0,0,outer_plate_width]) inner_plate();
  translate([0,0,outer_plate_width + inner_plate_width]) outer_plate();
}

module outer_plate() {
  linear_extrude(height=outer_plate_width)
    polygon(points=[
    [screw_d/2,0], [screw_d/2,screw_h],
    [nut_d/2,screw_h],[nut_d/2, screw_h+nut_h],
    [clamp_d/2,screw_h+nut_h], [clamp_d/2,screw_h+nut_h+clamp_h],
    [total_d/2,screw_h+nut_h+clamp_h],[total_d/2, -margin_h],
    [-total_d/2, -margin_h], [-total_d/2, screw_h+nut_h+clamp_h],
    [-clamp_d/2,screw_h+nut_h+clamp_h], [-clamp_d/2,screw_h+nut_h],
    [-nut_d/2,screw_h+nut_h], [-nut_d/2,screw_h],
    [-screw_d/2,screw_h], [-screw_d/2,0],
  ]);
}

module inner_plate() {
  linear_extrude(height=inner_plate_width)
  polygon(points=[
    [-screw_mid_d/2,0], [-screw_mid_d/2,screw_h],
    [-total_d/2,screw_h],[-total_d/2, -margin_h],
    [-screw_d/2, -margin_h], [-filament_d/2, -margin_h], [-filament_d/2,0],
  ]);
}

module original_clamp() {
  difference() {
    union() {
      cylinder(r=screw_mid_d/2, h=screw_h);
      translate([0, 0, screw_h]) {
        translate([-nut_d/2,-total_width/2,0]) cube([nut_d, total_width, nut_h]);
        translate([0,0,nut_h]) {
          cylinder(r=clamp_mid_d/2, h=clamp_full_h);
          translate([0,0,clamp_full_h]) cylinder(r=clamp_ring_d/2, h=clamp_ring_h);
        }
     }
    }
    translate([0,0,-1]) cylinder(r=filament_d/2, nut_h+screw_h+clamp_full_h+2);
    translate([0,0,screw_h]) cylinder(r=bowden_d/2, screw_h+clamp_full_h+1);
  }
}

module new_clamp() {
  difference() {
    union() {
      cylinder(r=screw_mid_d/2, h=screw_h);
      translate([0, 0, screw_h]) {
        intersection() {
          translate([-nut_d/2,-total_width/2,0]) cube([nut_d, total_width, nut_h]);
          translate([0,0,-0.01]) cylinder(r=screw_mid_d/2, r2=nut_outer_d/2, h=nut_h+0.02);
        }
        translate([0,0,nut_h]) riserTube();
     }
    }
    translate([0,0,-1]) cylinder(r=filament_d/2, nut_h+screw_h+clamp_full_h+2);
    translate([0,0,screw_h]) cylinder(r=bowden_d/2, screw_h+clamp_full_h+1);
  }
}

//////////////////////////////////////////////////////////////////////////////////////
////////// BORROWED FROM Owen's Bowden Clamp
////////// http://www.thingiverse.com/thing:11864
//////////////////////////////////////////////////////////////////////////////////////

module riserTube(){
    translate (tubeCentre)
        translate ([0,0,baseHeight])
        difference(){
            union(){
                cylinder(r = riserTubeRadius, h = threadBottom + stlClearance);
                cylinder(r1 = riserTubeRadius + riserTubeSkirt, r2 = riserTubeRadius, h = threadBottom + stlClearance);  //riserTubeSkirt//
                translate([0,0,threadBottom])Makerbolt();
            }
                translate ([0,0,threadBottom])
                    cylinder(r1 = tubeRadius + tR_Allow, r2 = tighteningConeTopRadius, h = threadLength + stlClearance);
        }
}

module tighteningCone(){
    rotate ([180,0,-45])
        translate ([0,0,-threadLength - topOfTighteningConeHeight])
        difference(){
            union(){
                cylinder(r1 = tubeRadius + tR_Allow, r2 = tighteningConeTopRadius, h = threadLength);
                translate([0,0,threadLength - stlClearance]) cylinder(r = tighteningConeTopRadius, h = topOfTighteningConeHeight);
            }
                translate ([0,0, - stlClearance])
                    cylinder(r = tighteningConeTopRadius + 1, h = threadLength - tighteningConeHeight);
                translate([0,0,-1])cylinder(r=(tubeRadius + tR_Allow) * tighteningConeInnerRatio, h = 70);
                translate([0, -tighteningConeOpening / 2,0]) cube([riserTubeRadius * 2, tighteningConeOpening, threadLength * 2]);
        }
    }

module cap(){
    translate ([0,0,capHeight])
    rotate ([180,0,0])
        union(){
            nut_4_Makerbolt();
            difference(){
                translate ([0,0,capHeight - capTopThickness])
                    cylinder(r = capInsideDiameter / 2 + 1, h = capTopThickness);
                        passThroughTube();
            }
        }
}

module passThroughTube(){
    cylinder(r=tubeRadius + tR_Allow, h = 70);
}


// Thanks http://www.thingiverse.com/thing:9095

module Makerbolt() {
    /* Bolt parameters.
    *
    * Just how thick is the head.
    * The other parameters, common to bolt and nut, are defined into k_cyl() module
    */
    b_hg=0; //distance of knurled head
    
    /* Screw thread parameters
    */
    t_od=riserTubeRadius * 2; // Thread outer diameter
    t_st=2.5; // Step/traveling per turn
    t_lf=55; // Step angle degrees
    t_ln=threadLength; // Length of the threade section
    t_rs=PI/2; // Resolution
    t_se=1; // Thread ends style
    t_gp=0; // Gap between nut and bolt threads
    
    
    translate([0,0,b_hg])screw_thread(t_od+t_gp, t_st, t_lf, t_ln, t_rs, t_se);
}

/* ****************************************************************************** */
/* Example 03.
 *
 * Just a knurled nut.
 * (Because we needed something where we can use Example 02...)
 */
module nut_4_Makerbolt()
{
 /* Nut parameters.
  */
    n_df=25;    // Distance between flats
    n_hg=capHeight;    // Thickness/Height
    n_od=capInsideDiameter;    // Outer diameter of the bolt to match
    n_st=2.5;   // Step height
    n_lf=55;    // Step Degrees
    n_rs=0.5;   // Resolution
    n_gp=0.07;   // Gap between nut and bolt


    intersection()
    {
        hex_nut(n_df, n_hg, n_st, n_lf, n_od + n_gp, n_rs);

        k_cyl(n_hg);
    }
}

/* ****************************************************************************** */
/* Knurled cylinder module used in both: Makerbolt() and Makerbolt_nut() modules
 */
module k_cyl(bnhg)
{
 /* Bolt/Nut parameters
  */
    k_cyl_hg=bnhg;   // Knurled cylinder height
    k_cyl_od = capOuterDiameter; // was 22.5;   // Knurled cylinder outer* diameter

    knurl_wd=3;      // Knurl polyhedron width
    knurl_hg=4;      // Knurl polyhedron height
    knurl_dp=1.5;    // Knurl polyhedron depth

    e_smooth=1;      // Cylinder ends smoothed height
    s_smooth=0;      // [ 0% - 100% ] Knurled surface smoothing amount

    knurled_cyl(k_cyl_hg, k_cyl_od,
                knurl_wd, knurl_hg, knurl_dp,
                e_smooth, s_smooth);
}
