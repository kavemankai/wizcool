# Technical Preferences

## Engine & Language
- **Engine**: Godot 4.6
- **Language**: GDScript (typed â€” all vars, params, return types annotated)
- **Rendering**: 2D, CanvasLayer for UI (HUD layer 0, CombatCutaway layer 10)
- **Physics**: Not used â€” grid-based movement only

## Input & Platform
- **Target Platforms**: PC (Windows primary)
- **Input Methods**: Keyboard / Mouse
- **Primary Input**: Mouse (left-click for all grid interaction)
- **Gamepad Support**: None
- **Touch Support**: None
- **Platform Notes**: 1280x720 locked viewport, no pan/zoom, orthographic

## Naming Conventions
- **Classes**: PascalCase with class_name (CombatResolver, GridManager)
- **Variables**: snake_case; private prefixed _ (_skip_requested)
- **Signals**: snake_case verb_noun (cutaway_dismissed, end_turn_pressed)
- **Files**: PascalCase .gd matching class_name
- **Scenes**: PascalCase .tscn matching root node name
- **Constants**: UPPER_SNAKE_CASE

## Performance Budgets
- **Target Framerate**: 60 fps
- **Frame Budget**: 16.6ms
- **Draw Calls**: Minimal â€” units use _draw() on Node2D, no sprites
- **Memory Ceiling**: No formal ceiling â€” prototype scope

## Testing
- **Framework**: None (GUT/gdUnit4 not set up)
- **Minimum Coverage**: 0% automated â€” manual in-editor testing
- **Required Tests**: Combat math, gear state transitions

## Forbidden Patterns
- No game logic in UI scripts (HUD.gd, CombatCutaway.gd must not own state)
- No direct unit.take_damage() calls â€” all damage routes through CombatResolver.resolve_damage()
- No hardcoded grid tile positions â€” use GridPos and grid_to_world_center
- No circular class_name dependencies
- No physics bodies or collision shapes

## Allowed Libraries / Addons
- GodotPrompter v1.9.0 (project-scoped Claude Code skills plugin)
- Claude Code Game Studios (workflow template â€” agents, skills, hooks)

## Architecture Decisions Log
- ADR-001: CombatResolver as single damage routing point
- ADR-002: CanvasLayer for all UI (no scene-tree UI nodes)
- ADR-003: Programmatic UI construction in _ready()/_build_ui()
- ADR-004: Static AI dispatch â€” each archetype is a pure static class

## Engine Specialists
- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-gdscript-specialist
- **Shader Specialist**: godot-shader-specialist
- **UI Specialist**: ui-programmer
- **Additional Specialists**: gameplay-programmer, systems-designer

### File Extension Routing
| File Extension / Type        | Specialist to Spawn          |
|------------------------------|------------------------------|
| .gd game logic               | godot-gdscript-specialist    |
| .gd shader / visual          | godot-shader-specialist      |
| .gd UI / HUD                 | ui-programmer                |
| .tscn scene files            | godot-specialist             |
| .tres resource files         | godot-specialist             |
| General architecture review  | technical-director           |
