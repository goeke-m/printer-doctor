---
name: printer-doctor
description: Use when a 3D print fails or needs tuning - stringing, blobs or zits, warping, layer shifts, under-extrusion, clogs or jams, bad first layer, elephant foot, ghosting or ringing, poor bed adhesion, spaghetti, thermal runaway - or when dialing in a new filament or calibrating flow, pressure advance, input shaper, rotation distance, Z-offset, or delta geometry. Works from a user-maintained fleet file describing their actual machines.
license: MIT
metadata:
  version: "1.0.0"
---

# Printer Doctor

## Overview

Diagnose print defects and tune print quality against the machine actually in
the room. Most bad printer advice comes from reasoning about a generic printer,
or from a model name that stopped being accurate the moment someone modified,
converted, or repaired the machine.

Two rules prevent that:

**Read the fleet file before naming any part.** It records what each machine
really is.

**Change one variable, prove it with a test print, then change the next.** A
print that improves after five simultaneous changes teaches nothing about which
change mattered.

## Step 1 - Load the fleet file

**REQUIRED, every time, before writing a single word of diagnosis.**

1. Read the user's fleet file at **`$HOME/.printer-doctor/fleet.md`**. Expand
   `$HOME` (or `~`) to the actual home directory yourself - some file readers do
   not expand it, and a literal `~` will simply fail to resolve. This file is
   the user's own and takes priority over everything else.
2. Only if that file genuinely does not exist, read
   `references/fleet-template.md`, say plainly that no fleet file is set up yet,
   and offer to build one from a few questions. Diagnose generically in the
   meantime, and say that is what you are doing.

   The template is a blank form, not a description of anyone's machines. Never
   diagnose from it as though it were a fleet file.

**This skill does not bundle a `fleet.md`.** Do not look for one in
`references/` - the only file there is `fleet-template.md`. The real fleet file
lives in the user's home directory, deliberately, so that updating the skill
never overwrites their machines.

Find the machine and note its **traits** - kinematics, hotend cooling type,
probe type or absence, extruder type, toolhead wiring, nozzle material,
enclosure, firmware. The diagnostic files below branch on exactly these.

**Do not describe, name, or recommend adjusting a component until you have
confirmed the machine has it.** Telling someone to check a heatbreak fan on a
liquid-cooled hotend, or to run a bed mesh on a machine with no probe fitted,
sends them hunting for something that does not exist.

Where the fleet file and a live config disagree, **the config wins** - then
offer to update the fleet file. A stale fleet file is worse than none, because
it is trusted.

## Step 2 - Intake before diagnosis

Your first reply to a new problem **is** these four things, in this order:

1. **The machine**, plus the traits from the fleet file that bear on this
   symptom (one line, so the user can correct you if the file is stale).
2. **What you still need**: material and brand, nozzle and bed temps, speed,
   layer height, whether it is new behavior or longstanding, and - the question
   that resolves the most cases - *when* in the print it appears.
3. **Evidence you can read yourself.** On Klipper, RepRapFirmware, or any
   machine with a readable config, offer to read the config and the log. Logs
   hold MCU errors, shutdowns, thermal events, timing faults, and the values
   actually in force - which on a modified machine are frequently not the values
   anyone remembers setting. Ask for a photo of the defect for anything visual.
4. **Your leading hypothesis**, stated as a hypothesis.

Do not prescribe fixes in the same breath as asking what the settings are. If
the user has already supplied the facts, skip to Step 3.

## Step 3 - One change, one test print

Route to `references/symptoms.md` for a defect, or `references/calibration.md`
for tuning and new-filament dial-in.

Propose exactly **one** change at a time, and with it the cheapest test that
proves or kills the hypothesis. Order candidate causes cheapest-to-test first: a
10 degree temperature change and a 20 minute test print beat re-tramming a
gantry, even when the gantry is likelier.

When several causes are plausible, say which one you are testing and what result
sends you to the next. Give the user a decision, not a list.

## Quick reference

| Symptom | Go to |
|---|---|
| Stringing, blobs, zits, seams | `symptoms.md` - Extrusion artifacts |
| Under-extrusion, clogs, jams, clicking extruder | `symptoms.md` - Flow loss |
| First layer, adhesion, elephant foot, warping | `symptoms.md` - First layer and adhesion |
| Layer shifts, ghosting, ringing, VFA | `symptoms.md` - Motion |
| Bowed or dished first layer on a delta | `calibration.md` - Delta geometry |
| `Timer too close`, MCU lost, CAN dropouts | `symptoms.md` - Firmware and CAN |
| New filament dial-in, flow, PA, input shaper | `calibration.md` |
| General tuning procedure, or checking received wisdom | Ellis' Print Tuning Guide - linked at the top of `calibration.md` |

## Worked example

> "Under-extrudes then jams about 45 minutes in."

Fleet file says the hotend is **liquid-cooled**. A 45-minute onset means heat
soak, not a setting - settings fail at minute one.

Leading hypothesis: the cooling loop, because on this hotend that is the only
thing whose failure is time-dependent in this way. One question: is the pump
running and is the coolant above the ports? One test: run the same job with the
chamber door open. Reaches an hour, it is thermal; jams at 45 minutes again,
move to extruder tension and the nozzle.

Note what this does *not* say: nothing about heatbreak fans or shrouds, because
that trait says this hotend has neither. On an air-cooled machine the same
symptom, the same 45 minutes, sends you to the fan, the shroud, and the intake -
and that answer would be wrong here.

## Common mistakes

- **Reasoning from the model name.** Modified, converted, and repaired machines
  keep their old names. Read the fleet file, then the config.
- **Trusting stock documentation on a converted machine.** Manuals, forum
  threads, and factory profiles describe a different printer.
- **Shotgunning.** Five changes at once, print comes out fine, nothing learned.
- **Prescribing before intake.** Asking for current settings at the end of a long
  answer wastes the whole answer.
- **Treating co-occurring defects as one defect.** Stringing and blobs look
  related and are not: stringing is ooze during travel, blobs are pressure
  behavior at seams and direction changes. Separate them, fix them separately.
- **Ignoring the log.** It often just contains the answer.
- **Skipping the dumb causes.** Wet filament and a partly clogged nozzle imitate
  a dozen exotic problems. Rule them out before tuning anything.
- **Quoting constants from memory.** Rotation distance, PA, and shaper values are
  per-machine measurements. Run the procedure in `calibration.md`.
- **Re-suggesting something already ruled out.** The fleet file records negative
  findings. Read them.
