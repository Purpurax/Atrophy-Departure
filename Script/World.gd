extends Node2D

var coins: int = 0

@export var UI: CanvasLayer
@export var Player: CharacterBody2D
@export var Camera: Camera2D

func _ready():
	UI.update_coin_label(str(coins))

func _process(delta):
	move_camera()

func move_camera() -> void:
	const LEFT_X_CAP: int = 0
	const RIGHT_X_CAP: int = 10000
	var player_horizontal_position: int = Player.get_transform().get_origin().x
	var camera_horizontal_position: int = Camera.get_transform().get_origin().x
	
	var difference: int = abs(player_horizontal_position - camera_horizontal_position)
	
	var smoothed_horizontal_movement = move_toward(camera_horizontal_position, player_horizontal_position, 0.7 * sqrt(difference))
	if smoothed_horizontal_movement < LEFT_X_CAP:
		smoothed_horizontal_movement = LEFT_X_CAP
	elif smoothed_horizontal_movement > RIGHT_X_CAP:
		smoothed_horizontal_movement = RIGHT_X_CAP
	
	Camera.transform.origin = Vector2(smoothed_horizontal_movement, 0)

func get_player_position() -> Vector2:
	return Player.get_transform().get_origin()

func add_coins():
	coins += 1
	UI.update_coin_label(str(coins))

func coins_decrease_by(n: int):
	coins -= n
	UI.update_coin_label(str(coins))
