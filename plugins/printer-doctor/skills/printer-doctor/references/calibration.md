# Calibration and Tuning

## The ladder - order is not optional

Each rung assumes the ones below it are true. Tuning pressure advance on a
machine with loose belts measures the belts. If someone asks to skip to input
shaper, ask what rung they last verified.

```
8. Speed and acceleration          <- last, and only after 1-7
7. Input shaper
6. Pressure advance
5. Flow / extrusion multiplier
4. Temperature
3. Rotation distance (E steps)
2. Z-offset and bed mesh
1. Mechanical: frame, belts, rails, gantry/delta geometry
```

### Ellis' Print Tuning Guide - the outside authority

<https://ellis3dp.com/Print-Tuning-Guide/>

The best general tuning reference available, and a good fit for this fleet
because it covers Klipper directly (alongside Marlin, RepRapFirmware and
Voron-specific material). Prefer its procedures over anything improvised here.

Its tuning order: Extruder Calibration, Build Surface Preparation, First Layer
Squish, Pressure Advance, Extrusion Multiplier, PA/EM Oddities, Cooling and
Layer Times, Retraction, Infill/Perimeter Overlap, Stepover. Then Advanced
Tuning for volumetric flow rate, motor currents, and speeds and accelerations.
It also carries a Troubleshooting section and a **Misconceptions & Bad Advice**
section that is worth reading before repeating any common wisdom.

**Where it and the ladder below disagree, follow Ellis.** One real divergence:
this ladder puts flow (rung 5) before pressure advance (rung 6); Ellis tunes
**pressure advance first, then extrusion multiplier**, and devotes a whole page
to how the two interact. Use his order and iterate between them.

The division of authority: **Ellis owns procedure, the fleet file owns
hardware.** His guide cannot know that a given hotend is liquid-cooled, that a
machine has no probe fitted, or that a probe must be attached by hand.
Machine-specific constraints in the fleet file always win over a general
procedure.

---

**Measure, never quote.** Rotation distance, PA, and shaper values are
properties of a specific machine on a specific day. Numbers from a forum, from a
stock build, or from memory are starting points at best and wrong at worst -
especially on a modified or converted machine.

---

## 1. Mechanical

Belts tensioned and matched across an axis - on the AWD gantry that means both
belt paths per axis. Pulley grub screws tight on a flat. Rails clean, no
binding. Frame square. Nothing loose in the toolhead.

*Trait - axis motor count:* on a doubled-motor axis, tension and match **every**
belt path on that axis, and verify each motor's direction and wiring.

*Trait - multiple independent Z motors:* level them first (`Z_TILT_ADJUST`,
`QUAD_GANTRY_LEVEL`, or the machine's equivalent) before anything Z-related.

*Trait - delta:* geometry section below, which sits at this rung.

Verify before tuning: `PROBE_ACCURACY` and a few repeat homes, if the machine
has a probe. If results scatter, nothing above this rung is measurable yet.
With no probe, check that homing repeats to the same height instead.

## 2. Z-offset and bed mesh

Heat soak the machine first - always, and non-negotiable for eddy-current or
inductive probes, which are temperature sensitive by design.

- *Trait - scanning/eddy-current probe:* calibrate the model, and recalibrate
  for each bed surface. Nozzle offset, probe model, and mesh are three separate
  things; a first-layer problem lives in exactly one of them.
- *Trait - detachable probe:* attach it before the run, confirm it is seated,
  and remember to remove it before printing.
- *Trait - **no probe fitted**:* no mesh, no `PROBE_ACCURACY`, no probe offset.
  Tram the bed physically, set the Z endstop by hand, adjust live on a first
  layer. This rung is entirely manual.
- `BED_MESH_CALIBRATE` at printing temperature, not cold.
- Live-adjust Z during a first layer, then persist it - `Z_OFFSET_APPLY_PROBE`
  and `SAVE_CONFIG`, or the machine's equivalent.

## 3. Rotation distance

Measure it. Do not quote a number from memory, and do not assume two extruders
of the same model match each other.

1. Heat the hotend, mark the filament 120mm above the extruder inlet.
2. Extrude 100mm slowly (`G1 E100 F60`).
3. Measure the remaining distance to the inlet. Actual extruded = 120 - measured.
4. `new = old * (actual / 100)`
5. Update `rotation_distance`, `SAVE_CONFIG`, repeat once to confirm.

Slow extrusion matters - fast extrusion measures flow limits instead.

## 4. Temperature

Temp tower, or `TUNING_TOWER` driving `SET_HEATER_TEMPERATURE`. Judge on layer
adhesion and surface finish, not looks alone - break the tower afterward.

*Trait - nozzle material:* a diamond-tipped or other high-conductivity nozzle
will not land on the same numbers as brass for the same filament. Retune per
filament on that machine rather than porting values across a fleet.

## 5. Flow

Klipper has no built-in flow calibration. Either:

- Print a single-wall cube, measure wall thickness with calipers at several
  points, and scale the extrusion multiplier by `nominal / measured`; or
- Use the slicer's flow calibration (Orca's is good, and it works fine against
  Klipper machines).

Over-extrusion masquerades as blobs, poor dimensional accuracy, and rough top
surfaces. Get this right before touching PA.

## 6. Pressure advance

Fixes bulging corners, seam blobs, and gaps at the start of perimeters.

```
TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.005
```

Print a tall square-ish test object, find the height where corners are sharpest
without gaps, compute `START + height * FACTOR`, then
`SET_PRESSURE_ADVANCE ADVANCE=<value>` to confirm before saving.

- PA is **per filament**, and materially different between PLA, PETG, and TPU.
- *Trait - bowden:* scale to the real tube length. A suspended or shortened
  bowden path sits between direct-drive and long-bowden values, well below what a
  guide for the stock machine quotes.
- Retune after changing nozzle, hotend, or extruder.

## 7. Input shaper

Needs an accelerometer. If the toolhead board or probe provides one, use it;
otherwise measure by printing a ringing tower and reading the frequency.

```
TEST_RESONANCES AXIS=X
TEST_RESONANCES AXIS=Y
SHAPER_CALIBRATE
SAVE_CONFIG
```

- Remeasure after changing toolhead mass, belts, or gantry.
- **Values are specific to the machine as built.** A modified gantry, a doubled
  motor count, or a suspended extruder all change the resonance profile; numbers
  from the stock version of the same printer do not transfer.
- Shaper cannot fix mechanical slop. If recommended frequencies are implausibly
  low, or results vary run to run, go back to rung 1.

## 8. Speed and acceleration

Only now. Raise acceleration until quality degrades or the machine complains,
then back off with margin. Watch for the flow ceiling - past a point the
limiting factor is mm3/s through the hotend, not motion. *Trait - hotend:* a
high-flow hotend has real headroom here; a stock one has much less.

Re-verify PA after a large speed change.

---

## Delta geometry (trait: delta kinematics)

Deltas have a calibration layer cartesians do not, and it sits at rung 1 -
*below* bed mesh. Meshing over a geometry error hides it until it returns.

**Read the signature in the first layer:**

| First layer across the bed | Points at |
|---|---|
| High in the center, low at edges (convex) | Delta radius too small |
| Low in the center, high at edges (concave) | Delta radius too large |
| One region consistently off, others fine | That tower's endstop offset or angle |
| Good center, distortion only near one tower | Tower angle / arm length |

**Procedure:**

1. **Attach the probe if it is detachable**, confirm it is seated, and remember
   to remove it before printing.
2. Equalize belt tension across all three towers first. Unequal tension produces
   position-dependent error that no calibration will resolve.
3. Check arms and ball joints for slop. Any play makes calibration
   unrepeatable - fix the mechanics first.
4. `DELTA_CALIBRATE` in Klipper, then the enhanced calibration pass (printing
   and measuring a test object) for arm length and finer geometry.
5. `SAVE_CONFIG`.
6. *Then* bed mesh, if still wanted. *Trait - auto mesh per print:* if the
   machine does not mesh before each print, what you save is what it prints
   with, indefinitely.

Bowden note: scale retraction and pressure advance to the **actual tube length**,
not to the machine's stock configuration. A shortened or suspended-extruder
conversion lands well below stock long-bowden values. Check the tether too: if it
tugs the effector, it produces position-dependent artifacts that imitate a
geometry error and will corrupt calibration results.

---

## Dialing in a new filament

Short path, in order. Stop when the print is good.

1. Dry it if there is any doubt. Nothing below works on wet filament.
2. Manufacturer temperature range as the starting point, then a temp tower.
3. Flow check on a single-wall cube.
4. Pressure advance for that filament.
5. Retraction only if stringing persists after temperature is right.
6. Cooling: more for PLA, less for ABS/ASA, moderate for PETG.

Save the result per filament, per machine. The same spool legitimately needs
different numbers on different machines - that is expected, not an error.
