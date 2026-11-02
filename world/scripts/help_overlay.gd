## Modal command reference. Live clients keep running while their input is released.
extends CanvasLayer

const SECTIONS := [
	["Move & look", "W A S D — Walk forward/backward and strafe.\nHold right mouse — Look around; release to free the pointer.\nCtrl — Hold to walk slowly. M — Toggle slow walking.\nSpace — Jump while on the ground.\nHome — Return to the arrival point.\nEscape — Release the pointer and stop moving."],
	["Applications", "Tab / Applications — Open recent applications in the world.\nClick the center or press Enter — Search installed applications.\nType to filter; use arrows and Enter or double-click to launch.\n1–8 — Open a recent application from the wheel.\nEscape — Return from search to recents, then to the world.\nClick a panel — Select it. Enter or double-click — Use it.\nCtrl+Alt+Escape — Return to the world, leaving the app running."],
	["Move & place objects", "Double-click an animal — Random lightning, fire, cyclone or love blast; it soon returns to normal.\nWalk into movable furniture to push it.\nLeft-drag an app panel or movable furniture — Pick it up.\nKeep holding left mouse and use W A S D to carry it.\nHold right mouse while carrying — Look around.\nWheel up / down — Move the object farther away / closer.\nHold both mouse buttons + wheel — Rotate the held object; up turns left, down turns right.\nRelease left mouse — Place it; unsupported panels fall onto a surface.\nEscape while holding — Cancel and restore the original placement.\nLeave a live panel on a table, explore, then return and double-click to resume."],
	["Desktop & application view", "F1 — Open or close this reference in any view.\nEscape / Close — Dismiss this overlay. Scroll for more on smaller windows.\nF11 — Toggle fullscreen and the last window size.\nAlt+F4 — Quit Elsewhere and close its owned applications.\nIn an app, type and use its normal shortcuts; ? remains normal text. F1, F11, Alt+F4 and Ctrl+Alt+Escape are reserved.\nDrag inside an app to select; use the wheel to scroll.\nResize Elsewhere’s window to resize the active app.\nClose an app using its own commands, such as exit in a terminal. Use Applications to launch it again."]
]

var app: CanvasLayer
var launcher: CanvasLayer
var objects: Node3D
var player: CharacterBody3D
var opened := false
var backdrop: ColorRect
var panel: PanelContainer
var scroll: ScrollContainer
var grid: GridContainer
var close_button: Button
var _prior_focus: WeakRef
var _consumed_keys: Dictionary = {}

func _ready() -> void:
	layer = 30
	backdrop = ColorRect.new()
	backdrop.color = Color(0.015, 0.025, 0.03, 0.8)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("15292f")
	style.border_color = Color("49666d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", style)
	backdrop.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)
	var header := HBoxContainer.new()
	content.add_child(header)
	var title := Label.new()
	title.text = "Commands & techniques"
	title.add_theme_font_size_override("font_size", 26)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(close)
	header.add_child(close_button)
	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	grid = GridContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 32)
	grid.add_theme_constant_override("v_separation", 24)
	scroll.add_child(grid)
	for section in SECTIONS:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 8)
		grid.add_child(column)
		var heading := Label.new()
		heading.text = section[0]
		heading.add_theme_font_size_override("font_size", 20)
		heading.add_theme_color_override("font_color", Color("a9d4ca"))
		column.add_child(heading)
		var body := Label.new()
		body.text = section[1]
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_theme_font_size_override("font_size", 16)
		body.add_theme_constant_override("line_spacing", 4)
		column.add_child(body)
	get_viewport().size_changed.connect(_layout)
	_layout()
	backdrop.hide()

func _layout() -> void:
	var viewport := get_viewport().get_visible_rect().size
	var desired := Vector2(minf(1080, viewport.x - 40), minf(760, viewport.y - 40))
	grid.columns = 2 if desired.x >= 800 else 1
	# Wrapping labels need an explicit width for their container minimum height.
	var width := (desired.x - 64 - (32 if grid.columns == 2 else 0)) / grid.columns
	for column in grid.get_children(): column.custom_minimum_size.x = width
	# Let the old column minimum widths clear before shrinking the panel.
	panel.set_deferred("size", desired)
	panel.set_deferred("position", (viewport - desired) * 0.5)

func open() -> void:
	if opened or not app.host_focused: return
	var focus := get_viewport().gui_get_focus_owner()
	_prior_focus = weakref(focus) if focus != null else null
	if objects.has_grab(): objects.finish_drag(true)
	player.release_pointer()
	player.application_mode = true
	app.help_active = true
	opened = true
	if app.terminal.session != null and app.terminal.session.is_running():
		app.terminal.session.pointer_reset()
		if not app.terminal.session.focus_keyboard(0): push_error(app.terminal.session.last_error())
	scroll.scroll_vertical = 0
	backdrop.show()
	close_button.grab_focus()

func close(restore_focus := true) -> void:
	if not opened: return
	opened = false
	app.help_active = false
	backdrop.hide()
	player.release_pointer()
	player.application_mode = app.active or launcher.opened
	if restore_focus and app.active:
		if app.terminal.session == null or not app.terminal.session.is_running() or not app.terminal.session.focus_keyboard(app.focused_handle):
			app.exit_application(false)
	if restore_focus and _prior_focus != null:
		var focus: Control = _prior_focus.get_ref()
		if is_instance_valid(focus) and focus.is_visible_in_tree(): focus.grab_focus()
	_prior_focus = null

func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	var key: int = event.physical_keycode if event.physical_keycode else event.keycode
	if not event.pressed and _consumed_keys.erase(key):
		get_viewport().set_input_as_handled()
		return
	var toggle: bool = key == KEY_F1 and not (event.ctrl_pressed or event.alt_pressed or event.meta_pressed or event.shift_pressed)
	if toggle or (opened and key == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		if event.pressed and not event.echo and not _consumed_keys.has(key):
			_consumed_keys[key] = true
			if opened: close()
			else: open()
	elif opened and key not in [KEY_UP, KEY_DOWN, KEY_PAGEUP, KEY_PAGEDOWN, KEY_HOME, KEY_END, KEY_TAB, KEY_ENTER, KEY_SPACE, KEY_SHIFT]:
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		close(false)
		_consumed_keys.clear()
