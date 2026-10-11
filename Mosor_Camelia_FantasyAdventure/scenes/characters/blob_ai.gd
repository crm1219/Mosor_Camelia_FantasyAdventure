extends CharacterBody2D

const PATROL_SPEED = 50.0
const CHASE_SPEED = 100.0

@onready var animated_sprite = $AnimatedSprite2D
var player = null

enum State {IDLE, PATROL, CHASE}

var current_state = State.IDLE
var time_elapsed = 0

var current_waypoint = 1

func _physics_process(delta: float) -> void:
	
	time_elapsed += delta
	
	if position.distance_to(Vector2(50, 50)) < 10:
		current_waypoint = 2
		
	if position.distance_to(Vector2(500, 300)) < 10:
		current_waypoint = 1
	
	if (current_state == State.IDLE):
		animated_sprite.play("idle")
		if (time_elapsed >= 2):
			current_state = State.PATROL
	elif (current_state == State.PATROL):
		if current_waypoint == 1:
			velocity = position.direction_to(Vector2(50, 50)) * PATROL_SPEED
		elif current_waypoint == 2:
			velocity = position.direction_to(Vector2(500, 300)) * PATROL_SPEED
		move_and_slide()
	elif (current_state == State.CHASE):
		#pass
		velocity = position.direction_to(player.position) * CHASE_SPEED
		move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if time_elapsed > 1:
		current_state = State.CHASE
		player = get_node("../Player")

func _on_area_2d_body_exited(body: Node2D) -> void:
	current_state = State.PATROL
	#player = null
