extends ProgressBar

func _ready() -> void:
	max_value = 100
	value = max_value

func _on_player_health_changed(new_health: Variant) -> void:
	value = new_health
