# P22-T05 render evidence

2026-10-11, Codex agent observed, based on `82dd2a2` / `art-reference-2`.
The owner selected version 2; these are its material/foliage/daylight refinements.
Actual Godot 4.7.2 Compatibility renders on the Steam Deck GPU under private
Weston. All world views are 1280 × 800 at the existing eye-height cameras.
Source JPEG references are not runtime screenshots.

| View | Selected version 2 baseline (2026-10-11, `82dd2a2`) | P22-T05 final |
| --- | --- | --- |
| arrival | [Before](../village-reference-2/arrival.png) | [After](arrival.png) |
| east-square | [Before](../village-reference-2/east-square.png) | [After](east-square.png) |
| north-return | [Before](../village-reference-2/north-return.png) | [After](north-return.png) |
| lodge | [Before](../village-reference-2/lodge.png) | [After](lodge.png) |
| guildhall | [Before](../village-reference-2/guildhall.png) | [After](guildhall.png) |
| workshop | [Before](../village-reference-2/workshop.png) | [After](workshop.png) |
| pavilion | [Before](../village-reference-2/pavilion.png) | [After](pavilion.png) |
| south-approach | [Before](../village-reference-2/south-approach.png) | [After](south-approach.png) |
| pavilion-covered | [Before](../village-reference-2/pavilion-covered.png) | [After](pavilion-covered.png) |

New close views: [plaster and timber](plaster-timber.png),
[carved fountain and paving](paving-fountain.png), [foliage](foliage.png).
These show finish scale/contact from inside the actual world.

[Rejected first texture pass](first-pass-arrival.png): excessive brightness
and missing mipmaps. It is retained to substantiate the defect/review loop;
use the final arrival above for the accepted agent-observed result.

Preservation captures, refreshed after the final shadow correction:
[empty startup](empty-arrival.png), [real terminal input](application.png),
[terrain-supported live panel](slope-panel.png),
[real Chrome input/save](browser-input.png), and
[browser world return](browser-in-room.png). The last image is 1000 × 700.
App-mode images confirm readable content alongside the automated interaction
assertions; screenshots alone are not input/usability proof.

[Verification excerpts](verification.txt) accompany the
[handoff and defect review](../../handoffs/45-village-materials.md).
No final owner approval, human comfort test or performance benchmark is claimed.
P22-T06 remains unstarted and requires owner review/authorization.
