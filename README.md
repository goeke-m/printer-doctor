# printer-doctor

A skill for diagnosing 3D print defects and tuning print quality, for use with
Claude Code and any other agent runtime that reads [Agent
Skills](https://agentskills.io/specification).

## Why

Most bad printer advice comes from reasoning about a *generic* printer - or from
a model name that stopped being accurate the moment the machine was modified,
converted, or repaired. Ask an assistant about a jam on a printer with a
liquid-cooled hotend and it will confidently tell you to check the heatbreak fan,
which that hotend does not have.

This skill fixes that by reading a **fleet file** you maintain, describing what
your machines actually are. Diagnosis branches on hardware *traits* - hotend
cooling, probe type or absence, kinematics, extruder, toolhead wiring, nozzle
material - not on model names.

It also enforces two habits that matter more than any individual tip:

- **Intake before diagnosis.** No prescribing fixes while still asking what the
  settings are.
- **One change, one test print.** A print that improves after five simultaneous
  changes teaches you nothing about which change mattered.

## Install

### Claude Code (plugin)

```
/plugin marketplace add <owner>/printer-doctor
/plugin install printer-doctor@printer-doctor
```

To develop against it locally:

```
claude --plugin-dir ./plugins/printer-doctor
```

### Any other runtime

```
./install.sh
```

Symlinks the skill into `~/.claude/skills/` and `~/.agents/skills/` - the latter
is read by Codex, Copilot CLI and Gemini CLI - so `git pull` updates every
runtime at once. It also seeds your fleet file if you do not have one.

## Your fleet file

Lives at `~/.printer-doctor/fleet.md`, **outside this repo**. It is never
overwritten by an update and never published here.

Start from `plugins/printer-doctor/skills/printer-doctor/references/fleet-template.md`
and describe each machine. The template's trait table is the important part -
the diagnostic files branch on exactly those traits, so a missing trait means
generic advice and a wrong trait means confident wrong advice.

Three sections earn their keep over time:

- **Non-obvious hardware** - anything that differs from what the model name
  implies.
- **Ruled out** - things already checked and eliminated, so they are not
  suggested again. Negative findings are as valuable as positive ones.
- **Still to confirm** - honest gaps. An unknown is safe; an invented fact is not.

## Structure

```
plugins/printer-doctor/skills/printer-doctor/
├── SKILL.md                        # router: fleet file -> intake -> one change, one test
└── references/
    ├── symptoms.md                 # defect trees, ordered cheapest-to-test
    ├── calibration.md              # the tuning ladder, delta geometry
    └── fleet-template.md           # trait vocabulary + machine template
```

## Credit

For general tuning procedure, this skill defers to
[Ellis' Print Tuning Guide](https://ellis3dp.com/Print-Tuning-Guide/), which is
the best reference of its kind. The division of labour: Ellis owns procedure,
your fleet file owns hardware.

## License

MIT
