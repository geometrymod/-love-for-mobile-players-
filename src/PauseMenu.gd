extends Control

signal paused
signal unpaused

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	LevelManager.pause_manager = self
	$VBoxContainer/LevelName.text = LevelManager.current_level_name

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart_level"):
		_on_restart_pressed()
	if Input.is_action_just_pressed("pause_level"):
		_on_continue_pressed()

func _on_leave_pressed() -> void:
	get_tree().paused = false
	LevelManager.platformer = false
	SFXManager.play_sfx("res://assets/sounds/sfx/game_sfx/LevelQuit.ogg")
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")

func _on_continue_pressed() -> void:
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		emit_signal("paused")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_parent().show()
	else:
		emit_signal("unpaused")
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		get_parent().hide()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	emit_signal("unpaused")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	get_parent().hide()
