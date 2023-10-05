# SPDX-FileCopyrightText: 2023 Jummit
#
# SPDX-License-Identifier: GPL-3.0-or-later

@tool
@icon("res://addons/navigation_camera/navigation_camera_icon.svg")
extends Camera3D
class_name NavigationCamera

## A camera which can be rotated and panned around a center using
## the mouse.
##
## The navigation scheme is as follows:
## [br]
## [br][code]Middle Mouse Button[/code]: Rotate
## [br][code]Shift + Middle Mouse Button[/code]: Drag
## [br][code]Ctrl + Middle Mouse Button[/code]: Zoom

## Sensitivity of mouse movement affecting rotation.
@export_range(0.0, 1.0) var rotation_sensitity := 0.48
## Sensitivity of mouse movement affecting motion.
@export_range(0.0, 1.0) var moving_sensitity := 0.14
## Sensitivity of mouse movement affecting zooming.
@export_range(0.0, 1.0) var zoom_sensitity := 0.1
## Disable rotation, useful for viewing something from one side.
@export var pan_only := false
## Relative point around which to rotate.
@export var focus_point := Vector3.ZERO

## Left-right rotation.
var horizontal_rotation := 0.0
## Up-down rotation.
var vertical_rotation := 0.0
## How close the camera is to the [member focus_point].
var zoom := 0.0:
	set(to):
		zoom = min(0.01, to)

var _previous_transform : Transform3D

func _ready() -> void:
	_sync_transform()


func _unhandled_input(event : InputEvent) -> void:
	if transform != _previous_transform:
		_sync_transform()
	var motion_event := event as InputEventMouseMotion
	var button_event := event as InputEventMouseButton
	if button_event:
		if button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += zoom_sensitity * (-zoom - 0.5)
		elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= zoom_sensitity * (-zoom - 0.5)
		_update_transform()
	if motion_event and motion_event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
		var motion := motion_event.relative
		if motion_event.ctrl_pressed:
			zoom -= zoom_sensitity * motion.y * moving_sensitity * (-zoom - 0.5)
		elif motion_event.shift_pressed or pan_only:
			var offset := motion * moving_sensitity / 100 * -zoom
			focus_point -= basis.x * offset.x
			focus_point += basis.y * offset.y
		else:
			vertical_rotation -= motion.x * rotation_sensitity / 100
			horizontal_rotation -= motion.y * rotation_sensitity / 100
		_update_transform()


func _sync_transform():
	vertical_rotation = transform.basis.get_euler().y
	horizontal_rotation = transform.basis.get_euler().x
	zoom = -transform.origin.distance_to(focus_point)
	_previous_transform = transform


func _update_transform() -> void:
	transform = _generate_transform(horizontal_rotation, vertical_rotation,
			zoom, focus_point)
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
