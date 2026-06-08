# ADR-002: CanvasLayer UI with Programmatic Node Construction

**Date**: 2026-06-07
**Status**: Accepted

## Context

UI components (HUD, CombatCutaway) need to render above the game world at all times. Two options were considered: scene-file-defined UI nodes under the main scene tree, or programmatically constructed nodes in a CanvasLayer.

## Decision

All UI is built on `CanvasLayer` nodes. All child nodes are created programmatically in `_ready()` or `_build_ui()` — no child nodes are defined in `.tscn` files for UI scenes.

- `HUD` — `CanvasLayer` at layer `0`
- `CombatCutaway` — `CanvasLayer` at layer `10` (renders above HUD)

## Consequences

- UI is always drawn above the game grid regardless of scene tree ordering.
- `.tscn` files for UI scenes contain only the root `CanvasLayer` node and its script; no child node authoring in the Godot editor for UI.
- `CanvasLayer` does **not** inherit `CanvasItem` — it has no `modulate` property. Fading requires targeting a root `Control` child: `_root.modulate.a`, not `self.modulate.a`.
- Adding new UI elements requires code changes, not scene editing — acceptable for this project's scope.
