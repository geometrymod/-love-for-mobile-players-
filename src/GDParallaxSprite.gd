extends Sprite2D

class_name GDParallaxSprite

@export var camera: GDPlayerCamera
@export var parallax_factor: Vector2
# Intended for use in menus, where the GDParallaxObject needs to scroll but the camera is static.
@export var autoscroll_speed: Vector2
const NOTIFIER_WIDTH: float = 10.0

func _ready() -> void:
	set_texture_repeat(TEXTURE_REPEAT_ENABLED)
	set_region_enabled(true)
	region_rect.size = Vector2(
		texture.get_size().x * 5,
		texture.get_size().y
		)
	$NotifierLeft.rect = Rect2(
		region_rect.position.x - region_rect.size.x/2,
		region_rect.position.y - region_rect.size.y/2,
		NOTIFIER_WIDTH,
		region_rect.size.y,
		)
	$NotifierRight.rect = Rect2(
		region_rect.position.x + region_rect.size.x/2 + NOTIFIER_WIDTH,
		region_rect.position.y - region_rect.size.y/2,
		NOTIFIER_WIDTH,
		region_rect.size.y,
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += camera.delta_position.x * parallax_factor.x + autoscroll_speed.x * delta
	position.y += camera.delta_position.y * parallax_factor.y + autoscroll_speed.y * delta
	
	position.x += texture.get_width() * scale.x * (int($NotifierRight.is_on_screen()) - int($NotifierLeft.is_on_screen()))

