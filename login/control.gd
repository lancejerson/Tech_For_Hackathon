extends Control
@export var tab: Node

const DB_PATH := "user://users.json"
var create = false

#initiates the state of the elements
func _ready():
	$Alert.visible = false
	$Password.secret = true
	$Back.visible = false
	# Create an empty DB if it doesn't exist
	if not FileAccess.file_exists(DB_PATH):
		var file = FileAccess.open(DB_PATH, FileAccess.WRITE)
		file.store_string("{}")
		file.close()

#prints a message if you try signup with an empty form
func _on_button_button_down() -> void:
	var username_input = $Username.text.strip_edges()
	var password_input = $Password.text.strip_edges()
	if username_input == "" or password_input == "":
		print("Fields cannot be empty")
		return
	
	var db = load_database()
	#creates an account, when account is already created this directs you directly to the login page
	if !create:
		# Sign-up
		if db.has(username_input):
			$Alert.visible = !false
			return

		db[username_input] = password_input.sha256_text()
		save_database(db)

		create = true
		$Alert.text = "Account Creation was Successful!"
		$Label.text = "Login"
		$Button.text = "Login"
		$Username.text = ""
		$Password.text = ""
		$Back.visible = true
		print("Account created - now log in")

	else:
		# Login
		print("DB contents at login: ", db)
		print("Trying login for: ", username_input)

		if db.has(username_input):
			var stored_hash = db[username_input]
			var entered_hash = password_input.sha256_text()

			print("Stored hash: ", stored_hash)
			print("Entered hash: ", entered_hash)

			if stored_hash == entered_hash:
				print("Login Success")
				# CHANGED: Load scenes/run/run.tscn instead
				var err = get_tree().change_scene_to_file("res://Step_Counter.tscn")
				if err != OK:
					print("Failed to load scenes/run/run.tscn: ", err)
			else:
				print("Login Unsuccessful - Wrong password")
		else:
			print("Login Unsuccessful - Account does not exist")

#directs you back to the sign up page
func _on_back_pressed():
	if create:
		create = false
		$Login.visible = true
		$Label.text = "Sign Up"
		$Button.text = "Sign Up"
		$Username.text = ""
		$Password.text = ""
		$Back.visible = false
		print("Returned to sign-up mode.")

#reveals or encrypts the characters on the password form
func _on_reveal_pressed():
	$Password.secret = not $Password.secret
	
#directs to the login forms when you already have an account
func _on_login_pressed():
	$Back.visible = true
	# Hide the login button and change its text
	$Login.visible = false
	$Button.text = "Login"
	$Label.text = "Login"
	create = true 

	# Get the username and password input from the user
	var username_input = $Username.text.strip_edges()
	var password_input = $Password.text.strip_edges()

	# Load the database that contains the credentials
	var db = load_database()

	# Check if the username exists in the database
	if db.has(username_input):
			var stored_hash = db[username_input]
			var entered_hash = password_input.sha256_text()

			print("Stored hash: ", stored_hash)
			print("Entered hash: ", entered_hash)

			if stored_hash == entered_hash:
				print("Login Success")
				# CHANGED: Load scenes/run/run.tscn instead
				var err = get_tree().change_scene_to_file("res://Step_Counter.tscn")
				if err != OK:
					print("Failed to load scenes/run/run.tscn: ", err)
			else:
				print("Login Unsuccessful - Wrong password")
	else:
		print("Login Unsuccessful - Account does not exist")
		
func load_database() -> Dictionary:
	var file = FileAccess.open(DB_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content) if content != "" else {}

func save_database(db: Dictionary) -> void:
	var file = FileAccess.open(DB_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(db))
	file.close()
