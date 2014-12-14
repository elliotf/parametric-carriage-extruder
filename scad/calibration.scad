include <util.scad>
include <config.scad>
use <motor_clamp.scad>

module m3_hole_calibration() {
  offset = wall_thickness+m3_diam;
  diams=[m3_diam];
  steps=[-2,-1,0,1,2,3,4];
  resolutions=[8,16,32];

  max_res_index  = 3;
  max_diam_index = 6;

  size_x = offset*(max_diam_index+1.5);
  size_y = offset*(max_res_index+1.5);
  size_z = 4;

  module body() {
    cube([size_x,size_y,size_z]);
  }

  module holes() {
    offset = wall_thickness+m3_diam;
    diams=[m3_diam];
    steps=[-2,-1,0,1,2,3,4];
    resolutions=[6,8,16,32];
    for(res=[0:max_res_index]) {
      for(try=[0:max_diam_index]) {
        translate([offset*(try+.75),offset*(res+.75),0]) {
          rotate([0,0,180/resolutions[res]]) {
            hole(m3_diam+(.05*steps[try]),10,resolutions[res]);

            hull() {
              translate([0,0,-.1]) {
                hole(m3_diam+(.05*steps[try])+.6,.1,resolutions[res]);
                hole(m3_diam+(.05*steps[try]),.9,resolutions[res]);
              }
            }
          }
          echo("DIAM: ", m3_diam+(.05*steps[try]));
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

m3_hole_calibration();
