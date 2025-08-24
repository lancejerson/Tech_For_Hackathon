extends Node2D
signal popup_closed

@onready var label: Label = $Label
@onready var button: Button = $Button

var target_steps: int = 0

func show_popup(t: int) -> void:
	target_steps = t
	label.text = "You've reached your goal"
	visible = true
	
func _ready() -> void:
	button.pressed.connect(_on_close_pressed)
	
func _on_close_pressed() -> void:
	emit_signal("popup_closed")
	queue_free()
