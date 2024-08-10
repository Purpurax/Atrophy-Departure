extends CharacterBody2D

@export var ButtonPrompt: Sprite2D
@export var AnimPlayer: AnimationPlayer

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
var open: bool = false
var player_in_proximity: bool = false

func _ready():
	ButtonPrompt.visible = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _process(delta):
	if player_in_proximity == true and Input.is_action_pressed("Interact"):
		open_chest()

func open_chest():
	# generate loot and send to world, then send from world to player
	AnimPlayer.play("Chest Opens")
	ButtonPrompt.visible = false
	open = true


func _on_area_2d_body_entered(body):
	player_in_proximity = true
	if open == false:
		ButtonPrompt.visible = true
	else:
		ButtonPrompt.visible = false
	
func _on_area_2d_body_exited(body):
	player_in_proximity = false
	ButtonPrompt.visible = false


	
