extends Object

class_name PlayerController


enum Action {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	LOOK_LEFT,
	LOOK_RIGHT,
	LOOK_UP,
	LOOK_DOWN,
	SHOOT,
	DODGE,
	RELOAD,
	NEXT_WEAPON,
	PREV_WEAPON,

	ACTION_COUNT,
}


var viewport: Viewport
var pc: Node
var input_id: int
var action_names = []
var look_direction := Vector2(1, 0)


const action_name := [
	"left",
	"right",
	"up",
	"down",
	"look_left",
	"look_right",
	"look_up",
	"look_down",
	"shoot",
	"dodge",
	"reload",
	"next_weapon",
	"prev_weapon",
]


const mouse_name_from_button := {
	BUTTON_LEFT: "mouse_left",
	BUTTON_RIGHT: "mouse_right",
	BUTTON_MIDDLE: "mouse_middle",
	BUTTON_WHEEL_UP: "wheel_up",
	BUTTON_WHEEL_DOWN: "wheel_down",
	BUTTON_WHEEL_LEFT: "wheel_left",
	BUTTON_WHEEL_RIGHT: "wheel_right",
	BUTTON_XBUTTON1: "mouse_prev",
	BUTTON_XBUTTON2: "mouse_next",
}
static func mouse_button_from_name(name):
	for button in mouse_name_from_button:
		if name == mouse_name_from_button[button]:
			return button
	return null


func setup(viewport_: Viewport, pc_: Node, input_id_: int = -1):
	viewport = viewport_
	pc = pc_
	input_id = input_id_

	var events = create_default_events()

	var id = "kb_" if input_id < 0 else "pad%d_" % input_id
	for act in range(action_name.size()):
		var act_name = id + action_name[act]
		action_names.append(act_name)

		if not InputMap.has_action(act_name):
			InputMap.add_action(act_name, 0.25)
		InputMap.action_erase_events(act_name)
		for event in events[act]:
			InputMap.action_add_event(act_name, event)


func get_move_direction() -> Vector2:
	var direction := Vector2()

	direction.x -= Input.get_action_strength(action_names[Action.LEFT])
	direction.x += Input.get_action_strength(action_names[Action.RIGHT])
	direction.y -= Input.get_action_strength(action_names[Action.UP])
	direction.y += Input.get_action_strength(action_names[Action.DOWN])

	var length = direction.length()
	if length > 1:
		direction /= length

	return direction


func get_look_direction() -> Vector2:
	if input_id < 0:
		return pc.position.direction_to(viewport.get_mouse_position())
	else:
		var direction := Vector2()

		direction.x -= Input.get_action_strength(action_names[Action.LOOK_LEFT])
		direction.x += Input.get_action_strength(action_names[Action.LOOK_RIGHT])
		direction.y -= Input.get_action_strength(action_names[Action.LOOK_UP])
		direction.y += Input.get_action_strength(action_names[Action.LOOK_DOWN])

		if direction != Vector2():
			look_direction = direction.normalized()

		return look_direction


func is_shoot_pressed() -> bool:
	return Input.is_action_pressed(action_names[Action.SHOOT])


func is_dodge_just_pressed() -> bool:
	return Input.is_action_just_pressed(action_names[Action.DODGE])


func is_reload_just_pressed() -> bool:
	return Input.is_action_just_pressed(action_names[Action.RELOAD])


func is_next_weapon_just_pressed() -> bool:
	return Input.is_action_just_pressed(action_names[Action.NEXT_WEAPON])


func is_prev_weapon_just_pressed() -> bool:
	return Input.is_action_just_pressed(action_names[Action.PREV_WEAPON])


func create_default_events():
	if input_id < 0:
		var keyboard_map: Dictionary = viewport.get_node("main").keyboard_map
		var key_events := []
		for action in range(Action.ACTION_COUNT):
			var events = []
			for key_name in keyboard_map.get(action, []):
				var mouse_button = mouse_button_from_name(key_name)
				if mouse_button != null:
					events.append(new_mouse_button_event(mouse_button))
				else:
					var key = OS.find_scancode_from_string(key_name)
					events.append(new_key_event(key))
			key_events.append(events)
		return key_events
	else:
		return [
			[new_gamepad_axis_event(JOY_ANALOG_LX, -1), new_gamepad_button_event(JOY_DPAD_LEFT)],
			[new_gamepad_axis_event(JOY_ANALOG_LX, 1), new_gamepad_button_event(JOY_DPAD_RIGHT)],
			[new_gamepad_axis_event(JOY_ANALOG_LY, -1), new_gamepad_button_event(JOY_DPAD_UP)],
			[new_gamepad_axis_event(JOY_ANALOG_LY, 1), new_gamepad_button_event(JOY_DPAD_DOWN)],
			[new_gamepad_axis_event(JOY_ANALOG_RX, -1)],
			[new_gamepad_axis_event(JOY_ANALOG_RX, 1)],
			[new_gamepad_axis_event(JOY_ANALOG_RY, -1)],
			[new_gamepad_axis_event(JOY_ANALOG_RY, 1)],
			[new_gamepad_button_event(JOY_R2)],
			[new_gamepad_button_event(JOY_L2)],
			[new_gamepad_button_event(JOY_L)],
			[new_gamepad_button_event(JOY_R)],
			[],
		]


func new_key_event(key):
	var event := InputEventKey.new()
	event.scancode = key
	event.pressed = true
	return event


func new_mouse_button_event(button):
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	return event


func new_gamepad_axis_event(axis, value):
	var event := InputEventJoypadMotion.new()
	event.device = input_id
	event.axis = axis
	event.axis_value = value
	return event


func new_gamepad_button_event(button):
	var event := InputEventJoypadButton.new()
	event.device = input_id
	event.button_index = button
	event.pressed = true
	return event
