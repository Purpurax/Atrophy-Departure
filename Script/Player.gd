extends CharacterBody2D


var speed = 400.0
const JUMP_VELOCITY = -800.0
const HIT_VELOCITY = 1200.0
const HIT_VELOCITY_VERTICAL = -500.0
const PARRY_VELOCITY = 700.0
const FAST_FALL_FACTOR = 4

enum State {IDLE, MOVE, ATTACK, PARRY, HIT, DEATH}
enum Decay {NONE, PARTIAL, RUST}

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state: State = State.IDLE
var decay: Decay = Decay.NONE
var flipped: bool = false
var parrying: bool = false
var rust_attack: bool = false
var death_called: bool = false
var shield = 0

#region Player Properties
var death: bool = false
var max_health: float = 100
var health: float = 0
var damage: float = 19.0
var dashdamage = 0
var healamp = 1
#endregion


@export var AnimPlayer: AnimationPlayer
@export var Sprite: Sprite2D
@export var Hitbox: Area2D
@export var HitboxCollision: CollisionShape2D
@export var HurtboxCollision: CollisionShape2D

@onready var World = get_tree().root.get_child(0)

func _ready() -> void:
	health = max_health
	update_state(state, decay)

func _physics_process(delta):
	if not is_on_floor():
		if Input.is_action_pressed("Down") and state != State.HIT and state != State.DEATH:
			velocity.y += gravity * delta * FAST_FALL_FACTOR
		else:
			velocity.y += gravity * delta

func _process(delta):
	Movement()
	if is_on_floor() and Input.is_action_just_pressed("Attack") and !death:
		Attack()
		print(healamp)
	if is_on_floor() and Input.is_action_just_pressed("Parry") and !death:
		Parry()
		
func Movement() -> void:
	if Input.is_action_just_pressed("Jump") and is_on_floor() and state != State.ATTACK and state != State.PARRY and state != State.HIT and state != State.DEATH:
		velocity.y = JUMP_VELOCITY
		World.play_audio("Jump")
	
	var direction: int = Input.get_axis("Left", "Right")
	if direction and state != State.ATTACK and state != State.PARRY and state != State.HIT and state != State.DEATH:
		velocity.x = direction * speed
		update_state(State.MOVE, decay)
		flip_player(direction)
	elif state != State.HIT and state != State.DEATH:
		update_state(State.IDLE, decay)
	if parrying:
		direction = 1
		if flipped:
			direction = -1
		velocity.x = direction * PARRY_VELOCITY
	velocity.x = move_toward(velocity.x, 0, speed/7)
	
	move_and_slide()

func Attack() -> void:
	if rust_attack:
		var decay_current: float = World.get_decay_current()
		Hitbox.name = str(int(damage + decay_current / 8))
	else:
		Hitbox.name = str(int(damage))
	
	update_state(State.ATTACK, decay)

func Parry() -> void:
	Hitbox.name = str(int(damage / 2 + dashdamage))
	update_state(State.PARRY, decay)

func Death() -> void:
	HurtboxCollision.disabled = true
	if !death_called:
		print("DEATH")
		death_called = true
		World.play_audio("Player Death")
		update_state(State.DEATH, decay)

func update_state(new_state: State, new_decay: Decay) -> void:
	if state == new_state and new_decay == decay:
		return
	if (state == State.ATTACK or state == State.PARRY) and new_state != State.HIT and new_state != State.DEATH: # attacks cannot be canceled
		return
	state = new_state
	if decay != new_decay:
		if new_decay == Decay.PARTIAL:
			World.play_audio("Rusting Partial")
		elif new_decay == Decay.RUST:
			World.play_audio("Rusting Fully")
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
			AnimPlayer.stop()
			AnimPlayer.play(animation_prefix + "Attack")
		State.PARRY:
			AnimPlayer.stop()
			AnimPlayer.play(animation_prefix + "Parry")
		State.HIT:
			AnimPlayer.stop()
			AnimPlayer.play(animation_prefix + "Hurt")
		State.DEATH:
			AnimPlayer.stop()
			AnimPlayer.play(animation_prefix + "Death")

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
		Hitbox.scale = Vector2(float(direction), 1.0)


func take_damage(amount: float, decay_percentage: float, direction: int) -> float:
	if direction == 1:
		velocity.x = HIT_VELOCITY
	elif direction == -1:
		velocity.x = -HIT_VELOCITY
	flip_player(-direction)
	velocity.y = HIT_VELOCITY_VERTICAL
	
	var truedmg = amount + (decay_percentage * 40) - shield
	
	health -= int(truedmg)
	death = health <= 0
	
	update_state(State.HIT, decay)
	World.show_damage_number(self.position, int(truedmg), true)
	World.play_audio("Player Hurt")
	
	return health / max_health

func _anim_attack_time(time: float) -> void:
	if time == 0.0:
		HitboxCollision.disabled = true
		HitboxCollision.position = Vector2(2, 14)
		HitboxCollision.shape.radius = 7
		HitboxCollision.shape.height = 66
	elif time == 0.1:
		HitboxCollision.position = Vector2(-7, 17)
	elif time == 0.2:
		HitboxCollision.position = Vector2(-10, 20)
	elif time == 0.4:
		HitboxCollision.position = Vector2(46, 10)
		HitboxCollision.shape.radius = 13
		HitboxCollision.shape.height = 166
		HitboxCollision.disabled = false
		World.play_audio("Sword Hit")
	elif time == 0.7:
		HitboxCollision.position = Vector2(32, 12)
		HitboxCollision.shape.radius = 9
		HitboxCollision.shape.height = 108

func _anim_parry_time(time: float) -> void:
	if time == 0.0:
		HitboxCollision.disabled = true
		HitboxCollision.position = Vector2(2, 14)
		HitboxCollision.shape.radius = 7
		HitboxCollision.shape.height = 66
		HurtboxCollision.disabled = false
	elif time == 0.5:
		HurtboxCollision.disabled = true
		HitboxCollision.disabled = false
		HitboxCollision.position = Vector2(42, 6)
		HitboxCollision.shape.radius = 34
		HitboxCollision.shape.height = 68
		parrying = true
	elif time == 1.0:
		HitboxCollision.disabled = true
		HitboxCollision.position = Vector2(2, 14)
		HitboxCollision.shape.radius = 7
		HitboxCollision.shape.height = 66
		HurtboxCollision.disabled = false
		parrying = false

func _anim_end() -> void:
	HitboxCollision.position = Vector2(2, 14)
	HitboxCollision.shape.radius = 7
	HitboxCollision.shape.height = 66
	HitboxCollision.disabled = true
	HurtboxCollision.disabled = false
	
	if death:
		Death()
	else:
		state = State.MOVE
		update_state(State.IDLE, decay)


func _on_hitbox_area_entered(area):
	HitboxCollision.disabled = true

func death_box_hit():
	queue_free()

func increase_damage(amount: float):
	damage += amount

func increase_maxhealth(amount: float):
	max_health += amount
	print(max_health)

func increase_speed(amount: float):
	speed += amount

func heal(amount: float):
	health += amount + healamp
	World.UpdateHealth(health / max_health)

func activate_shield(amount: float):
	shield = amount
	
func activate_DashDamage(amount: float):
	dashdamage += amount

func activate_HealAmp(amount: float):
	healamp *= amount

func activate_rust_attack(decay_current: float):
	rust_attack = true
