extends TextureProgressBar
# How long the bar takes to slide to the new value (in seconds)
@export var animation_duration: float = 0.25

@export var player: CharacterBody2D

# Holds the active tween animation instance
var health_tween: Tween
func _ready() -> void:
# Locate the player node using the group we created
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		update_bar(player.current_health, player.max_health)
		
# Public function that the player can call safely
func update_bar(current: int, max_hp: int) -> void:
	max_value = max_hp
	value = current
		
func _on_player_health_changed(current_health: int, max_health: int) -> void:
	# 1. Update the maximum capacity dynamically if your player levels up/buffs max health
	max_value = max_health
	
	update_bar(current_health, max_health)
	
	# 2. Stop any ongoing health animations to prevent overlapping glitches from fast hits
	if health_tween and health_tween.is_running():
		health_tween.kill()
	# 3. Create a brand new Tween instance
	health_tween = create_tween()
	# 4. Animate the progress bar "value" smoothly to the new health number
	health_tween.tween_property(self, "value", current_health,
	animation_duration)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_OUT)
