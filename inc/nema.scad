motor_side = 35;
motor_height = 36.5;
motor_shaft_length = 19;
motor_short_shaft_length = 10;
motor_shoulder_height = 2;
motor_shoulder_diam = 22;

module nema14() {
  cube([motor_side,motor_side,motor_height],center=true);

  // shaft
  translate([0,0,motor_height/2+motor_shaft_length/2+motor_shoulder_height])
    cylinder(r=5/2,h=motor_shaft_length,center=true);

  // shoulder
  translate([0,0,motor_height/2+motor_shoulder_height/2])
    cylinder(r=motor_shoulder_diam/2,h=motor_shoulder_height,center=true); // shoulder

  // short shaft
  translate([0,0,-motor_height/2-motor_short_shaft_length/2])
    cylinder(r=5/2,h=motor_short_shaft_length,center=true);
}

//nema14();
