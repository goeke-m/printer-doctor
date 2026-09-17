# Fleet Template

Copy this to `~/.printer-doctor/fleet.md` and describe your real machines. That
file is read instead of this one, is never overwritten by an update, and is the
difference between advice for your printer and advice for a generic printer.

One entry per machine. Delete what does not apply. **Leave an item marked
UNCONFIRMED rather than guessing** - an unknown is safe, a wrong "fact" is not.

---

## Traits - the part that actually drives diagnosis

Record these explicitly for every machine. The diagnostic files branch on them,
so a missing trait means generic advice and a wrong trait means confident wrong
advice.

| Trait | Options | Why it matters |
|---|---|---|
| **Kinematics** | cartesian / bedslinger / CoreXY / delta / IDEX | Deltas have a geometry calibration layer nothing else has |
| **Hotend cooling** | air-cooled / liquid-cooled | Decides whether "check the heatbreak fan" is sound advice or nonsense |
| **Probe** | none / fixed / detachable / scanning (eddy, inductive, touch) | Decides whether mesh and probe-offset commands exist at all |
| **Auto mesh per print** | yes / no | If no, a saved mesh persists and geometry errors resurface |
| **Extruder** | direct drive / bowden (note length) | Sets the scale of retraction and pressure advance |
| **Toolhead wiring** | direct-wired / CAN | CAN adds a whole failure vocabulary |
| **Nozzle material** | brass / hardened steel / diamond-tipped | Diamond and hardened do not wear - never chase nozzle wear on them |
| **Axis motor count** | standard / doubled (AWD and similar) | Doubled motors can fight each other |
| **Enclosure** | none / passive / heated | Drives heat soak, warping, and PLA heat creep |
| **Firmware** | Klipper / Marlin / RRF / closed | Decides whether the config is readable |
| **Build surface(s)** | list each one held | Swapping surfaces moves Z, badly so with no probe |

---

## Machine entry template

## <Machine name>

| Subsystem | What it actually is |
|---|---|
| Kinematics | |
| Firmware / board / MCU | |
| Toolhead wiring | |
| Hotend (and **cooling type**) | |
| Nozzle (size and material) | |
| Extruder (and direct/bowden) | |
| Probe (or NONE) | |
| Part cooling | |
| Bed, surfaces held | |
| Heater / temp sensor | |
| Enclosure | |
| Build volume | |
| Filtration | |

### Non-obvious hardware

Anything that differs from what the model name implies. This section is the
whole point of the file: if the machine is modified, converted, or repaired,
its model name is actively misleading and stock documentation describes a
different printer. Spell out what is actually there.

### Known failure modes

Problems this machine has actually had, and what fixed them.

### Ruled out

Things already checked and eliminated, so they are not suggested again. Record
the negative findings - they are as valuable as the positive ones, and without
them every new session re-suggests the same dead ends.

### Still to confirm

Explicitly unknown items. Better an honest gap than an invented fact.

---

## Worked example of a non-obvious entry

> **Hotend:** Slice Mosquito Magnum Plus **Liquid** - water-cooled.
> **There is no heatbreak fan and no fan shroud.** Heat is carried by a pump,
> coolant, lines, and a radiator. The classic heat-creep symptom pattern applies
> here, but the causes share nothing with an air-cooled hotend: pump stalled,
> coolant low, **air pocket in the loop** (the pump still sounds normal),
> radiator fan dead or dust-blocked, kinked line.

That is the level of detail worth writing: the model name implies air cooling,
the truth is a pump, and a generic answer would send the user hunting for a fan
that does not exist.
