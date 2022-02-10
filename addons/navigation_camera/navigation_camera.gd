tool
extends Camera
class_name NavigationCamera, "navigation_camera_icon.svg"

"""
A camera that can be rotated and panned around a center using the mouse
"""

export(float, 0.0, 1.0) var rotation_sensitity := 0.48
export(float, 0.0, 1.0) var moving_sensitity := 0.14
export(float, 0.0, 1.0) var zoom_sensitity := 0.3
export var pan_only := false

export var focus_point := Vector3.ZERO

var horizontal_rotation := 0.0
var vertical_rotation := 0.0
var zoom := 0.0

func _ready() -> void:
	vertical_rotation = transform.basis.get_euler().y
	horizontal_rotation = transform.basis.get_euler().x
	zoom = -transform.origin.distance_to(focus_point)


func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom += zoom_sensitity
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom -= zoom_sensitity
		_update_transform()
	if event is InputEventMouseMotion and event.button_mask == BUTTON_MASK_MIDDLE:
		if event.control:
			zoom -= zoom_sensitity * event.relative.y * moving_sensitity
		elif event.shift or pan_only:
			focus_point -= transform.basis.x * event.relative.x * moving_sensitity / 100 * -zoom
			focus_point += transform.basis.y * event.relative.y * moving_sensitity / 100  * -zoom
		else:
			vertical_rotation -= event.relative.x * rotation_sensitity / 100
			horizontal_rotation -= event.relative.y * rotation_sensitity / 100
		_update_transform()


func _update_transform() -> void:
	transform = _generate_transform(horizontal_rotation, vertical_rotation, zoom, focus_point)


static func _generate_transform(_horizontal_rotation : float,
		_vertical_rotation : float, _zoom : float,
		_focus_point : Vector3) -> Transform:
	var transform := Transform.IDENTITY\
			.translated(Vector3.FORWARD * _zoom)\
			.rotated(Vector3.RIGHT, _horizontal_rotation)\
			.rotated(Vector3.UP, _vertical_rotation)\
	# Don't use `translated` because it is in local space.
	transform.origin += _focus_point
	return transform
