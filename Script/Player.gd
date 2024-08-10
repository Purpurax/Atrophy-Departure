extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const FAST_FALL_FACTOR = 4

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum State {IDLE, MOVE, ATTACK, PARRY}
var state: State = State.IDLE
var flipped: bool = false
var rust = false


@export var AnimPlayer: AnimationPlayer
@export var Sprite: Sprite2D

func _ready() -> void:
	update_state(State.IDLE)


func _physics_process(delta):
	if not is_on_floor():
		if Input.is_action_pressed("Down"):
			velocity.y += gravity * delta * FAST_FALL_FACTOR
		else:
			velocity.y += gravity * delta

func _process(delta):
	Movement()
	if is_on_floor() and Input.is_action_just_pressed("Attack"):
		Attack()
	if is_on_floor() and Input.is_action_just_pressed("Parry"):
		Parry()
	if Input.is_action_just_pressed("Rust"):
		rust = true
		
func Movement() -> void:
	if Input.is_action_just_pressed("Jump") and is_on_floor() and state != State.ATTACK and state != State.PARRY:
		velocity.y = JUMP_VELOCITY
	
	var direction: int = Input.get_axis("Left", "Right")
	if direction and state != State.ATTACK and state != State.PARRY:
		velocity.x = direction * SPEED
		update_state(State.MOVE)
		flip_player(direction)
	else:
		update_state(State.IDLE)
		velocity.x = move_toward(velocity.x, 0, SPEED/7)
	
	move_and_slide()

func Attack() -> void:
	# calculate damage depending on Decay
	update_state(State.ATTACK)

func Parry() -> void:
	update_state(State.PARRY)

func update_state(new_state: State) -> void:
	if state == new_state:
		return
	if state == State.ATTACK or state == State.PARRY: # attacks cannot be canceled
		return
	state = new_state
	match new_state:
		State.IDLE:
			if rust == false:
				AnimPlayer.stop()
				AnimPlayer.play("Idle")
			else:
				AnimPlayer.stop()
				AnimPlayer.play("Rust Idle")
		State.MOVE:
			if rust == false:
				AnimPlayer.stop()
				AnimPlayer.play("Walk")
			else:
				AnimPlayer.stop()
				AnimPlayer.play("Rust Walking")
		State.ATTACK:
			if rust == false:
				AnimPlayer.stop()
				AnimPlayer.play("Attack")
			else: 
				AnimPlayer.stop()
				AnimPlayer.play("Rust Attack")
		State.PARRY:
			if rust == false:
				AnimPlayer.stop()
				AnimPlayer.play("Parry")
			else:
				AnimPlayer.stop()
				AnimPlayer.play("Rust Parry")
func flip_player(direction: int) -> void:
	if !flipped && direction == -1 \
			or flipped && direction == 1:
		flipped = !flipped
		Sprite.flip_h = flipped

func _anim_attack_end() -> void:
	state = State.MOVE
	update_state(State.IDLE)

func _anim_parry_end() -> void:
	state = State.MOVE
	update_state(State.IDLE)
