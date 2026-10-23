extends Node2D

@onready var player: CharacterBody2D = $Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.player_died.connect(_play_sad_music)

func _play_sad_music() -> void:
	$SadMusic.play()
