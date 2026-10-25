extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const Life = 3

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if Input.is_action_pressed('Shift'):
			velocity.y = JUMP_VELOCITY - 100.0
		else:
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
const GAME_SCENE2 = preload("res://game_page_2.tscn")
	

const THEEND = preload("res://game_page_2.tscn")

func _on_edge_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_packed(THEEND)


func _on_edge_1_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_packed(GAME_SCENE2)
