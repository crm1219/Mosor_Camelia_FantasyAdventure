extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var speed = 200
@onready var animated_sprite = $AnimatedSprite2D

var last_direction = "down"
var is_action_playing = false

signal health_changed(current_health, max_health)
@export var max_health: int = 100
# How long the player remains immune to damage after a hit (in
# seconds)
@export var iframe_duration: float = 0.6
var current_health: int

# Reference the child hurtbox node
@onready var hurtbox: Hurtbox = $PlayerHurtbox

func _ready() -> void:
	current_health = max_health
	# Only emit if someone is actively listening,
	# otherwise let the UI handle it in its own _ready() function
	if health_changed.get_connections().size() > 0:
		health_changed.emit(current_health, max_health)
	
	# Connect the hurtbox signal directly to our take_damage
	# function
	hurtbox.damage_received.connect(take_damage)
	
func take_damage(amount: int) -> void:
	current_health = clampi(current_health - amount, 0,
	max_health)
	health_changed.emit(current_health, max_health)
	# Activate the invincibility window on our hurtbox
	hurtbox.start_invincibility(iframe_duration)

	# Optional: Trigger visual feedback for I-Frames
	flash_sprite()
	if current_health <= 0:
		die()
		
func heal(amount: int) -> void:
	current_health = clampi(current_health + amount, 0,
	max_health)
	health_changed.emit(current_health, max_health)
	
func flash_sprite() -> void:
	# Create a quick visual flash using an inline tween
	var flash_tween = create_tween()
	# Drop opacity or change color briefly, then return to
	# normal
	flash_tween.tween_property(animated_sprite, "modulate:a", 0.4,
	iframe_duration / 4.0)
	flash_tween.tween_property(animated_sprite, "modulate:a", 1.0,
	iframe_duration / 4.0)
	flash_tween.tween_property(animated_sprite, "modulate:a", 0.4,
	iframe_duration / 4.0)
	flash_tween.tween_property(animated_sprite, "modulate:a", 1.0,
	iframe_duration / 4.0)
	
func die() -> void:
	print("Player died!")

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
		
func play_action_animation(action_name):
	is_action_playing = true
	animated_sprite.play(action_name + "_" + last_direction)

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		play_action_animation("attack")
	elif event.is_action_pressed("test_hit"):
		play_action_animation("hit")
	elif event.is_action_pressed("test_die"):
		play_action_animation("die")

func _physics_process(delta: float) -> void:
	
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = input_direction * speed
	
	update_direction(input_direction)
	
	if not is_action_playing:
		update_movement_animation(input_direction)


	move_and_slide()

func _on_animated_sprite_2d_animation_finished() -> void:
	is_action_playing = false
