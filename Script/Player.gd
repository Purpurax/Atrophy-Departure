extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const FAST_FALL_FACTOR = 4

enum State {IDLE, MOVE, ATTACK, PARRY, HIT}
enum Decay {NONE, PARTIAL, RUST}

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state: State = State.IDLE
var decay: Decay = Decay.NONE
var flipped: bool = false



@export var AnimPlayer: AnimationPlayer
@export var Sprite: Sprite2D
@export var Hitbox: Area2D
@export var HitboxCollision: CollisionShape2D

func _ready() -> void:
	update_state(state, decay)


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
		
func Movement() -> void:
	if Input.is_action_just_pressed("Jump") and is_on_floor() and state != State.ATTACK and state != State.PARRY:
		velocity.y = JUMP_VELOCITY
	
	var direction: int = Input.get_axis("Left", "Right")
	if direction and state != State.ATTACK and state != State.PARRY:
		velocity.x = direction * SPEED
		update_state(State.MOVE, decay)
		flip_player(direction)
	else:
		update_state(State.IDLE, decay)
		velocity.x = move_toward(velocity.x, 0, SPEED/7)
	
	move_and_slide()

func Attack() -> void:
	var damage: float = 9.5
	Hitbox.name = str(int(damage))
	update_state(State.ATTACK, decay)

func Parry() -> void:
	update_state(State.PARRY, decay)

func update_state(new_state: State, new_decay: Decay) -> void:
	if state == new_state and new_decay == decay:
		return
	if state == State.ATTACK or state == State.PARRY: # attacks cannot be canceled
		return
	state = new_state
	decay = new_decay
	
	var animation_prefix: String
	match decay:
		Decay.NONE:
			animation_prefix = ""
		Decay.PARTIAL:
			animation_prefix = "Partial Rust "
		Decay.RUST:
			animation_prefix = "Rust "
	
	match new_state:
		State.IDLE:
			AnimPlayer.stop()
			AnimPlayer.play(animation_prefix + "Idle")
		State.MOVE:
			AnimPlayer.stop()
			AnimPlayer.play(animation_prefix + "Walk")
		State.ATTACK:
			#AnimPlayer.stop()
			AnimPlayer.play(animation_prefix + "Attack")
		State.PARRY:
			AnimPlayer.stop()
			AnimPlayer.play(animation_prefix + "Parry")
		State.HIT:
			AnimPlayer.stop()
			AnimPlayer.play(animation_prefix + "Hurt")

func update_decay(decay_percent: float):
	var new_decay: Decay
	if decay_percent >= 1.0:
		new_decay = Decay.RUST
	elif decay_percent >= 0.5:
		new_decay = Decay.PARTIAL
	else:
		new_decay = Decay.NONE
	
	update_state(state, new_decay)

func flip_player(direction: int) -> void:
	if !flipped && direction == -1 or flipped && direction == 1:
		flipped = !flipped
		Sprite.flip_h = flipped


func take_damage(amount: float, decay_percentage: float):
	print("Player says UFF")
	update_state(State.HIT, decay)

func _anim_end() -> void:
	state = State.MOVE
	update_state(State.IDLE, decay)


func _on_hitbox_area_entered(area):
	HitboxCollision.disabled = true
