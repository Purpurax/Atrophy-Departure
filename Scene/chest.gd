extends CharacterBody2D

@export var ButtonPrompt: Sprite2D
@export var AnimPlayer: AnimationPlayer
@export var Price: Label

@onready var World: Node2D = get_tree().root.get_child(0)

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
var open: bool = false
var player_in_proximity: bool = false

func _ready():
	ButtonPrompt.visible = false
	Price.visible = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _process(delta):
	if player_in_proximity == true and Input.is_action_pressed("Interact") and !open and World.get_coins() >= 10:  
		open_chest()

func open_chest():
	# generate loot and send to world, then send from world to player
	World.coins_decrease_by(10)
	World.play_audio("Chest Open")
	ButtonPrompt.visible = false
	Price.visible = false
	AnimPlayer.play("Chest Opens")
	open = true
	
	var frame = World.generate_item_frame()
	# display frame over chest ?? when, for how long
	
	var player_can_take_item = World.equip_item(frame)
	if !player_can_take_item:
		print("Player is full")


func _on_area_2d_body_entered(body):
	player_in_proximity = true
	if open == false:
		ButtonPrompt.visible = true
		Price.visible = true
	else:
		ButtonPrompt.visible = false
		Price.visible = false
	
func _on_area_2d_body_exited(body):
	player_in_proximity = false
	ButtonPrompt.visible = false
	Price.visible = false



