include <config.scad>;

// motor position
motor_y = (bearing_diam/2+wall_thickness+motor_side/2)*front;
motor_z = 27;

hotend_side = front;
hotend_motor_offset_y = (hobbed_effective_diam/2+filament_diam/2-0.25)*hotend_side;
hotend_motor_offset_z = (motor_shoulder_diam/2)*bottom;

hotend_clamp_removable_width = hotend_diam/2 + 2;

hotend_x = x_carriage_width/2 - hotend_clamp_removable_width;
hotend_y = motor_y + hotend_motor_offset_y;
hotend_z = motor_z + hotend_motor_offset_z;

hotend_clamp_width  = x_carriage_width/2-hotend_x;
hotend_clamp_height = hotend_groove_height + hotend_height_above_groove;

hotend_clamp_x = x_carriage_width/2 - hotend_clamp_width/2;
hotend_clamp_y = motor_y;
hotend_clamp_z = hotend_z - hotend_clamp_height/2;

idler_bearing_x = hotend_x;
//idler_bearing_y = hotend_y + (idler_bearing_outer/2+filament_diam/2-0.25)*hotend_side;
idler_bearing_y = hotend_y + (idler_bearing_outer/2)*hotend_side;
idler_bearing_z = motor_z;

belt_clamp_x = 0;
belt_clamp_y = 0;
belt_clamp_z = 0;
belt_clamp_center_screw_offset_z = space_between_bearing_bodies/2-carriage_nut_diam/2-2;

motor_x = hotend_x - hotend_clamp_removable_width;

module position_motor() {
  translate([motor_x,motor_y,motor_z])
    children();
}
