# Temporary animal blasts (2026-11-01)

Owner directly requested four random double-click reactions on existing animals.
Base `1cc1469`, clean working tree. This is one bounded owner request; no numbered
roadmap task or human gate advances. Stop after this interaction.

## Behavior and ownership

In world mode, double-click a visible animal within 20m. Each outcome has a 25%
chance, with a separate randomized stream from ordinary wandering. A busy animal
ignores repeat clicks; separate animals may have concurrent effects.

- **Lightning-Blast (1.8s):** jagged sky bolt, temporary charcoal coat, 0.85m
  startled jump and accelerated wandering, then ordinary coat and behavior.
- **Fire-Blast (5s):** one-second red player beam, bright red eye meshes mounted
  at the model's authored eye centers, navigation toward the nearest companion
  and animated eye-fire when close with an unobstructed line of sight.
- **Cyclone-Blast (3.4s):** descending tapered translucent funnel and helical
  wind, a 2.5m lift with spinning/tilting, then a controlled drop.
- **Love-Blast (5s):** one-second pink beam with soft drifting smoke hearts,
  pursuit of the nearest companion, then head/tongue licking attempts nearby.

Fire/love select the nearest other animal at activation and periodically update
their approach to that companion. Existing outdoor paths, local avoidance and
swept clearance still apply. The final approach extends the coarse graph route
to a checked point outside the companion's clearance. An unreachable or distant
companion may not be reached before expiry; there is no teleport or wall bypass.
A lone animal still plays its visuals and returns to normal. Targets take no
damage and do not trigger recursive effects. No breeding or persistence.

`village_animals.gd` owns input gating and creation; `animal_blast.gd` owns the
finite effect, temporary visuals and pursuit decisions. The existing herd
scheduler still plans at most one animal per physics tick. `village_animal.gd`
retains physical movement/gait, with temporary speed/acceleration and visual
stunt offsets. Aerial stunts reserve the ground body rather than moving physical
collision into the sky, avoiding occupied/invalid landings. Material changes
use per-instance charcoal uniforms, leaving shared coats and other animals alone.
Expiry clears routes/velocity, restores visual transforms/materials, removes
transient eye/tongue/effect nodes and resumes ordinary rest/forage/wandering.

World double-clicks are excluded during application/help/launcher interaction,
host focus loss, mouse-look and object grabs. Walls, furniture and live panel
housing occlude animal picking. Animal collision now also occludes panel and
furniture picking, avoiding double-click activation through an animal. F1 lists
the binding. No native compositor, live application identity, dependency,
asset download or host service changes.

All visuals are original procedural meshes/shaders using the existing Godot
renderer and animal models. Source-only artifact policy is retained; PNG captures
and generated/imported data remain ignored under `.tools`.

## Verification

Import/startup/bridge build, all 20 effect/species cases in headless and GPU
modes, normal animal behavior, real Terminal/Vim during concurrent effects,
help, transitions, pointer, exact client color, pavilion and 62 Node tests pass.
Actual effect, restored-species, help and returned-client renders were inspected.

See [evidence and reproduction](../evidence/animal-blasts/README.md) for the final
agent-run results, actual rendered frames and scope limits. Human appearance,
physical-input comfort and sustained/target-device performance remain unobserved.
