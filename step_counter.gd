extends Node2D

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
@onready var PopupScene: PackedScene = preload("res://scenes/run/run.tscn")

func _ready() -> void:
	_generate_new_goal()

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
	step_goal = randi_range(100, 200)
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
