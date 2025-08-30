extends Label

@export var circle_size: int = 150
@export var gradient_start: Color = Color("#0a8da8")  # Changed to blue-green shade
@export var gradient_end: Color = Color("#0a5fa8")    # Changed to blue shade
@export var pulse_enabled: bool = false  # Disabled pulse by default

# Font enhancement properties - INCREASED FONT SIZE
@export_range(24, 120) var font_size: int = 96        # Increased maximum range and default size
@export_range(100, 900, 100) var font_weight: int = 700
@export var font_color: Color = Color.WHITE
@export var outline_color: Color = Color("#0d3b4e")   # Darker blue-green outline
@export_range(0, 6) var outline_size: int = 2         # Increased outline size
@export var use_shadow: bool = true
@export var shadow_color: Color = Color(0, 0.1, 0.2, 0.5)  # Blue-tinted shadow
@export_range(1, 6) var shadow_size: int = 2          # Increased shadow size
@export var shadow_offset: Vector2 = Vector2(2, 2)    # Increased shadow offset
@export var font_style: String = "modern"  # Options: modern, rounded, elegant, bold

# New property for background contrast
@export var background_contrast: float = 0.7  # How much to darken/lighten background for contrast

# New properties for enhanced effects
@export var enable_glow: bool = true
@export var glow_color: Color = Color("#0affff")      # Cyan-blue glow
@export_range(0, 20) var glow_size: int = 8
@export var enable_gradient: bool = true
@export var border_width: int = 6                    # Thicker border

func _ready():
	# Create a more sophisticated style
	var style_box = StyleBoxFlat.new()
	
	# Calculate contrasting background color based on font color
	var bg_color = calculate_contrasting_color(font_color)
	
	# Apply gradient if enabled
	if enable_gradient:
		style_box.bg_color = gradient_start
		# Simulate gradient using corner colors (Godot 4 doesn't have direct gradient support in StyleBoxFlat)
		style_box.corner_detail = 8
		style_box.border_width_left = border_width
		style_box.border_width_right = border_width
		style_box.border_width_top = border_width
		style_box.border_width_bottom = border_width
		style_box.border_color = gradient_end
	else:
		style_box.bg_color = bg_color
	
	# Perfect circle
	style_box.corner_radius_top_left = circle_size / 2
	style_box.corner_radius_top_right = circle_size / 2
	style_box.corner_radius_bottom_right = circle_size / 2
	style_box.corner_radius_bottom_left = circle_size / 2
	
	# Enhanced border with blue-green color
	style_box.border_width_left = border_width
	style_box.border_width_right = border_width
	style_box.border_width_top = border_width
	style_box.border_width_bottom = border_width
	style_box.border_color = gradient_end
	
	# Enhanced shadow with blue tint
	style_box.shadow_color = shadow_color
	style_box.shadow_size = shadow_size * 3  # Multiplied for more visible effect
	style_box.shadow_offset = shadow_offset
	
	# Add glow effect if enabled
	if enable_glow:
		style_box.shadow_color = glow_color
		style_box.shadow_size = glow_size
		style_box.shadow_offset = Vector2(0, 0)
	
	# Increased padding for larger text
	style_box.content_margin_left = 35
	style_box.content_margin_right = 35
	style_box.content_margin_top = 35
	style_box.content_margin_bottom = 35
	
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
	
	# Removed hover and transition animations
	scale = Vector2(1.0, 1.0)

func calculate_contrasting_color(base_color: Color) -> Color:
	# Calculate luminance of the font color
	var luminance = 0.2126 * base_color.r + 0.7152 * base_color.g + 0.0722 * base_color.b
	
	# If font is light, use dark background; if font is dark, use light background
	if luminance > 0.6:
		return base_color.darkened(background_contrast)
	else:
		return base_color.lightened(background_contrast)

func setup_font_style():
	# Apply the font enhancement properties - LARGER FONT
	add_theme_font_size_override("font_size", font_size)
	add_theme_color_override("font_color", font_color)
	add_theme_color_override("font_shadow_color", shadow_color)  # Added shadow color
	add_theme_constant_override("font_weight", font_weight)
	
	# Apply outline if enabled with increased size
	if outline_size > 0:
		add_theme_color_override("font_outline_color", outline_color)
		add_theme_constant_override("outline_size", outline_size)
	
	# Apply shadow if enabled with enhanced settings
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
				add_theme_constant_override("outline_size", 3)  # Increased
			
		"elegant":
			add_theme_constant_override("font_weight", 300)  # Light weight
			add_theme_constant_override("font_italic", 1)    # Slight italic
			if not use_shadow:
				var font_settings = LabelSettings.new()
				font_settings.shadow_color = Color(0, 0.1, 0.2, 0.3)  # Blue tint
				font_settings.shadow_size = 2  # Increased
				font_settings.shadow_offset = Vector2(2, 2)  # Increased
				label_settings = font_settings
			
		"bold":
			add_theme_constant_override("font_weight", 900)  # Heavy weight
			if not use_shadow:
				var font_settings = LabelSettings.new()
				font_settings.shadow_color = Color(0, 0.1, 0.2, 0.5)  # Blue tint
				font_settings.shadow_size = 3  # Increased
				font_settings.shadow_offset = Vector2(3, 3)  # Increased
				label_settings = font_settings

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

# New function to apply blue-green theme
func apply_blue_green_theme():
	gradient_start = Color("#0a8da8")
	gradient_end = Color("#0a5fa8")
	outline_color = Color("#0d3b4e")
	shadow_color = Color(0, 0.1, 0.2, 0.5)
	glow_color = Color("#0affff")
	
	# Update the style
	var style = get_theme_stylebox("normal").duplicate()
	style.border_color = gradient_end
	style.shadow_color = shadow_color
	add_theme_stylebox_override("normal", style)
	
	# Update font settings
	setup_font_style()
