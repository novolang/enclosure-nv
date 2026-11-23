// The lid of the housing "usbc_screwed", written by enclosure-nv 0.1.0
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
pilot_len = 3.5;  // the depth of the screw's hole
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

module outline() {
  polygon(points = [[0, 0], [30, 0], [30, 20], [0, 20]]);
}

module lid() {
  difference() {
    union() {
      // the plate
      translate([0, 0, z_split]) linear_extrude(height = lid_t) offset(delta = clear + wall) outline();
      // the skirt that takes the place of the outer half of the wall
      translate([0, 0, z_skirt]) linear_extrude(height = z_split - z_skirt + 0.2) difference() {
        offset(delta = clear + wall) outline();
        offset(delta = clear + a_in + lid_gap) outline();
      }
      // the pillars the screws turn into
      translate([26.5, 16.5, z_bt]) cylinder(h = z_split - z_bt + 0.2, d = standoff_d, $fn = 32);
      translate([26.5, 3.5, z_bt]) cylinder(h = z_split - z_bt + 0.2, d = standoff_d, $fn = 32);
    }
    // the screws' holes
    translate([26.5, 16.5, z_bt - 1]) cylinder(h = pilot_len + 1, d = pilot_d, $fn = 32);
    translate([26.5, 3.5, z_bt - 1]) cylinder(h = pilot_len + 1, d = pilot_d, $fn = 32);
    // the openings
    translate([0, 8.6, z_bt + (-0.4)]) rotate([0, 0, 180]) translate([-1, -3.5, 0]) cube([clear + wall + 2, 7, 4.1]);
    translate([18, 14, z_split - 1]) cylinder(h = lid_t + 2, d = 3, $fn = 32);
    translate([18, 6, z_split - 1]) cylinder(h = lid_t + 2, d = 3, $fn = 32);
  }
}

if (print_flip) {
  translate([0, 20, z_top]) rotate([180, 0, 0]) lid();
} else {
  lid();
}
