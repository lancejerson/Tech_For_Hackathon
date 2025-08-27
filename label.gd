extends Label

@export var circle_size: int = 150
@export var gradient_start: Color = Color("#2b5876")
@export var gradient_end: Color = Color("#4e4376")
@export var pulse_enabled: bool = true

# Font enhancement properties
@export_range(12, 36) var font_size: int = 22
@export_range(100, 900, 100) var font_weight: int = 700
@export var font_color: Color = Color.WHITE
@export var outline_color: Color = Color("#1a1a2e")
@export_range(0, 4) var outline_size: int = 1
@export var use_shadow: bool = true
@export var shadow_color: Color = Color(0, 0, 0, 0.3)
@export_range(1, 4) var shadow_size: int = 1
@export var shadow_offset: Vector2 = Vector2(1, 1)
@export var font_style: String = "modern"  # Options: modern, rounded, elegant, bold

# New property for background contrast
@export var background_contrast: float = 0.7  # How much to darken/lighten background for contrast

func _ready():
	# Create a more sophisticated style
	var style_box = StyleBoxFlat.new()
	
	# Calculate contrasting background color based on font color
	var bg_color = calculate_contrasting_color(font_color)
	
	# Gradient background using corner colors to simulate gradient
	style_box.bg_color = bg_color
	
	# Perfect circle
	style_box.corner_radius_top_left = circle_size / 2
	style_box.corner_radius_top_right = circle_size / 2
	style_box.corner_radius_bottom_right = circle_size / 2
	style_box.corner_radius_bottom_left = circle_size / 2
	
	# Border with gradient color
	style_box.border_width_left = 4
	style_box.border_width_right = 4
	style_box.border_width_top = 4
	style_box.border_width_bottom = 4
	style_box.border_color = bg_color.darkened(0.3)
	
	# Enhanced shadow with blur effect
	style_box.shadow_color = Color(0, 0, 0, 0.4)
	style_box.shadow_size = 12
	style_box.shadow_offset = Vector2(3, 3)
	
	# Padding for text
	style_box.content_margin_left = 25
	style_box.content_margin_right = 25
	style_box.content_margin_top = 25
	style_box.content_margin_bottom = 25
	
	# Apply the style
	add_theme_stylebox_override("normal", style_box)
	
	# Set up font based on selected style and enhancement options
	setup_font_style()
	
	# Center alignment
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Set circular size
	custom_minimum_size = Vector2(circle_size, circle_size)
	size = Vector2(circle_size, circle_size)
	
	# Add hover animation for interactivity
	mouse_filter = MOUSE_FILTER_PASS
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Initial scale for animation
	scale = Vector2(0.9, 0.9)
	
	# Entrance animation
	entrance_animation()

func calculate_contrasting_color(base_color: Color) -> Color:
	# Calculate luminance of the font color
	var luminance = 0.2126 * base_color.r + 0.7152 * base_color.g + 0.0722 * base_color.b
	
	# If font is light, use dark background; if font is dark, use light background
	if luminance > 0.6:
		return base_color.darkened(background_contrast)
	else:
		return base_color.lightened(background_contrast)

func setup_font_style():
	# Apply the font enhancement properties
	add_theme_font_size_override("font_size", font_size)
	add_theme_color_override("font_color", font_color)
	add_theme_constant_override("font_weight", font_weight)
	
	# Apply outline if enabled
	if outline_size > 0:
		add_theme_color_override("font_outline_color", outline_color)
		add_theme_constant_override("outline_size", outline_size)
	
	# Apply shadow if enabled
	if use_shadow:
		var font_settings = LabelSettings.new()
		font_settings.shadow_color = shadow_color
		font_settings.shadow_size = shadow_size
		font_settings.shadow_offset = shadow_offset
		label_settings = font_settings
	
	# Apply specific style presets
	match font_style:
		"rounded":
			add_theme_constant_override("font_weight", 500)  # Medium weight
			if outline_size == 0:
				add_theme_constant_override("outline_size", 2)
			
		"elegant":
			add_theme_constant_override("font_weight", 300)  # Light weight
			add_theme_constant_override("font_italic", 1)    # Slight italic
			if not use_shadow:
				var font_settings = LabelSettings.new()
				font_settings.shadow_color = Color(0, 0, 0, 0.2)
				font_settings.shadow_size = 1
				font_settings.shadow_offset = Vector2(1, 1)
				label_settings = font_settings
			
		"bold":
			add_theme_constant_override("font_weight", 900)  # Heavy weight
			if not use_shadow:
				var font_settings = LabelSettings.new()
				font_settings.shadow_color = Color(0, 0, 0, 0.4)
				font_settings.shadow_size = 2
				font_settings.shadow_offset = Vector2(2, 2)
				label_settings = font_settings

func entrance_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if pulse_enabled:
		await get_tree().create_timer(0.6).timeout
		start_pulse_animation()

func _on_mouse_entered():
	# Scale up and add glow effect on hover
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# Enhance shadow on hover
	var style = get_theme_stylebox("normal").duplicate()
	style.shadow_size = 16
	style.shadow_color = Color(0, 0, 0, 0.5)
	add_theme_stylebox_override("normal", style)
	
	# Font color change on hover
	add_theme_color_override("font_color", font_color.lightened(0.1))

func _on_mouse_exited():
	# Scale back to normal
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Reset shadow
	var style = get_theme_stylebox("normal").duplicate()
	style.shadow_size = 12
	style.shadow_color = Color(0, 0, 0, 0.4)
	add_theme_stylebox_override("normal", style)
	
	# Reset font color
	add_theme_color_override("font_color", font_color)

# Subtle pulse animation for attention
func start_pulse_animation():
	if not pulse_enabled:
		return
		
	var tween = create_tween()
	tween.set_loops()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.03, 1.03), 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color(1.1, 1.1, 1.1, 1.0), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_SINE).set_delay(0.5)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE).set_delay(0.5)

# Function to change colors dynamically
func update_colors(new_font_color: Color, new_bg_color: Color = Color.TRANSPARENT):
	font_color = new_font_color
	
	# If no specific background color provided, calculate a contrasting one
	if new_bg_color == Color.TRANSPARENT:
		new_bg_color = calculate_contrasting_color(font_color)
	
	var style = get_theme_stylebox("normal").duplicate()
	style.bg_color = new_bg_color
	style.border_color = new_bg_color.darkened(0.3)
	add_theme_stylebox_override("normal", style)
	
	# Update font color
	add_theme_color_override("font_color", font_color)

# Function to update font properties at runtime
func update_font_style():
	setup_font_style()
