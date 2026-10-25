
extends Node2D

@export var speed: float = 55.0
@export var patrol_distance: float = 100.0
@export var bounce_strength: float = -350.0

@onready var hurtbox: Area2D = $Body
@onready var stompbox: Area2D = $Top

var start_x: float
var direction: int = 1
var defeated: bool = false
var restarting: bool = false

func _ready() -> void:
	start_x = position.x

	hurtbox.body_entered.connect(_on_hurtbox_entered)
	stompbox.body_entered.connect(_on_stompbox_entered)

func _physics_process(delta: float) -> void:
	if defeated or restarting:
		return

	position.x += direction * speed * delta

	if position.x >= start_x + patrol_distance:
		direction = -1
	elif position.x <= start_x:
		direction = 1


func _on_stompbox_entered(body: Node2D) -> void:
	if defeated or restarting:
		return

	if not body.is_in_group("player"):
		return

	if body is CharacterBody2D and body.velocity.y > 0:
		defeat(body)


func _on_hurtbox_entered(body: Node2D) -> void:
	if defeated or restarting:
		return

	if not body.is_in_group("player"):
		return

	# Allow the stompbox to detect a landing first.
	await get_tree().physics_frame

	if not is_inside_tree() or defeated or restarting:
		return

	restarting = true
	get_tree().call_deferred("reload_current_scene")


func defeat(player: CharacterBody2D) -> void:
	defeated = true

	player.velocity.y = bounce_strength

	hurtbox.set_deferred("monitoring", false)
	stompbox.set_deferred("monitoring", false)

	var message := Label.new()
	message.text = "VIRUS DELETED!"
	message.position = Vector2(-45, -48)
	message.add_theme_color_override(
		"font_color", Color.GREEN
	)
	add_child(message)

	var tween := create_tween()

	tween.tween_property(
		self,
		"scale",
		Vector2.ZERO,
		0.2
	)

	tween.parallel().tween_property(
		message,
		"position:y",
		-70.0,
		0.2
	)

	tween.tween_callback(queue_free)


func _on_edge_1_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
