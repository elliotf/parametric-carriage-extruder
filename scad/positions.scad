include <config.scad>;

idler_screw_from_shaft = bearing_outer/2+idler_screw_nut_diam/2+2;

// bearing helps provide clearance for motor mount screws
gear_side_bearing_y = bearing_height/2-m3_socket_head_height+1;

// distance between extruder shaft and top of the bottom plate
ext_shaft_hotend_dist = bearing_outer/2 + 3;

body_bottom_pos = -ext_shaft_hotend_dist-bottom_thickness;

main_body_width = min_material_thickness+filament_diam/2+filament_x+bearing_outer/2+min_material_thickness*2;
main_body_height = ext_shaft_hotend_dist + idler_screw_from_shaft + idler_screw_nut_diam/2 + min_material_thickness;
main_body_x = -bearing_outer/2-min_material_thickness*1.5+main_body_width/2;
main_body_z = body_bottom_pos+bottom_thickness+main_body_height/2-0.05; // subtract 0.05 to avoid a hole in slic3r

// motor position
motor_y = mount_plate_thickness;
motor_z = body_bottom_pos+bottom_thickness+motor_side/2;
motor_x = -sqrt(pow(gear_dist,2)-pow(motor_z,2));


module position_motor() {
  translate([motor_x,motor_y,motor_z]) child(0);
}
