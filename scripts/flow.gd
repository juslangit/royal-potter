extends Node
## Moves between screens and plays sound. Registered as the autoload `Flow`.

const SCREENS := {
	"wheel": "res://scenes/wheel.tscn",
}

const BLIP := preload("res://assets/audio/blip.wav")

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.stream = BLIP
	add_child(_player)


func go(screen: String) -> void:
	get_tree().change_scene_to_file(SCREENS[screen])


## Phone browsers stay silent until the first touch; any tap that calls this wakes sound up.
func blip(pitch := 1.0) -> void:
	_player.pitch_scale = pitch
	_player.play()
