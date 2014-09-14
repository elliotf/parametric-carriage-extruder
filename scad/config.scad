motor_pulley_tooth_pitch = 2; // GT2 belt
motor_pulley_tooth_count = 20;

// All hail whosawhatsis
da6 = 1 / cos(180 / 6) / 2;
da8 = 1 / cos(180 / 8) / 2;
pi  = 3.14159;

resolution = 24;

// make coordinates more communicative
left  = -1;
right = 1;
front = -1;
rear  = 1;
top = 1;
bottom  = -1;

// address vector positions by their name
x = 0;
y = 1;
z = 2;

// Screws, nuts
m3_diam = 3.1;
m3_nut_diam  = 5.8;
m3_nut_thickness  = 2.5;
m3_nut_height  = m3_nut_thickness;
m3_socket_head_diam = 6;
m3_socket_head_height = 3;
m5_diam = 5;
m5_nut_diam = 8;
m5_nut_thickness = 5;

// Motors
nema17_side = 43;
nema17_len = 36; // "half-length" nema 17
nema17_len = 48;
nema17_hole_spacing = 31;
nema17_screw_diam = m3_diam;
nema17_shaft_diam = 5;
nema17_shaft_len = 16.5;
nema17_short_shaft_len = 0;
nema17_shoulder_height = 2;
nema17_shoulder_diam = nema17_hole_spacing*.75;

nema14_side = 35.3;
nema14_len = 36;
nema14_hole_spacing = 26;
nema14_screw_diam = m3_diam;
nema14_shaft_diam = 5;
nema14_shaft_len = 20;
nema14_short_shaft_len = 20;
nema14_shoulder_height = 2;
nema14_shoulder_diam = 22;

motor_side = nema17_side;
motor_len = nema17_len;
motor_hole_spacing = nema17_hole_spacing;
motor_screw_diam = nema17_screw_diam;
motor_shaft_diam = nema17_shaft_diam;
motor_shaft_len = nema17_shaft_len;
motor_short_shaft_len = nema17_short_shaft_len;
motor_shoulder_height = nema17_shoulder_height;
motor_shoulder_diam = nema17_shoulder_diam;

/*
motor_side = nema14_side;
motor_len = nema14_len;
motor_hole_spacing = nema14_hole_spacing;
motor_screw_diam = nema14_screw_diam;
motor_shaft_diam = nema14_shaft_diam;
motor_shaft_len = nema14_shaft_len;
motor_short_shaft_len = nema14_short_shaft_len;
motor_shoulder_height = nema14_shoulder_height;
motor_shoulder_diam = nema14_shoulder_diam;
*/

// Misc settings
extrusion_width = 0.5;
extrusion_height = 0.3;
min_material_thickness = extrusion_width*2;
spacer = 1;

// bearing size

// 4-40
idler_screw_diam = 3.2;
idler_screw_nut_diam = 6.8;
idler_screw_nut_thickness = 2.5;

// m3
idler_screw_diam = m3_diam;
idler_screw_nut_diam = m3_nut_diam;
idler_screw_nut_thickness = 2.5;

// 608
idler_bearing_height = 7;
idler_bearing_outer  = 22;
idler_bearing_inner  = 8;

//626
idler_bearing_height = 6;
idler_bearing_outer  = 19;
idler_bearing_inner  = 6;

//625
idler_bearing_height = 5;
idler_bearing_outer  = 16;
idler_bearing_inner  = 5;

/*
//624
idler_bearing_height = 5;
idler_bearing_outer  = 13;
idler_bearing_inner  = 4;

//623
idler_bearing_height = 4;
idler_bearing_outer  = 10;
idler_bearing_inner  = 3;
*/

filament_diam = 3;
filament_compressed_diam = filament_diam - .2;
filament_opening_diam = filament_diam + 0.5;

hobbed_effective_diam = 6.9;
hobbed_outer_diam = 8;
hobbed_depth = 7;

hotend_length = 63;
hotend_diam   = 16;
hotend_groove_diam   = 12;

// jhead
hotend_height_above_groove = 5;
hotend_groove_height = 4.6;

// e3d v6 direct
hotend_height_above_groove = 3.7;
hotend_groove_height = 6;

hotend_clamped_height = hotend_height_above_groove + hotend_groove_height;

wall_thickness = 3;

motor_pulley_circumference = motor_pulley_tooth_pitch * motor_pulley_tooth_count;
motor_pulley_diameter      = motor_pulley_circumference / pi;
belt_thickness = 1;
belt_tooth_height   = 1.5;
belt_tooth_distance = 2;
belt_tooth_ratio    = 0.5;
belt_width = 6;
belt_opening_width = 8;

x_rod_spacing = 45;

// lm8uu
bearing_len = 25;
bearing_diam = 15;

bearing_body_diam = bearing_diam+wall_thickness*2;
space_between_bearing_bodies = x_rod_spacing - bearing_body_diam;
space_between_bearings = 1;
x_carriage_width = bearing_len*2 + space_between_bearings;
carriage_plate_thickness = 5;
carriage_screw_diam = m3_diam;
carriage_nut_diam = m3_nut_diam;
carriage_nut_height = 2;
carriage_screw_spacing = 30;

belt_clamp_width  = x_carriage_width;
belt_clamp_height = space_between_bearing_bodies/2+carriage_nut_diam/2;
belt_clamp_depth  = bearing_body_diam/2-carriage_plate_thickness + belt_opening_width/2;

idler_groove_material = 5;
idler_width = idler_bearing_height + wall_thickness * 4;
