include <BOSL/constants.scad>
use <BOSL/shapes.scad>

// Which one would you like to see?
part = "both"; // [box:Box only, top: Top cover only, both: Box and top cover]

// Size of your printer's nozzle in mm
nozzle_size = 0.4;

// Number of walls the print should have
number_of_walls = 4; // [1:5]

// Tolerance (use 0.2 for FDM)
tolerance = 0.2; // [0.1:0.1:0.4]

// Outer x dimension in mm
x=40;

// Outer y dimension in mm
y=40;

// Outer z dimension in mm
z=40;

// Radius for rounded corners in mm
radius=5; // [1:20]

/* Hidden */
$fn=100;
wall_thickness=nozzle_size*number_of_walls;
hook_thickness = 3*nozzle_size;

top_cover_wall_thickness = hook_thickness + wall_thickness;

module bottom_box_main () {
    difference(){
        // Solid box
        linear_extrude(z-wall_thickness){
            minkowski(){
                square([x-radius*2,y-radius*2], center=true);
                circle(radius, center=true);
            }
        }
        
        // Hollow out
        translate([0,0,wall_thickness]) linear_extrude(z){
            minkowski(){
                square([x-radius*2-wall_thickness*2+wall_thickness*2,y-radius*2-wall_thickness*2+wall_thickness*2], center=true);
                circle(radius-wall_thickness);
            }
        }
    }
    left_hook(); // left hook
    rotate([180,180,0]) left_hook(); // right hook
    front_hook(); // front hook
    rotate([180,180,0]) front_hook(); // back hook
    // TODO: hooks on the other two sides
}

module bottom_box() {
    difference() {
        union() {
            bottom_box_main();
            board_surround();
        }
        usb_cutout();
    }
}

module board_surround() {
    board_riser_shape = [21, 19, 4];
    
    translate([x / 2 - board_riser_shape.x / 2 - wall_thickness, 0, wall_thickness + 0.9]) {
        difference() {
            cuboid([board_riser_shape.x * 1.1,
                    board_riser_shape.y * 1.1,
                    board_riser_shape.z * 0.8]);
            cuboid(board_riser_shape);
            translate([board_riser_shape.x / 2, 0, 0]) {
                cuboid([board_riser_shape.x * 0.2,
                        board_riser_shape.y,
                        board_riser_shape.z]);
            }
        }
    }
}

module usb_cutout() {
    board_thickness = 3 * 0.5;
    port_extension = 3 * 0.5;
    board_inset = wall_thickness - port_extension;
    
    usb_cutout_shape = [9.5, 9.5, 3.3];
    fillet=1.5;
    
    translate([x / 2, 0, wall_thickness + board_thickness * 1.1 + usb_cutout_shape.z * 0.5 + fillet]) {
        cuboid(usb_cutout_shape, fillet=fillet, edges=EDGES_ALL);
    }
    
    board_cutout_shape = [2, 19, board_thickness * 1.1];
    
    translate([x / 2 - board_cutout_shape.x, 0, wall_thickness + board_thickness * 1.1]) {
        cuboid(board_cutout_shape);
    }
}

module left_hook () {
    translate([(x-2*wall_thickness)/2,-y/2+radius*2,z-wall_thickness]) rotate([0,90,90]) linear_extrude(y-2*radius*2){
    polygon(points=[[0,0],[2*hook_thickness,0],[hook_thickness,hook_thickness]], center=true);
    }
}


module front_hook () {
    translate([(-x+4*radius)/2,-y/2+wall_thickness,z-wall_thickness]) rotate([90,90,90]) linear_extrude(x-2*radius*2){
    polygon(points=[[0,0],[2*hook_thickness,0],[hook_thickness,hook_thickness]], center=true);
    }
}


module right_grove () {
    translate([-tolerance/2+(x-2*wall_thickness)/2,-y/2+radius,wall_thickness+hook_thickness*2]) rotate([0,90,90]) linear_extrude(y-2*radius){
    polygon(points=[[0,0],[2*hook_thickness,0],[hook_thickness,hook_thickness]], center=true);
    }
}


module front_grove () {
    translate([(-x+2*radius)/2,-y/2+wall_thickness+tolerance/2,wall_thickness+hook_thickness*2]) rotate([90,90,90]) linear_extrude(x-2*radius){
    polygon(points=[[0,0],[2*hook_thickness,0],[hook_thickness,hook_thickness]], center=true);
    }
}

module top_cover_main () {

    // Top face
    linear_extrude(wall_thickness){
        minkowski(){
            square([x-radius*2,y-radius*2], center=true);
            circle(radius, center=true);
        }
    }
    
    difference(){
        // Wall of top cover
        linear_extrude(wall_thickness+hook_thickness*2){
            minkowski(){
                square([x-radius*2-wall_thickness*2-tolerance+wall_thickness*2,y-radius*2-wall_thickness*2-tolerance+wall_thickness*2], center=true);
                circle(radius-wall_thickness, center=true);
            }
        }
        
        // Hollow out
        // TODO: If radius is very small, still hollow out

        translate([0,0,wall_thickness]) linear_extrude(z){
            minkowski(){
                square([x-radius*2-wall_thickness*2-2*top_cover_wall_thickness-tolerance+wall_thickness*2+top_cover_wall_thickness*2,y-radius*2-wall_thickness*2-2*top_cover_wall_thickness-tolerance+wall_thickness*2+top_cover_wall_thickness*2], center=true);
            circle(radius-wall_thickness-top_cover_wall_thickness);
            }
        }
    right_grove();
    rotate([180,180,0]) right_grove();
    front_grove();
    rotate([180,180,0])  front_grove();
    }
  

}

module top_cover() {
    difference() {
        top_cover_main();
        // Button hole
        translate([0,0,-wall_thickness * 2]) {
            linear_extrude(wall_thickness * 4){
                circle(15, center=true);
            }
        }
    }
}

print_part();

module print_part() {
	if (part == "box") {
		bottom_box();
	} else if (part == "top") {
		top_cover();
	} else if (part == "both") {
		both();
	} else {
		both();
	}
}

module both() {
	translate([0,-(y/2+wall_thickness),0]) bottom_box();
    
    
    translate([0,+(y/2+wall_thickness),0]) top_cover();
}