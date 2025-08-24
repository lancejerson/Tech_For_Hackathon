extends Control
@export var tab: Node

const DB_PATH := "user://users.json"
@onready var step_counter: PackedScene = preload("res://Step_Counter.tscn")
var is_login_mode := false   # clearer than "create"

# initializes the state of the elements
func _ready():
	$Alert.visible = false
	$Password.secret = true
	$Back.visible = false

	# Create an empty DB if it doesn't exist
	if not FileAccess.file_exists(DB_PATH):
		var file = FileAccess.open(DB_PATH, FileAccess.WRITE)
		file.store_string("{}")
		file.close()

# Handles signup/login button
func _on_button_button_down() -> void:
	var username_input = $Username.text.strip_edges()
	var password_input = $Password.text.strip_edges()

	if username_input == "" or password_input == "":
		$Alert.text = "Fields cannot be empty!"
		$Alert.visible = true
		return

	var db = load_database()

	if not is_login_mode:
		# ---------- SIGN UP ----------
		if db.has(username_input):
			$Alert.text = "Username already exists!"
			$Alert.visible = true
			return

		db[username_input] = password_input.sha256_text()
		save_database(db)

		is_login_mode = true
		$Alert.text = "Account Creation Successful!"
		$Alert.visible = true
		$Label.text = "Login"
		$Button.text = "Login"
		$Username.text = ""
		$Password.text = ""
		$Back.visible = true
		print("Account created - now log in")
		

	else:
		# ---------- LOGIN ----------
		if db.has(username_input):
			var stored_hash = db[username_input]
			var entered_hash = password_input.sha256_text()

			if stored_hash == entered_hash:
				print("Login Success")
				# load the next scene
				get_tree().change_scene_to_packed(step_counter)
			else:
				$Alert.text = "Wrong password!"
				$Alert.visible = true
				print("Login Unsuccessful - Wrong password")
		else:
			$Alert.text = "Account does not exist!"
			$Alert.visible = true
			print("Login Unsuccessful - Account does not exist")

# Directs you back to the sign up page
func _on_back_pressed():
	if is_login_mode:
		is_login_mode = false
		$Login.visible = true
		$Label.text = "Sign Up"
		$Button.text = "Sign Up"
		$Username.text = ""
		$Password.text = ""
		$Back.visible = false
		$Alert.visible = false
		print("Returned to sign-up mode.")

# Reveals or hides password text
func _on_reveal_pressed():
	$Password.secret = not $Password.secret
	
# Switches to login mode
func _on_login_pressed():
	$Back.visible = true
	$Login.visible = false
	$Button.text = "Login"
	$Label.text = "Login"
	is_login_mode = true 

# ---------- Database Handling ----------
func load_database() -> Dictionary:
	if not FileAccess.file_exists(DB_PATH):
		return {}
	var file = FileAccess.open(DB_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content) if content != "" else {}

func save_database(db: Dictionary) -> void:
	var file = FileAccess.open(DB_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(db))
	file.close()
