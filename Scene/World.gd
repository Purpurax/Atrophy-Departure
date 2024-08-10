extends Node2D

@export var UI: CanvasLayer
@export var Player: CharacterBody2D
@export var Camera: Camera2D



func add_coins():
	UI.coins_increase()
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
