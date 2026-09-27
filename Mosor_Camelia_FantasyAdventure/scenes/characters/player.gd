extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var speed = 200
@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = input_direction * speed

	move_and_slide()
