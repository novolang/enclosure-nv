# enclosure-nv

A printed circuit board needs a box. This package computes one from the facts of the board's KiCad file (read by [kicad-pcb-nv](https://novo-lang.org/packages/kicad-pcb-nv)) and a few parameters, and writes it as OpenSCAD text: a base with standoffs at the mounting holes, a lid held by screws or by a snap, an opening in the wall for every connector that faces an edge, and a window or a printed light pipe for every LED and a hole or a printed cap for every button.

The housing is a model of its own before it is text. The model has the levels along z, the standoffs, the openings and the printed parts as numbers, and the package checks it without a renderer: every opening lies in its wall, every standoff clears the parts, the lid closes over the tallest part with the headroom asked for, and every wall is at least two nozzle widths thick.

## Install

```
novo pkg add enclosure-nv
```

The package depends on [kicad-pcb-nv](https://novo-lang.org/packages/kicad-pcb-nv), [sexpr-nv](https://novo-lang.org/packages/sexpr-nv) and [stl-nv](https://novo-lang.org/packages/stl-nv). None of the three is published yet, so `novo.toml` names each by a sibling path, and the lines become registry ranges when they are.

## Example

```novo
use std.env
use std.fs
use kpcbread
use encparams
use encmodel
use encscad
use encchecks
use encbill

fn main() [io, fs]
    let args = env.args()
    match fs.read_bytes(args[1])
        None => println("cannot read ${args[1]}")
        Some(src) =>
            match kpcbread.read(src, args[1])
                Err(e) => println(e.message())
                Ok(b)  =>
                    var p = encparams.defaults()
                    p.name = "usbc"
                    let h = encmodel.build(b, p)
                    fs.mkdir_all(args[2])
                    for f in encscad.files(h)
                        fs.write("${args[2]}/${f.name}", f.text)
                        println("wrote ${f.name}")
                    println(encchecks.report(encchecks.run(h)))
                    for l in encbill.bill(h)
                        println("${l.part}: ${l.count} x ${encscad.num(l.x1 - l.x0)} x ${encscad.num(l.y1 - l.y0)} x ${encscad.num(l.z1 - l.z0)} mm, ${encscad.num(l.volume)} mm3")
```

On `tests/fixtures/usbc_board.kicad_pcb` in this package, a board of 30 by 20 mm with a USB-C connector on its left edge, a button, an LED, a resistor, a capacitor on the back and two mounting holes, the program writes three files and prints:

```
wrote usbc_base.scad
wrote usbc_lid.scad
wrote usbc_assembly.scad
ok  wall-min  every wall is at least 0.8 mm thick, the thinnest 1 mm
ok  feature-min  every opening and pin is at least 1 mm across
ok  opening-in-wall  1 wall opening(s), each in the straight part of its wall
ok  opening-in-plate  2 plate opening(s), each over the board
ok  post-clear  2 standoff(s) keep at least 0.4 mm from the parts
ok  screw-hole-fit  every mounting hole passes the 2.5 mm screw
ok  post-on-board  every standoff stands on the board
ok  lid-headroom  the lid leaves 1 mm over the tallest part, 3.3 mm
ok  bottom-headroom  the standoffs leave 2.2 mm under the tallest part, 0.8 mm
ok  in-cavity  every part without an opening is inside the wall
ok  screw-fit  an M2.5 x 10 screw fits, its hole 3.5 mm deep
ok  mount-holes  2 mounting hole(s)
ok  connector-reach  every connector can be reached
ok  heights-known  every part has a height
base: 1 x 35.8 x 25.8 x 11.3 mm, 4217.516 mm3
lid: 1 x 35.8 x 25.8 x 5.9 mm, 1991.22 mm3
screw M2.5 x 10: 2 x 0 x 0 x 0 mm, 0 mm3
```

The three files are in `tests/golden/usbc_screwed`. The parameters head each file, the openings are at the end of the base:

```
wall = 2.4;
floor_t = 2.4;
lid_t = 1.6;
clear = 0.5;  // the board's edge to the inside of the wall
...
module base() {
  difference() {
    union() {
      difference() {
        linear_extrude(height = z_split) offset(delta = clear + wall) outline();
        translate([0, 0, floor_t]) linear_extrude(height = z_split) offset(delta = clear) outline();
        ...
    // the openings
    translate([0, 8.6, z_bt + (-0.4)]) rotate([0, 0, 180]) translate([-1, -3.5, 0]) cube([clear + wall + 2, 7, 4.1]);
```

Open `usbc_assembly.scad` in OpenSCAD to see the base, the lid, the board and its parts as boxes in place. Open `usbc_base.scad` or `usbc_lid.scad` to export a mesh for the slicer. Set `print_flip = true` in the lid to lay its plate on the bed.

## What the housing is

The levels along z, from the underside of the base, are these.

| Level | Where it is |
| --- | --- |
| `floor_t` | The top of the floor and the foot of the standoffs. |
| `z_bb` | The board's underside, `floor_t` plus the space under the board. |
| `z_bt` | The board's front surface, and the foot of a lid pillar. |
| `z_step` | The top of the outer half of the wall. |
| `z_split` | `z_bt` plus the space over the board: the top of the inner half of the wall and the underside of the lid's plate. |
| `z_top` | `z_split` plus the lid's thickness. |

The wall has two halves side by side. The inner half, `wall / 2` thick, goes up to `z_split`. The outer half stops at `z_step`, `lip_h` lower, and the lid's skirt stands in its place, `lid_gap` clear of the rim. A screwed lid has a pillar over each mounting hole. One screw runs from the underside of the floor, through the standoff and the board's hole, and turns into the pillar's hole, so the screws hold the lid and the board together. A snap lid has a bead on the inside of its skirt that clicks into a groove in the rim, and the board is screwed from above into the standoffs' blind holes.

| Fact of the board | What the housing makes |
| --- | --- |
| Outline | The outline grown by `clear` is the cavity, and by `clear + wall` the outside. The corners are sharp offsets of the outline's own corners. |
| Mounting holes of at least `mount_min_drill` | A standoff and, for a screwed lid, a pillar, at the hole. A locating pin of a connector is smaller and has none. |
| Connector facing an edge | An opening in that wall, as wide as the courtyard along the wall and `opening_margin` more on each side, from below the board's surface to above the connector. It also notches the lid's skirt. |
| LED, button | A hole in the lid for a part on the front and in the floor for a part on the back; with `LedPipe` or `ButtonCap` a printed light pipe or cap as well. |
| Heights | The tallest part sets the space above the board, and the tallest on the back the space under it, each with its headroom. |

## Parameters

`encparams.defaults()` answers a `Params` whose fields are `var`, so a program sets the ones it wants.

| Field | Default | Meaning |
| --- | --- | --- |
| `wall`, `floor_t`, `lid_t` | 2.4, 2.4, 1.6 | Thicknesses. |
| `lid` | `LidScrewed` | `LidScrewed` or `LidSnap`. |
| `clear` | 0.5 | The board's edge to the inside of the wall. |
| `standoff_d`, `screw_d`, `pilot_d`, `head_d`, `head_h` | 6, 2.5, 2.1, 5, 1.6 | Standoff, screw thread, the hole the thread cuts, and the screw head. |
| `engage_min` | 3 | The least thread in plastic. |
| `standoff_h`, `top_space` | 0, 0 | Zero computes from the tallest part and its headroom. |
| `standoff_min`, `headroom_top`, `headroom_bottom` | 3, 1, 1 | The least space under the board, and the headroom on each side. |
| `opening_margin`, `post_clear`, `mount_min_drill` | 0.4, 0.4, 2 | Margin round an edge opening, the distance a standoff keeps from a part, and the smallest hole that takes a screw. |
| `lip_h`, `lid_gap`, `snap_depth`, `snap_h` | 3, 0.2, 0.4, 0.8 | The step, the lid's clearance, the bead. |
| `led`, `led_d`, `button`, `button_d` | `LedWindow`, 3, `ButtonHole`, 3 | What is made for LEDs and buttons, and their diameters. |
| `unknown_height` | 1 | What a part of no known height counts as. |
| `nozzle`, `min_feature` | 0.4, 1 | The nozzle, and the smallest opening or pin. |
| `extras` | none | Openings the board file does not imply: `lid_extra`, `floor_extra` and `side_extra`. |

## The checks

| Check | What fails it |
| --- | --- |
| `wall-min` | A wall, plate, rim, skirt or standoff wall under two nozzle widths. |
| `feature-min` | An opening, a pipe or a cap under `min_feature` across. |
| `opening-in-wall` | A wall opening with less than a wall's thickness to the corner, below the floor, or above the top of the wall. |
| `opening-in-plate` | A hole in the lid or the floor that is not over the board. |
| `post-clear` | A standoff nearer than `post_clear` to a part on the back, or a pillar nearer to a part on the front. |
| `screw-hole-fit` | A mounting hole narrower than the screw plus a tenth of a millimetre. |
| `post-on-board` | A standoff that overhangs the board's edge. |
| `lid-headroom`, `bottom-headroom` | Less room than the headroom asked for over the tallest part, or under the tallest on the back. |
| `in-cavity` | A part with no opening that reaches into the wall. |
| `screw-fit` | No standard screw long enough, or a hole deeper than the standoff or pillar leaves above its skin. |
| `mount-holes` | A board with no hole to hold it by. |
| `connector-reach` (warning) | A connector that faces no edge and under no extra opening. |
| `heights-known` (warning) | Parts with no height from a field, the table or a model. |

A warning does not fail a housing. `encchecks.passes` says whether any error failed.

## The bill

`encbill.bill` lists the base, the lid, each light pipe and cap, and the screws. A printed part has the bounding box and the volume of one copy, in the assembled position. The volumes are formulas over the model: the area of the outline grown by a distance, the polygon area of a cylinder, and the material each hole passes through. A mesh rendered from the text has the same box to a hundredth of a millimetre and the same volume to a fifth of a percent on the six variants of the tests. `encbill.mesh_report` makes that comparison for any mesh and any line of the bill.

## The OpenSCAD the text uses

The text keeps to modules without parameters, numeric variables and arithmetic on them, `polygon`, `linear_extrude`, `offset(delta = ...)`, `difference`, `union`, `translate`, `rotate`, `cube`, `cylinder` with `$fn`, `color` with four numbers, `use <file>`, and one `if` on a boolean variable. It has no function, loop, `include`, `import`, `hull`, `minkowski`, `text`, `scale` or `mirror`. A test scans the text of three variants for every call and every banned word.

Every file starts with the same block of parameters, the levels along z written as sums of them, and the heights of the openings written as sums of those levels. A change of a wall or a plate in the block moves the levels and the heights with it. The positions of the standoffs, the openings and the parts are numbers: a change of the board needs a new text. When a value changes in one file, change it in the others, or the assembly shows the parts apart.

## What is verified

The tests render every part of six variants with OpenSCAD 2021.01 headless, and fail on an error, a warning or a result that is not simple. They read the rendered meshes back with [stl-nv](https://novo-lang.org/packages/stl-nv) and compare each one's bounding box and volume with the bill. The variants are a screwed lid, a snap lid, pipes and caps with a lid hole, a floor hole and a wall slot, a board with rounded corners, a plain rectangle, and a board with cut-outs. The suite skips with a note when the OpenSCAD Flatpak is missing. The golden text of three variants is in `tests/golden`.

## What is not verified

- **A print on a real board.** No part was printed and no board was put in one. The tolerances are those of a 0.4 mm nozzle taken from the parameters: a gap of `lid_gap` between the lid and the wall, a `clear` between the board and the wall. A first print measures what a printer needs.
- **The heights.** A part's height comes from a `Height` field of its footprint or from the nominal table of kicad-pcb-nv, which is measured from the 3D models of the KiCad library and not from the parts bought. A part taller than its row breaks the headroom and the check does not see it.
- **The newer OpenSCAD.** The renders ran on 2021.01 with its CGAL backend. The subset above is old, and the text was not rendered by a later release or by the Manifold backend.
- **The snap.** The bead and the groove are sized by the parameters and the check of the walls. Whether a 1 mm skirt flexes enough to click, and holds after a few openings, is the first print's to say.
- **The screws.** The hole a screw cuts in the plastic is the `pilot_d` of 2.1 mm for M2.5, and the engagement is `engage_min`. A heat-set insert or a nut needs other parameters.
- **A board outline with a narrow notch.** The cavity is the outline grown by a distance with sharp corners. OpenSCAD closes a notch narrower than twice the distance, and the volumes of the bill do not.
- **Cut-outs of the board.** The housing's floor lies under a cut-out of the board. A board with a slot is drawn in the assembly and not cut into the base.
- **The antenna.** Nothing keeps plastic away from an antenna.

## What to check first

Render `usbc_assembly.scad` in OpenSCAD and look for parts in the wall and for a lid that does not sit on the step. Then print the base alone and put the board in it: it has `clear` all round, the standoffs sit in the holes, and a connector fills its opening with `opening_margin` to spare. Print the lid next, and close it. Change one parameter at a time from there.

## Tests

```bash
novo test tests/enc_model_tests.nv     # levels, standoffs, openings, pipes, caps, extras, screws, geometry
novo test tests/enc_checks_tests.nv    # every check on a sound board and on a board built to violate it
novo test tests/enc_scad_tests.nv      # golden text, the shared parameter block, the subset
novo test tests/enc_bill_tests.nv      # volumes worked out by hand, boxes, the mesh report
novo test tests/enc_render_tests.nv    # OpenSCAD renders and compares, skipped without it
bash tests/coverage.sh                 # line coverage over src/, merged across the suites
```

## Licence

Apache-2.0. See `LICENSE`.
