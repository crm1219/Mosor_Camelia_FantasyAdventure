extends CharacterBody2D

@export_group("Movement")
@export var patrol_speed: float = 40.0
@export var chase_speed: float = 70.0

@export_group("Idle and Patrol Timing")
@export var idle_time_min: float = 1.0
@export var idle_time_max: float = 3.0
@export var patrol_time_min: float = 1.5
@export var patrol_time_max: float = 4.0

@export_group("Chasing")
@export var detection_range: float = 120.0
@export var give_up_time: float = 3.0

const BLOB_GROUP := &"blobs"
const PLAYER_GROUP := &"player"

var _state_timer: float = 0.0
var _chase_timer: float = 0.0
var _patrol_direction := Vector2.ZERO
var _player: Node2D = null

enum State { IDLE, PATROL, CHASE }
var state: State = State.IDLE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group(BLOB_GROUP)
	hitbox.hit_landed.connect(_on_hit_landed)
	_start_idle()
	
func _on_hit_landed(_target: Node2D) -> void:
	# The player did not evade, so restart the give-up clock.
	if state == State.CHASE:
		_chase_timer = give_up_time

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(PLAYER_GROUP) as Node2D
	match state:
		State.IDLE:
			_update_idle(delta)
		State.PATROL:
			_update_patrol(delta)
		State.CHASE:
			_update_chase(delta)
	move_and_slide()
	_bounce_off_walls()
	if velocity.x != 0.0:
		sprite.flip_h = velocity.x < 0.0
	
func _bounce_off_walls() -> void:
	if state != State.PATROL:
		return
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()
		if _patrol_direction.dot(normal) < 0.0:
			_patrol_direction = _patrol_direction.bounce(normal)
		
func _start_chase() -> void:
	state = State.CHASE
	_chase_timer = give_up_time
	_play_animation("move")

func _player_in_range() -> bool:
	if not is_instance_valid(_player):
		return false
	var distance := global_position.distance_to(_player.global_position)
	return distance <= detection_range
			
func _start_idle() -> void:
	state = State.IDLE
	_state_timer = randf_range(idle_time_min, idle_time_max)
	velocity = Vector2.ZERO
	_play_animation("idle")
	
func _start_patrol() -> void:
	state = State.PATROL
	_state_timer = randf_range(patrol_time_min, patrol_time_max)
	_patrol_direction = Vector2.from_angle(randf_range(0.0, TAU))
	_play_animation("move")
	
func _play_animation(anim_name: StringName) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
		
func _update_idle(delta: float) -> void:
	velocity = Vector2.ZERO
	_state_timer -= delta
	if _state_timer <= 0.0:
		_start_patrol()
		
func _update_patrol(delta: float) -> void:
	velocity = _patrol_direction * patrol_speed
	_state_timer -= delta
	if _player_in_range():
		_start_chase()
	elif _state_timer <= 0.0:
		_start_idle()
		
func _update_chase(delta: float) -> void:
	# Rule 1: the player got out of range -- give up right away.
	if not _player_in_range():
		_start_idle()
		return
	# Rule 2: the player has evaded the blob for too long -- give up.
	_chase_timer -= delta
	if _chase_timer <= 0.0:
		_start_idle()
		return
	var to_player := global_position.direction_to(_player.global_position)
	velocity = to_player * chase_speed
	
# Place this at the bottom of your BlobMonster AI script
func take_damage(amount: int) -> void:
	# If you decide to add an enemy health variable later, manage it
	# here!
	# For now, let's just make it die instantly upon a player strike
	die()
	
func die() -> void:
# Safely vanish the monster scene tree instance cleanly between
# engine steps
	queue_free()
	
