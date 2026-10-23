class_name Hitbox
extends Area2D
## Sent after a hit lands (not when the target was invincible).
signal hit_landed(target: Node2D)
## Damage dealt per hit.
@export var damage: int = 5

@export var knockback_force: float = 300.0
## Seconds between hits from this hitbox.
@export var cooldown: float = 1.0
## Only bodies in this group can be hurt.
@export var target_group: StringName = &"player"
var _cooldown_timer: float = 0.0

func _physics_process(delta: float) -> void:
	_cooldown_timer = maxf(_cooldown_timer - delta, 0.0)
	if _cooldown_timer > 0.0:
		return
	
