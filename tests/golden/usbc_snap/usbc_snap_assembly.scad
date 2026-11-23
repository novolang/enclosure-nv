// The assembly of the housing "usbc_snap", written by enclosure-nv 0.1.0
// from the board file usbc_board.kicad_pcb.  Render with OpenSCAD.
// Parameters, in millimetres.  The same block heads every file of this housing:
// when a value is changed, change it in each file.
wall = 2.4;
floor_t = 2.4;
lid_t = 1.6;
clear = 0.5;  // the board's edge to the inside of the wall
standoff_d = 6;
screw_d = 2.5;
pilot_d = 2.1;
head_d = 5;
head_h = 1.6;
lip_h = 3;  // the height of the step the lid sits on
lid_gap = 0.2;
snap_depth = 0.4;
snap_h = 0.8;
led_d = 3;
button_d = 3;
board_t = 1.6;
standoff_h = 3;  // the space under the board
top_space = 4.3;  // the space above the board
pilot_len = 3.9;  // the depth of the screw's hole
print_flip = false;  // true lays the lid plate down

// Levels along z.
z_bb = floor_t + standoff_h;
z_bt = z_bb + board_t;
z_split = z_bt + top_space;
z_step = z_split - lip_h;
z_top = z_split + lid_t;
z_skirt = z_step + lid_gap;
a_in = wall / 2;
screw_clear = screw_d + 0.3;

use <usbc_snap_base.scad>
use <usbc_snap_lid.scad>

module board_outline() {
  polygon(points = [[0, 0], [30, 0], [30, 20], [0, 20]]);
}

module board() {
  color([0.1, 0.55, 0.25, 0.8]) translate([0, 0, z_bb]) linear_extrude(height = board_t) difference() {
    board_outline();
  }
}

module parts() {
  color([0.75, 0.75, 0.75, 0.9]) {
    translate([-2.8, 5.5, 7]) cube([8.6, 6.2, 3.3]);  // J1
    translate([14.65, 11.65, 7]) cube([6.7, 4.7, 1.6]);  // SW1
    translate([16.55, 5.25, 7]) cube([2.9, 1.5, 1.1]);  // D1
    translate([20.52, 5.27, 7]) cube([2.96, 1.46, 0.45]);  // R1
    translate([10.52, 11.27, 4.6]) cube([2.96, 1.46, 0.8]);  // C1
  }
}

base();
lid();
board();
parts();
