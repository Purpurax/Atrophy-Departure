extends Node2D

const LEFT_CAMERA_CAP: int = 0
const TOP_CAMERA_CAP: int = -300
const RIGHT_CAMERA_CAP: int = 16500
const BOTTOM_CAMERA_CAP: int = 300
const COIN_VELOCITY: int = 200
const DMG_VELOCITY: int = 100
const DMG_VELOCITY_VERTICAL: int = -50

var coins: int = 0
var decay_max: float = 175.0
var decay_speed: float = 1.0
var decay_current: float = 0.0

var decay_mend = false
var coin_reap = false
var coin_vamp = false
var decay_slow = false

@export var UI: CanvasLayer
@export var Player: CharacterBody2D
@export var Camera: Camera2D
@export var AudioPlayer: Node2D

@onready var Coin_Instance = preload("res://Scene/PhysikCoin.tscn")
@onready var Damage_Number_Instance = preload("res://Scene/damage_number.tscn")

func _ready():
	UI.update_coin_label(str(coins))

func _process(delta):
	if Player != null:
		move_camera()
		decay(delta)

func move_camera() -> void:
	var player_position: Vector2 = Player.get_transform().get_origin()
	var camera_position: Vector2 = Camera.get_transform().get_origin()
	
	var difference: Vector2 = player_position - camera_position
	
	var smoothed_horizontal_movement: int = move_toward(camera_position.x, player_position.x, 0.7 * sqrt(abs(difference.x)))
	var smoothed_vertical_movement: int = move_toward(camera_position.y, player_position.y, 0.7 * sqrt(abs(difference.y)))
	
	Camera.transform.origin = Vector2(min(max(smoothed_horizontal_movement, LEFT_CAMERA_CAP), RIGHT_CAMERA_CAP), \
		min(max(smoothed_vertical_movement, TOP_CAMERA_CAP), BOTTOM_CAMERA_CAP))

func reload():
	get_tree().reload_current_scene()

func show_game_over():
	play_audio("Game Over")
	UI.show_game_over()
	
func show_victory():
	play_audio("Victory")
	UI.show_victory()

func decay(delta: float):
	decay_current += delta * decay_speed
	if decay_current >= decay_max:
		decay_current = decay_max
	UI.update_decay(decay_current / decay_max)
	Player.update_decay(decay_current / decay_max)

func UpdateHealth( percentage : float):
	UI.update_health(percentage)

func scatter_coins_from(position: Vector2, coin_amount: int):
	for _i in range(coin_amount):
		var coin = Coin_Instance.instantiate()
		coin.position = position
		coin.set_velocity(Vector2(COIN_VELOCITY * randf_range(-1.0, 1.0), -COIN_VELOCITY * randf_range(0.0, 1.0) - 150.0))
		add_child(coin)

func show_damage_number(position: Vector2, damage_amount: int, red: bool = false):
	var dmg_number = Damage_Number_Instance.instantiate()
	if randi():
		dmg_number.position = position + Vector2(10.0, -20.0)
		dmg_number.set_velocity(Vector2(DMG_VELOCITY, DMG_VELOCITY_VERTICAL))
	else:
		dmg_number.position = position + Vector2(-10.0, -20.0)
		dmg_number.set_velocity(Vector2(-DMG_VELOCITY, DMG_VELOCITY_VERTICAL))
	
	if red:
		dmg_number.set_font_color_red()
	dmg_number.set_damage(damage_amount)
	add_child(dmg_number)

func get_coins():
	return coins

func play_audio(name: String):
	AudioPlayer.play_audio(name)

func add_coins():
	coins += 1
	if decay_mend:
		decay_current -= 0.5
	if coin_reap:
		Player.increase_damage(0.5)
	if coin_vamp:
		Player.heal(0.5)
	UI.update_coin_label(str(coins))

func coins_decrease_by(n: int):
	coins -= n
	if coin_reap:
		Player.increase_damage(-n+0.5)
	UI.update_coin_label(str(coins))


func get_player_position() -> Vector2:
	if Player != null:
		return Player.get_transform().get_origin()
	return Vector2(0,0)

func damage_player(amount: float, direction: int):
	decay(amount)
	var health_percentage: float = Player.take_damage(amount, decay_current / decay_max, direction)
	UI.update_health(health_percentage)
	
func delete_entity(entity: Node2D):
	if entity.name == "Player":
		play_audio("Player Fall")
		show_game_over()
		Player.queue_free()
	entity.call_deferred("queue_free")


func generate_item_frame() -> int:
	var have_frames: Array[int] = UI.get_item_frames()
	var all_frames: Array[int] = [
		3, # Item Increases Damage
		106, # Item Increases max_health
		35, # Item Increases Damage with Coins
		152, # Item Restores Decay when picking up Coins
		196, # Item increases Speed
		191, # Item slows decay
		65, # Items Heals player with coins
		49, # Item decreases damage taken
		109,
		60,
		17,
	]
	var possible_frames: Array[int] = []
	for frame in all_frames:
		if !(frame in have_frames):
			possible_frames.append(frame)
	
	if len(possible_frames) == 0:
		return -1
	
	return possible_frames.pick_random()

func equip_item(frame: int) -> bool:
	var successful = UI.equip_item(frame)
	if successful: update_player_stats(frame)
	return successful

func update_player_stats(frame: int):
	match frame:
		3:
			Player.increase_damage(10.0)
		106:
			Player.increase_maxhealth(20.0)
		152:
			decay_mend = true
		35:
			coin_reap = true
			Player.increase_damage(coins)
		196:
			Player.increase_speed(30.0)
		191:
			decay_slow = true
			decay_speed -= 0.1
		65:
			coin_vamp = true
		49:
			Player.activate_shield(10.0)
		109:
			Player.activate_DashDamage(5.0)
		60:
			Player.activate_HealAmp(2.0)
		17:
			Player.activate_rust_attack(decay_current)

func get_decay_current() -> float:
	return decay_current



func _on_victory_area_body_entered(body):
	print("Victory")
	show_victory()
