// ==========================
// Hovercraft Base Parameters
// ==========================
base_radius        = 6 * 25.4;       // hex flat-to-flat in mm
base_thickness     = 3;              // base thickness
rail_width         = 25;             // rail width
rail_height        = 3;              // rail thickness
rail_offset        = 1 * 25.4;       // height of rails above base
hole_radius        = 4.2 * 25.4;       // motor central hole radius (for rails connector)
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

// ==========================
// Hex Base Points
// ==========================
hex_points = [ for(i=[0:5]) [ base_radius*(cos(i*60 + 30)), base_radius*(sin(i*60 + 30)) ] ];

// ==========================
// Modules
// ==========================

// Hex base with central hole
module hex_base() {
    difference() {
        linear_extrude(height=base_thickness)
            polygon(hex_points);
        translate([0,0,-1])
            cylinder(h=base_thickness+2, r=hole_radius, $fn=100);
    }
}

// Rails clipped to hex
module rails_clipped() {
    intersection() {
        union() {
            translate([-hole_radius, -rail_width/2, rail_offset])
                cube([hole_radius-center_disk_radius+5, rail_width, rail_height]);
            translate([-rail_width/2, -hole_radius, rail_offset])
                cube([rail_width, hole_radius-center_disk_radius+5, rail_height]);
            translate([center_disk_radius-5, -rail_width/2, rail_offset])
                cube([hole_radius-center_disk_radius+5, rail_width, rail_height]);
            translate([-rail_width/2, center_disk_radius-5, rail_offset])
                cube([rail_width, hole_radius-center_disk_radius+5, rail_height]);
        }
    }
}

// Hollow connector cylinder for rails
module hollow_connector() {
    difference() {
        cylinder(h=rail_offset+rail_height, r=hole_radius+connector_thickness, $fn=100);
        translate([0,0,-1])
            cylinder(h=rail_offset+rail_height+2, r=hole_radius, $fn=100);
    }
}


// Center disk with motor mount and screws
module center_disk_union() {
    difference() {
        cylinder(h=rail_height, r=center_disk_radius, $fn=100);
        translate([0,0,-1])
            cylinder(h=rail_height+2, r=motor_hole_radius, $fn=50);
        for (angle=[0,90,180,270]) {
            translate([mount_screw_dist*cos(angle), mount_screw_dist*sin(angle), -1])
                cylinder(h=rail_height+2, r=mount_screw_radius, $fn=20);
        }
    }
}

// Reinforced vent duct with rails, crossbars, and motor mount
module vent_duct(pos=[0,0,0], rot=[90,0,0]) {
    translate(pos)
        rotate(rot)
            union() {
                // Hollow cylinder
                difference() {
                    cylinder(h=vent_length, r=vent_outer_radius, $fn=50);
                    translate([0,0,-1])
                        cylinder(h=vent_length+2, r=vent_outer_radius-vent_hollow_radius, $fn=50);
                }
                translate([0, 0, vent_offset])
                    // Rails inside cylinder
                    intersection() {
                        union() {
                            translate([-vent_outer_radius+vent_hollow_radius, -rail_width/2, 0])
                                cube([vent_outer_radius-vent_hollow_radius-center_disk_radius+5, rail_width, rail_height]);
                            translate([-rail_width/2, -vent_outer_radius+vent_hollow_radius, 0])
                                cube([rail_width, vent_outer_radius-vent_hollow_radius-center_disk_radius+5, rail_height]);
                            translate([center_disk_radius-5, -rail_width/2, 0])
                                cube([vent_outer_radius-vent_hollow_radius-center_disk_radius+5, rail_width, rail_height]);
                            translate([-rail_width/2, center_disk_radius-5, 0])
                                cube([rail_width, vent_outer_radius-vent_hollow_radius-center_disk_radius+5, rail_height]);
                        }
                    }
                    // Center disk on vent
                    translate([0,0,vent_offset])
                        difference() {
                            cylinder(h=rail_height, r=center_disk_radius, $fn=100);
                            translate([0,0,-1])
                                cylinder(h=rail_height+2, r=motor_hole_radius, $fn=50);
                            for(angle=[0,90,180,270]){
                                translate([mount_screw_dist*cos(angle), mount_screw_dist*sin(angle), -1])
                                    cylinder(h=rail_height+2, r=mount_screw_radius, $fn=20);
                            }
                        }
            }
}

// Support strut connecting vent duct to base
module support_strut() {
    translate([-sqrt(3)*base_radius/2, -vent_length/2 - 0.8, 0])
        cube([10, vent_length, vent_height_above_base - vent_outer_radius + vent_hollow_radius]);

    translate([sqrt(3)*base_radius/2 - 10, -vent_length/2 - 0.8, 0])
        cube([10, vent_length, vent_height_above_base - vent_outer_radius + vent_hollow_radius]);}

module top_cross_strut() {
    x1 = base_radius - vent_lateral_offset;
    x2 = -base_radius + vent_lateral_offset;
    y  = vent_total_offset + rail_width; 
    z  = base_thickness + vent_height_above_base + vent_length - rail_height; 

    translate([x2, y - rail_width/2, z])
        cube([ (x1 - x2)+20, rail_width, rail_height ]);
}
// ==========================
// Assembly
// ==========================
union() {
    hex_base();
    rails_clipped();
     hollow_connector();
    translate([0,0,rail_offset])
        center_disk_union();
    // Two vent ducts at opposite vertices
     vent_duct(pos=[base_radius - vent_lateral_offset,vent_total_offset+rail_width,base_thickness + vent_height_above_base]);
    vent_duct(pos=[-base_radius + vent_lateral_offset,vent_total_offset+rail_width,base_thickness + vent_height_above_base]);

    // Supports from base vertices to vent ducts
     support_strut();
    top_cross_strut();
}
