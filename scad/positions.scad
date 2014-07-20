include <config.scad>;

idler_screw_from_shaft = bearing_outer/2+idler_screw_nut_diam/2+2;

// bearing helps provide clearance for motor mount screws
gear_side_bearing_y = bearing_height/2-m3_socket_head_height/2; // buttonhead

main_body_height_below_shaft = bearing_outer/2 + min_material_thickness*3;

// motor position
motor_z = bottom*(main_body_height_below_shaft) + motor_side/2;
motor_y = mount_plate_thickness;
motor_x = -sqrt(pow(gear_dist,2)-pow(motor_z,2));

module position_motor() {
  translate([motor_x,motor_y,motor_z])
    child(0);
}

main_body_width_motor_side = -motor_x - motor_side/2;
main_body_width_idler_side = hobbed_effective_diam/2 + filament_diam + min_material_thickness;
main_body_width  = main_body_width_motor_side + main_body_width_idler_side;
main_body_depth  = motor_len + mount_plate_thickness;
main_body_height_above_shaft = idler_screw_from_shaft + idler_screw_diam/2 + min_material_thickness * 2;
main_body_height = main_body_height_above_shaft + main_body_height_below_shaft + bottom_plate_height;

main_body_x = left*main_body_width/2+main_body_width_idler_side;
main_body_y = main_body_depth/2;
main_body_z = bottom*main_body_height/2+main_body_height_above_shaft;

filament_x = hobbed_effective_diam/2 + filament_compressed_diam/2;
filament_y = main_body_depth - filament_from_carriage;

idler_x = filament_x + filament_compressed_diam/2 + idler_bearing_outer/2;
idler_y = filament_y;
idler_offset_from_bearing = idler_bearing_inner*.25;

total_width = carriage_hole_spacing + m3_nut_diam + min_material_thickness*4;

hotend_z = (main_body_height_below_shaft+bottom_plate_height-hotend_height_above_groove) * bottom;

bottom_plate_z = bottom*(main_body_height_below_shaft+bottom_plate_height/2);
carriage_hole_z = bottom_plate_z;

idler_retainer_width = filament_x + total_width/2 - idler_x - idler_offset_from_bearing - idler_groove_width/2;
idler_retainer_x     = filament_x + total_width/2 - idler_retainer_width/2;

carriage_side_bearing_y = filament_y + hobbed_depth/2 + bearing_lip_height;
