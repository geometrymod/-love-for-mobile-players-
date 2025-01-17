@tool
extends Node2D
class_name tSpawn

@export var _spawned_groups: Array[gSpawnedGroup]
@export var _loop: bool = false:
	set(value):
		_loop = value
		notify_property_list_changed()
@export var _loop_count: int = 1
@export_range(0.0, 10.0, 0.01, "or_greater", "suffix:s") var _loop_delay: float = 0.0

# Debugging purposes only
@export var _refresh_target_link: bool:
	set(value):
		_update_target_link()
@export var _clear_external_target_links: bool:
	set(value):
		for _group in _spawned_groups:
			get_node(_group.path).get_node("SpawnTargetLink").queue_free()


func _validate_property(property: Dictionary) -> void:
	if property.name in ["_loop_count", "_loop_delay"] and not _loop:
		property.usage = PROPERTY_USAGE_NO_EDITOR

var _current_loop: int
var _base: tBase
var _easing: tEasing
var _target_link: GDTargetLink
var _player: Player
var _setup: tSetup

func _ready() -> void:
	_setup = tSetup.new(self, true)
	_base._sprite.set_texture(preload("res://assets/textures/triggers/Spawn.svg"))
	_target_link.default_color = Color.CYAN
	_update_target_link()
	_player = LevelManager.player

func _start(_body: Node2D):
	if _loop and not _easing._tween.is_connected("finished", _restart):
		_easing._tween.finished.connect(_restart)
	_current_loop += 1

func _restart() -> void:
	await get_tree().create_timer(_loop_delay).timeout
	if _loop_count < 0 or _current_loop < _loop_count:
		_base.emit_signal("body_entered", _player)

func _update_target_link() -> void:
	if len(_spawned_groups) >= 1:
		_target_link._target = get_node_or_null(_spawned_groups[0].path)
	if len(_spawned_groups) >= 2:
		for i in range(len(_spawned_groups)-1):
			# Start loop at index 1, skipping the first spawned group since it already has a 'spawn' target link
			var _group = get_node(_spawned_groups[i].path)
			if not _group.has_node("SpawnTargetLink"):
				var _group_spawn_target_link: GDTargetLink = load("res://scenes/components/game_components/GDTargetLink.tscn").instantiate()
				_group_spawn_target_link.default_color = Color.CYAN
				_group_spawn_target_link.name = "SpawnTargetLink"
				_group_spawn_target_link.z_index -= 1
				_group_spawn_target_link._target = get_node_or_null(_spawned_groups[i+1].path)
				_group.add_child(_group_spawn_target_link)
				_group_spawn_target_link.owner = _group.get_parent()
			else:
				_group.get_node("SpawnTargetLink")._target = get_node_or_null(_spawned_groups[i+1].path)

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() and not is_zero_approx(_easing._weight):
		if _spawned_groups != null:
			for _group in _spawned_groups:
				if _easing._weight >= _group.time and _group.used_in_loop != _current_loop:
					if get_node(_group.path).has_node("tBase"): get_node(_group.path)._base.emit_signal("body_entered", _player)
					_group.used_in_loop = _current_loop
		else:
			printerr("In ", name, ": _target is unset")
	elif Engine.is_editor_hint() or LevelManager.in_editor:
		_target_link.position = Vector2.ZERO
		if len(_spawned_groups) >= 1 and _spawned_groups[0].is_connected("changed", _update_target_link):
			_spawned_groups[0].changed.connect(_update_target_link)
		if _spawned_groups.is_empty(): _target_link._target = null
		if Engine.is_editor_hint(): _base.position = Vector2.ZERO
