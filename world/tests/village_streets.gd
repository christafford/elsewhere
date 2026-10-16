## Eye-level composition views; use the unchanged atmosphere trial for cost data.
extends "res://tests/village_landscape.gd"

const VIEWS := [
	["square-north",Vector2(0,5),Vector3(-3,4,-16)],
	["north-quarter",Vector2(5,-27),Vector3(-10,5,-32)],
	["copper-frontage",Vector2(-20,-24.8),Vector3(-14,5,-31)],
	["bookbinder-frontage",Vector2(5,-37),Vector3(-4,4,-33)],
	["library-street",Vector2(4,-26),Vector3(17,5,-32)],
	["lantern-lane",Vector2(-20,-18),Vector3(-26,6,-26)],
	["west-shops",Vector2(-21,5),Vector3(-31,4,8)],
	["bakery-frontage",Vector2(-23,-6),Vector3(-31,4,1)],
	["herb-frontage",Vector2(-24,10),Vector3(-31,4,17)],
	["trade-lane",Vector2(24,-7),Vector3(31,4,-17)],
	["store-frontage",Vector2(21,6),Vector3(32,4,0)],
	["southern-court",Vector2(0,17),Vector3(14,4,27)],
	["meadow-frontage",Vector2(-2,23),Vector3(7,5,32)],
	["hearth-frontage",Vector2(9,7),Vector3(18,4,19)],
]

func run() -> void:
	output_dir = ProjectSettings.globalize_path("res://../.tools/p22-t11/streets").simplify_path()
	DirAccess.make_dir_recursive_absolute(output_dir)
	study = load("res://scenes/main.tscn").instantiate()
	root.add_child(study)
	current_scene = study
	terminal = study.terminal_screen
	app = study.application_mode
	objects = study.application_objects
	walker = study.get_node("Player")
	await frames(20)
	check(DisplayServer.get_name()!="headless","Street inspection requires graphical rendering")
	if not failures:
		root.grab_focus()
		for view in VIEWS:
			await place_at(view[1])
			walker.camera.look_at(view[2])
			await capture(view[0]+".png")
	await study.desktop_runtime.shutdown()
	print("VILLAGE_STREETS_OK failures=",failures)
	quit(1 if failures else 0)
