motor_pulley_tooth_pitch = 2; // GT2 belt
motor_pulley_tooth_count = 16;

// All hail whosawhatsis
pi  = 3.14159265359;

resolution = 32;
rotation   = 180/resolution;

motor_clamp_mount_width     = 20;
motor_clamp_mount_thickness = 8;

// make coordinates more communicative
left  = -1;
center = 0;
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
m3_diam          = 3.1;
m3_diam_vertical = 3.2; // after printer calibration check
m3_nut_diam  = 5.8;
m3_nut_thickness  = 2.5;
m3_nut_height  = m3_nut_thickness;
m3_socket_head_diam = 6;
m3_socket_head_height = 3;

m5_diam = 5;
m5_nut_diam = 8;
m5_nut_thickness = 4;
m5_nut_height = m5_nut_thickness;

// Motors
nema17_side = 42.5;
nema17_diam = 50.5;
nema17_len = 36; // "half-length" nema 17
nema17_len = 48;
nema17_hole_spacing = 31;
nema17_screw_diam = m3_diam;
nema17_shaft_diam = 5;
nema17_shaft_len = 22;
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
motor_diam = nema17_diam;
motor_len = nema17_len;
motor_hole_spacing = nema17_hole_spacing;
motor_shaft_diam = nema17_shaft_diam;
motor_shaft_len = nema17_shaft_len;
motor_short_shaft_len = nema17_short_shaft_len;
motor_shoulder_height = nema17_shoulder_height;
motor_shoulder_diam = nema17_shoulder_diam;

/*
motor_side = nema14_side;
motor_len = nema14_len;
motor_hole_spacing = nema14_hole_spacing;
motor_shaft_diam = nema14_shaft_diam;
motor_shaft_len = nema14_shaft_len;
motor_short_shaft_len = nema14_short_shaft_len;
motor_shoulder_height = nema14_shoulder_height;
motor_shoulder_diam = nema14_shoulder_diam;
*/

motor_screw_head_diam = 6;

// Misc settings
extrusion_width = 0.5;
extrusion_height = 0.3;
min_material_thickness = extrusion_width*2;
spacer = 1;

// bearing size

// 4-40
idler_screw_diam = 3.2;
idler_nut_diam = 6.8;
idler_nut_thickness = 2.5;

// m3

// 608
idler_bearing_height = 7;
idler_bearing_outer  = 22;
idler_bearing_inner  = 8;

//626
idler_bearing_height = 6;
idler_bearing_outer  = 19;
idler_bearing_inner  = 6;

//625
idler_bearing_height      = 5;
idler_bearing_outer       = 16;
idler_bearing_inner       = 5;
idler_screw_diam          = m5_diam;
idler_nut_diam            = m5_nut_diam;
idler_nut_thickness       = m5_nut_thickness;

/*
//624
idler_bearing_height = 5;
idler_bearing_outer  = 13;
idler_bearing_inner  = 4;

//623
idler_bearing_height      = 4;
idler_bearing_outer       = 10;
idler_bearing_inner       = 3;
idler_screw_diam          = m3_diam;
idler_nut_diam      = m3_nut_diam;
idler_nut_thickness = 2.5;
*/

filament_diam = 3;
filament_compressed_diam = filament_diam * 0.75;
filament_opening_diam = filament_diam + 0.5;

hobbed_pulley_height  = 11;
hobbed_pulley_len     = hobbed_pulley_height;
hobbed_effective_diam = 6.9;
hobbed_pulley_diam    = 9;
hob_dist_from_end     = 3.25;
hob_width             = 3.5;
hob_depth             = hobbed_pulley_diam/2-hobbed_effective_diam/2;

hotend_length      = 63;
hotend_diam        = 16;
hotend_groove_diam = 12;
hotend_clearance   = 0.15;

// e3d v6 direct
hotend_height_above_groove = 3.7;
hotend_groove_height = 6;

// jhead
hotend_height_above_groove = 5;
hotend_groove_height = 4.6;

hotend_clamped_height = hotend_height_above_groove + hotend_groove_height;

wall_thickness = extrusion_width*4;

motor_pulley_circumference = motor_pulley_tooth_pitch * motor_pulley_tooth_count;
motor_pulley_diameter      = motor_pulley_circumference / pi;
belt_thickness = .95;
belt_tooth_height   = 1.5;
belt_tooth_distance = 2;
belt_tooth_ratio    = 0.5;
belt_width = 6;
belt_opening_width = 8;

x_rod_spacing = 45;

// lm8uu
bearing_len = 25;
bearing_diam = 15;

carriage_screw_spacing = 30;
