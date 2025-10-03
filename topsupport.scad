base_radius        = 6 * 25.4;       // hex flat-to-flat in mm
base_thickness     = 3;              // base thickness
rail_width         = 25;             // rail width
rail_height        = 3;              // rail thickness
rail_offset        = 1 * 25.4;       // height of rails above base
hole_radius        = 4 * 25.4;       // motor central hole radius (for rails connector)
connector_thickness= 5;              // hollow cylinder shell thickness

center_disk_radius = 25;             // central disk radius
motor_hole_radius  = 7;              // motor shaft hole radius
mount_screw_radius = 1.5;            // mounting screw radius (~M3)
mount_screw_dist   = 16;             // distance from center to screws

vent_height_above_base = 4.5 * 25.4;      // 4 inches above hex vertices
vent_outer_radius      = 3.3 * 25.4;// vent outer radius
vent_hollow_radius     = 0.2 * 25.4;// vent hollow radius
vent_length            = 25.4*4;     // vent length along X
vent_offset            = 25; // vent offset?
vent_total_offset            = 25; // vent total offset?
vent_lateral_offset = 1* 25.4;

crossbar_radius        = 2.5;        // crossbar radius
crossbar_distance_above_vent = 0;     // adjust if needed

support_width   = 10;                // width of support beams
support_thickness = 3;               // thickness of support beams
module top_cross_strut() {
    x1 = base_radius - vent_lateral_offset;
    x2 = -base_radius + vent_lateral_offset;
    y  = vent_total_offset + rail_width; 
    z  = base_thickness + vent_height_above_base + vent_length - rail_height; 

        cube([ (x1 - x2)+20, rail_width, rail_height ]);
}
top_cross_strut();