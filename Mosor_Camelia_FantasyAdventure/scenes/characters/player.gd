extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var speed = 200
@onready var animated_sprite = $AnimatedSprite2D

var last_direction = "down"
var is_action_playing = false

func update_direction(input_direction):
	if input_direction.y < 0:
		last_direction = "up"
	elif input_direction.y > 0:
		last_direction = "down"
	elif input_direction.x < 0:
		last_direction = "left"
	elif input_direction.x > 0:
		last_direction = "right"

func update_movement_animation(input_direction):
	if input_direction == Vector2.ZERO:
		animated_sprite.play("idle_" + last_direction)
	else:
		animated_sprite.play("run_" + last_direction)

func _physics_process(delta: float) -> void:
	
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = input_direction * speed
	
	update_direction(input_direction)
	
	if not is_action_playing:
		update_movement_animation(input_direction)


	move_and_slide()
