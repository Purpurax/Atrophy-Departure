extends Node2D

@export var Music: AudioStreamPlayer2D
@export var Coin: AudioStreamPlayer2D
@export var Jump: AudioStreamPlayer2D
@export var SwordHit: AudioStreamPlayer2D
@export var SwordHit2: AudioStreamPlayer2D
@export var ChestOpen: AudioStreamPlayer2D
@export var PlayerHurt: AudioStreamPlayer2D
@export var PlayerDeath: AudioStreamPlayer2D
@export var PlayerFall: AudioStreamPlayer2D
@export var GameOverDefault: AudioStreamPlayer2D
@export var GameOverTroll: AudioStreamPlayer2D
@export var Victory: AudioStreamPlayer2D
@export var RustingPartial: AudioStreamPlayer2D
@export var RustingFully: AudioStreamPlayer2D

func play_audio(name: String):
	match name:
		"Coin Collect":
			Coin.pitch_scale = randf_range(0.8, 1.2)
			Coin.play()
		"Jump":
			Jump.play()
		"Sword Hit":
			if randf() < 0.6:
				SwordHit.play()
			else:
				SwordHit2.play()
		"Chest Open":
			ChestOpen.play()
		"Player Hurt":
			PlayerHurt.play()
		"Player Death":
			PlayerDeath.play()
		"Player Fall":
			PlayerFall.play()
		"Game Over":
			Music.stop()
			if randf() < 0.92:
				GameOverDefault.play()
			else:
				GameOverTroll.play()
		"Victory":
			Music.stop()
			Victory.play()
		"Rusting Partial":
			RustingPartial.play()
		"Rusting Fully":
			RustingFully.play()
		_:
			print("tried to play audio withs: " + name)
