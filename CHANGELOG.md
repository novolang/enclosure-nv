# Changelog

All notable changes to enclosure-nv are recorded here. The format is
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
package follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
with the pre-1.0 rule that a breaking change bumps the MINOR number.

## [0.1.0] — 2026-11-23

### Added

- `encparams`: the parameters of a housing, with defaults for a 0.4 mm nozzle and M2.5 screws, three modes for the lid, the LEDs and the buttons, and constructors for extra openings in the lid, the floor and the wall.
- `encmodel`: the housing as a model: levels along z, standoffs and pillars at the mounting holes, openings for connectors at an edge, windows and light pipes for LEDs, holes and caps for buttons, and a block for every part.
- `encscad`: OpenSCAD text, one file per part and an assembly, with the parameters at the top of each file and the levels written as sums of them.
- `encchecks`: fourteen checks of the model made without a renderer, twelve errors and two warnings.
- `encbill`: the bill of the printed parts with bounding boxes and volumes, the screws, and `mesh_report`, which compares a rendered mesh with a line of the bill.

### Known

- `kicad-pcb-nv`, `sexpr-nv` and `stl-nv` are sibling paths in `novo.toml` until they are published; `novo pkg publish` refuses a path.
- The text was rendered with OpenSCAD 2021.01 only.
