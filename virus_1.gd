
extends Area2D

@export var speed: float = 55.0
@export var patrol_distance: float = 100.0
@export var bounce_strength: float = -320.0

var start_x: float
var direction: int = 1
var defeated: bool = false

func _ready() -> void:
	start_x = position.x
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if defeated:
		return

	position.x += direction * speed * delta

	if position.x >= start_x + patrol_distance:
		position.x = start_x + patrol_distance
		direction = -1

	elif position.x <= start_x:
		position.x = start_x
		direction = 1

func _on_body_entered(body: Node2D) -> void:
	if defeated:
		return

	if not body.is_in_group("player"):
		return

	# Player must be falling onto the virus
	var is_falling: bool = body.velocity.y > 0

	# Check if player's feet are near the virus's top
	var player_feet: float = body.global_position.y + 12.0
	var virus_top: float = global_position.y - 12.0

	var landed_on_top: bool = player_feet <= virus_top + 12.0

	if is_falling and landed_on_top:
		defeat(body)
	else:
		get_tree().call_deferred("reload_current_scene")

func defeat(player: Node2D) -> void:
	defeated = true

	# Bounce the player up
	player.velocity.y = bounce_strength

	# Prevent more collisions
	set_deferred("monitoring", false)

	# Floating message
	var message := Label.new()
	message.text = "VIRUS DELETED!"
	message.add_theme_color_override(
		"font_color", Color("#FFFFFF")
	)
	message.position = Vector2(-42, -35)
	add_child(message)

	# Animate the message upward
	var tween := create_tween()
	tween.tween_property(
		message,
		"position:y",
		-65.0,
		0.35
	)

	# Shrink the virus
	tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ZERO,
		0.25
	)

	tween.tween_callback(queue_free)
