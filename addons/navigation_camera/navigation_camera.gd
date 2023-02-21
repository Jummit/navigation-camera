@tool
@icon("res://addons/navigation_camera/navigation_camera_icon.svg")
extends Camera3D
class_name NavigationCamera

## A camera that can be rotated and panned around a center using the mouse

@export_range(0.0, 1.0) var rotation_sensitity := 0.48
@export_range(0.0, 1.0) var moving_sensitity := 0.14
@export_range(0.0, 1.0) var zoom_sensitity := 0.1
@export var pan_only := false
@export var focus_point := Vector3.ZERO

var horizontal_rotation := 0.0
var vertical_rotation := 0.0
var zoom := 0.0:
	set(to):
		zoom = min(0.01, to)

var _previous_transform : Transform3D

func _ready() -> void:
	_sync_transform()


func _sync_transform():
	vertical_rotation = transform.basis.get_euler().y
	horizontal_rotation = transform.basis.get_euler().x
	zoom = -transform.origin.distance_to(focus_point)
	_previous_transform = transform


func _unhandled_input(event : InputEvent) -> void:
	if transform != _previous_transform:
		_sync_transform()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += zoom_sensitity * (-zoom - 0.5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= zoom_sensitity * (-zoom - 0.5)
		_update_transform()
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
		if event.ctrl_pressed:
			print(zoom)
			zoom -= zoom_sensitity * event.relative.y * moving_sensitity * (-zoom - 0.5)
		elif event.shift_pressed or pan_only:
			focus_point -= transform.basis.x * event.relative.x * moving_sensitity / 100 * -zoom
			focus_point += transform.basis.y * event.relative.y * moving_sensitity / 100  * -zoom
		else:
			vertical_rotation -= event.relative.x * rotation_sensitity / 100
			horizontal_rotation -= event.relative.y * rotation_sensitity / 100
		_update_transform()


func _update_transform() -> void:
	transform = _generate_transform(horizontal_rotation, vertical_rotation, zoom, focus_point)
	_previous_transform = transform


static func _generate_transform(_horizontal_rotation : float,
		_vertical_rotation : float, _zoom : float,
		_focus_point : Vector3) -> Transform3D:
	var transform := Transform3D.IDENTITY\
			.translated(Vector3.FORWARD * _zoom)\
			.rotated(Vector3.RIGHT, _horizontal_rotation)\
			.rotated(Vector3.UP, _vertical_rotation)
	# Don't use `translated` because it is in local space.
	transform.origin = transform.origin + _focus_point
	return transform
