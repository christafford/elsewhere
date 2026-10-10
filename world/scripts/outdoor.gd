## The outdoor location supplies terrain and presentation to DesktopRuntime.
extends Node3D

const Landscape = preload("res://scripts/village_landscape.gd")
@onready var desktop_runtime: Node = $DesktopRuntime
var terminal_screen: Node:
	get: return desktop_runtime.terminal_screen
var application_mode: CanvasLayer:
	get: return desktop_runtime.application_mode
var app_launcher: CanvasLayer:
	get: return desktop_runtime.app_launcher
var application_objects: Node3D:
	get: return desktop_runtime.application_objects

static func bounded_center(center: Vector3, extents: Vector3) -> Vector3:
	return Landscape.bounded_center(center, extents)

func _ready() -> void:
	# Keep the existing selected-texture adapter without a second physical monitor.
	# The independent live panels remain the visible world presentation.
	$SelectedPreview/Screen.material_override = preload("res://scripts/screen_material.gd").create()
	desktop_runtime.initialize($Player, $SelectedPreview/Screen, $ApplicationStatus, bounded_center)
