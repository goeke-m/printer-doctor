# Symptom Trees

Causes are listed **cheapest-to-test first**, not likeliest first. Test one,
report, move on.

Branches below key on **traits** from the fleet file - hotend cooling, probe
type, kinematics, extruder, toolhead wiring, nozzle material. Read the machine's
entry before applying any of this. If a trait is unrecorded, ask rather than
assume.

Two causes imitate almost everything below. Rule them out before tuning:
**wet filament** (popping/hissing at the nozzle, rough surfaces, stringing that
no setting fixes, worse the longer the spool has been open) and a **partially
clogged nozzle** (inconsistent flow that looks like a dozen exotic problems).

---

## Extrusion artifacts

### Separate the defects first

Stringing and blobs co-occur and have different mechanisms. Fixing them as one
problem is how people chase their tails.

| Defect | Looks like | Mechanism |
|---|---|---|
| Stringing | Fine hairs spanning gaps | Ooze during travel moves |
| Blobs / zits | Bumps on the surface, often aligned in a seam | Pressure behavior at start/stop |
| Seam gaps | A visible groove or hole at layer seam | Retraction/PA at the seam specifically |
| Corner bulges | Swelling at direction changes | Pressure advance too low |

### Stringing

1. **Dry the filament.** PETG, TPU, nylon, PC especially. Non-negotiable first step.
2. **Nozzle temperature down in 5 degree steps.** Biggest lever.
   - *Trait - nozzle material:* a diamond-tipped or otherwise high-conductivity
     nozzle does not land on the same numbers as brass. Retune rather than
     porting values from a brass-nozzle guide.
3. **Retraction distance, then speed** - one at a time.
   - *Trait - extruder:* direct drive wants short retractions; bowden wants
     substantially more, scaled to tube length.
4. **Travel: avoid crossing walls, and Z-hop** if the nozzle drags through strings.
5. Only then: slicer coasting/wipe.

### Blobs, zits, seams

1. **Pressure advance.** The actual fix for bulges and seam artifacts. See
   `calibration.md`.
2. **Seam placement** - move it to a corner, or use scarf/staggered seams.
3. **Retraction at the seam** and wipe-on-retract.
4. **Over-extrusion** - verify flow before chasing anything else.

---

## Flow loss - under-extrusion, clogs, jams, clicking

### When it starts tells you what it is

This single question resolves most cases. Ask it first.

| Onset | Points at |
|---|---|
| Immediate, from layer one | Settings, flow, temperature, nozzle already clogged |
| Gradual over 30-60 min | Thermal - heat creep, chamber soak, cooling failure |
| At a specific height | Mechanical - Z binding, an obstruction, a cable snag |
| Random, intermittent | Filament path, spool tangle, moisture, partial clog |
| After a speed/flow increase | Genuine flow limit, or PA and temp not scaled with it |

### Gradual onset - the thermal path

**The right answer here depends entirely on the hotend cooling trait. Check the
fleet file before saying "fan".**

- *Trait - **liquid-cooled**:* there is **no heatbreak fan and no shroud**.
  Heat is rejected by a pump, coolant, lines, and a radiator. Check: pump
  stalled or unpowered, coolant level low, **air pocket in the loop** (the
  sneaky one - the pump still sounds perfectly normal), radiator fan dead,
  radiator dust-blocked, kinked or crushed line, coolant degraded. A leak here
  reaches electronics: if coolant is being lost, power down first.
- *Trait - **air-cooled**:* the classic path applies. Is the heatbreak fan
  actually spinning for the whole print, is the shroud seated and directing air
  at the fins, is the intake unobstructed, is the fan gunked or slowing.
- *Trait - **bowden**:* also inspect the PTFE path and the coupler at the hot
  end. A receding liner or a gap there backs filament up into the heat zone and
  imitates heat creep exactly.
- *Trait - **enclosure**:* chamber temperature climbing into the cold end causes
  heat creep in its own right, worst in a small enclosure on a long print.
  Cracking the door is a free diagnostic.

### Immediate onset

1. Temperature too low for the material, or for the flow being asked of it.
2. Flow limit - what mm3/s is the slicer demanding at this speed and layer
   height? *Trait:* a high-flow hotend has real headroom; a stock one does not.
   Do not diagnose a flow ceiling without knowing which you have.
3. Partial clog - cold pull, or inspect. *Trait - nozzle material:* be
   conservative with aggressive cold pulls on a diamond-tipped nozzle.
4. Extruder tension and filament path drag - spool binding, dry box friction,
   bowden tube wear at the coupler.

**Never chase nozzle wear on a hardened-steel or diamond-tipped nozzle.** Those
do not wear appreciably, including on abrasive filament. Sending a user down
that path wastes their time and a nozzle.

### Reading the aftermath

Pull the filament after a jam and look:

- **Swollen or deformed well above the melt zone** - heat creep. Cooling problem.
- **Ground flat, gouged, plastic dust in the gears** - the extruder was pushing
  against a blockage. This is a *symptom*; find what it was pushing against.
  Re-tensioning alone will not fix it.
- **Clean melted taper** - normal; the jam is downstream in the nozzle.

---

## First layer and adhesion

1. **Clean the plate.** Dish soap and water, then IPA. Skin oils beat every
   setting change. Free, do it first.
2. **Ask whether the build surface was swapped.** *Trait - surfaces held:* if
   the machine has more than one plate, different surfaces sit at different
   effective heights and behave differently for adhesion. **With no probe
   fitted there is nothing to absorb the difference and Z must be re-set by
   hand.** A first layer that broke suddenly usually broke because something
   changed, not because something drifted.
3. **Z-offset**, adjusted live during a first layer, one small step at a time.
4. **Heat soak.** Matters everywhere, and critically for probes that are
   temperature sensitive by design (eddy-current and inductive types). Probing
   cold gives a Z that walks during the print.
5. **Probe-specific checks** - *trait - probe type:*
   - *scanning / eddy-current:* the model is **bed-surface specific**. New
     sheet, new model. A stale model reads as a mystery Z error. Nozzle offset,
     probe model, and mesh are three separate things; the fault is in exactly one.
   - *inductive:* reads the metal plate, is affected by plate material and
     temperature, and will not see a non-metallic surface.
   - *detachable:* it must be physically attached before a mesh or calibration
     run and removed before printing. Forgetting either way is its own failure
     mode - ask which happened if there was a crash near homing or early layers.
   - ***none fitted:*** **do not suggest `BED_MESH_CALIBRATE`, `PROBE_ACCURACY`,
     `Z_OFFSET_APPLY_PROBE`, probe offsets, or mesh leveling at all.** There is
     no probe to run them with. First-layer work is manual: physical tramming, a
     hand-set Z endstop, live Z adjustment, paper or feeler gauge.
6. **Bed mesh** - re-run at printing temperature, if the machine has a probe.
   *Trait - auto mesh per print:* if it does not mesh automatically before each
   print, a saved mesh persists indefinitely, and a geometry error will resurface
   rather than being silently re-compensated. That recurrence is itself a clue.
7. **Delta only:** a first layer bowed or dished *across* the bed is geometry,
   not mesh. Go to `calibration.md` delta geometry. Meshing over it hides it.
8. First layer temp, speed, and squish - last, not first.

### Elephant foot
Z-offset slightly too low, or bed too hot for the material. Slicer elephant-foot
compensation is the cosmetic fix; treat it as a cover, not a cure.

### Warping and lifted corners
Chamber temperature and draft control, then bed temperature, then adhesion aids,
then brims. *Trait - enclosure:* a heated or passive enclosure is an asset here -
keep it shut. Recirculating filtration moves chamber air and nudges temperature.

---

## Motion - layer shifts, ghosting, ringing

### Layer shifts

1. **Something is obstructing travel** - a cable, a clip, a warped part corner
   the nozzle is striking. Watch a print; listen for the collision.
2. **Belt tension**, matched across the axis. *Trait - axis motor count:* on a
   doubled-motor axis (AWD and similar) that means **every belt path on the
   axis**, not just one side.
3. **Motor direction and wiring** - *trait - doubled motors:* a single reversed
   or mis-wired motor makes the pair fight itself. Lost steps under
   acceleration, poor surface finish, severity scaling with speed, sometimes an
   audible growl. Easy to miss, and it imitates weak motor current.
4. **Acceleration and velocity limits** too aggressive for the moving mass.
5. Stepper current and driver temperature.
6. Loose pulley grub screws, binding linear rails.
7. *Trait - suspended/flying extruder:* its tether can tug the toolhead,
   producing position-dependent artifacts that read like a motion fault.

### Ghosting, ringing, echoes after corners

Input shaper, then acceleration. See `calibration.md`.

**Do not port shaper values between machines**, or from a stock build to a
modified one. A changed gantry, toolhead mass, or motor count has its own
resonance profile.

Mechanical slop, loose belts, and a loose frame all defeat input shaper. Shaper
compensates for resonance; it does not compensate for a loose machine.

---

## Firmware and CAN

*Trait - firmware:* on Klipper, RepRapFirmware, or anything with a readable log,
**read the log first**. It holds the actual error, the actual config values, and
what happened just before a shutdown.

| Error | Usually means |
|---|---|
| `Timer too close` | Host overloaded, or MCU communication problems. Suspect the CAN link first if there is one. |
| `Lost communication with MCU` | CAN wiring, termination, bitrate mismatch, power, or a failing board |
| `Move exceeds maximum extrusion` | Flow or extrusion limits vs what the slicer is asking |
| `Heater not heating at expected rate` | Loose heater/thermistor wiring, a failed cartridge, or part cooling spilling onto the heater block |
| `ADC out of range` | Thermistor disconnected or failing. **Check the sensor type first** - a thermocouple is read through a MAX31855/MAX6675-class amplifier over SPI and fails at the amplifier or the SPI link instead. |

### CAN toolhead specifics

*Trait - toolhead wiring = CAN:*

- Confirm the node comes up and its UUID matches the config.
- Bitrate must match end to end - board, host interface, and config.
- Termination: the bus wants a 120 ohm resistor at each end, exactly two total.
- Toolhead wiring flexes every single move. Intermittent dropouts that worsen
  over time, or correlate with position, are a cable failing in a drag chain
  until proven otherwise. A suspended extruder adds a second moving tether.
- Do not tune print settings to work around CAN dropouts. Fix the bus.

### Electrical history

If the fleet file records **previous board or component failures**, weigh that
before blaming firmware or config for anything electrical. Check wiring,
chafing in moving looms, shorts, PSU voltage and grounding.

**A general caution worth giving on any machine:** hand-moving a gantry or
spinning an extruder gear turns the stepper into a generator, and that voltage
returns through the driver into the supply rail. Move axes slowly and
deliberately, and never whip one across its travel with the printer powered off.
It is a known way to kill a board.
