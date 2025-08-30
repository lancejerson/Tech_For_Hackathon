extends Node2D
class_name control

var total_steps: int = 0
var current_steps: int = 0
var step_count: int = 0
var last_accel := Vector3.ZERO
var step_threshold := 11
var cooldown := 0.3
var step_timer := 0.0
var step_goal: int = 0
var popup_instance: Node2D = null
var target_steps : int = 0

@onready var step_label: Label = $Label
@onready var PopupScene: PackedScene = preload("res://Step_Counter.tscn")

func _ready() -> void:
	_setup_rounded_design()
	_generate_new_goal()

func _setup_rounded_design() -> void:
	# Create a container for the rounded background
	var container = Control.new()
	container.name = "RoundedContainer"
	add_child(container)
	move_child(container, 0)  # Move to bottom so label is on top
	
	# Set container size to 30% of screen
	var screen_size = get_viewport().get_visible_rect().size
	container.custom_minimum_size = screen_size * 0.3
	container.size = screen_size * 0.3
	
	# Position container (centered by default, adjust as needed)
	container.position = (screen_size - container.size) / 2
	
	# Create rounded background using StyleBoxFlat
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 0.9)  # Dark semi-transparent background
	style_box.corner_radius_top_left = 20
	style_box.corner_radius_top_right = 20
	style_box.corner_radius_bottom_right = 20
	style_box.corner_radius_bottom_left = 20
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.8, 0.8, 0.8)
	
	# Apply the style to the container
	container.add_theme_stylebox_override("panel", style_box)
	
	# Configure the existing label
	step_label.add_theme_color_override("font_color", Color.WHITE)
	step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Make label fill the container
	step_label.size = container.size
	step_label.position = Vector2.ZERO
	
	# Reparent the label to the container
	remove_child(step_label)
	container.add_child(step_label)

func _process(delta: float) -> void:
	step_timer -= delta
	var accel: Vector3 = Input.get_accelerometer()
	var diff: Vector3 = accel - last_accel
	
	if diff.length() > step_threshold and step_timer <= 0.0:
		total_steps += 1
		current_steps += 1 
		step_timer = cooldown
		step_label.text = "Steps: %d\nProgress: %d / %d" % [total_steps, current_steps, step_goal]
		
		if current_steps >= step_goal:
			_show_popup()
	
	last_accel = accel
	
func _generate_new_goal() -> void:
	step_goal = randi_range(10, 20)
	current_steps = 0
	step_label.text = "Total Steps: %d\nProgress: 0 / %d" % [total_steps, step_goal]
	
func _show_popup() -> void:
	if popup_instance == null:
		popup_instance = PopupScene.instantiate()
		get_tree().root.add_child(popup_instance)
		hide()
		popup_instance.connect("tree_exited", Callable(self, "_on_popup_closed"))
	
func _on_popup_closed() -> void:
	show()
	popup_instance = null
	_generate_new_goal()
