extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const FAST_FALL_FACTOR = 4

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum State {IDLE, MOVE, ATTACK, HIT}
var state: State = State.IDLE
var flipped: bool = false
var time_elapsed: float = 0.0

#region Properties
var stationary: bool
var trigger_distance: int
var attack_speed: float
var base_damage: float
#endregion

enum EntityType {MUSHROOM}
@export var entity_type: EntityType
@export var World: Node2D
@export var AnimPlayer: AnimationPlayer
@export var Sprite: Sprite2D

func _ready() -> void:
	update_state(State.IDLE)
	update_properties()

func update_properties():
	match entity_type:
		EntityType.MUSHROOM: 
			stationary = true
			trigger_distance = 500
			attack_speed = 5.0
			base_damage = 10.0

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta

func _process(delta: float):
	time_elapsed += delta
	var player_position: Vector2 = World.get_player_position()
	var horizontal_difference: int = player_position.x - self.get_transform().get_origin().x
	
	var player_is_in_proximity = abs(horizontal_difference) <= trigger_distance
	if player_is_in_proximity:
		Movement(player_position, horizontal_difference)
		if is_on_floor() and time_elapsed >= attack_speed:
			time_elapsed = 0.0
			Attack()

func Movement(player_position: Vector2, horizontal_difference: int) -> void:
	if !stationary:
		if state != State.ATTACK and state != State.HIT:
			velocity.x = move_toward(self.get_transform().get_origin().x, player_position.x, float(SPEED))
			update_state(State.MOVE)
			flip_player(horizontal_difference)
		else:
			update_state(State.IDLE)
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func Attack() -> void:
	# calculate damage depending on Decay
	update_state(State.ATTACK)

func Hit() -> void:
	update_state(State.HIT)

func update_state(new_state: State) -> void:
	if state == new_state:
		return
	if state == State.ATTACK or state == State.HIT: # attacks cannot be canceled
		return
	state = new_state
	match new_state:
		State.IDLE:
			AnimPlayer.stop()
			AnimPlayer.play("Idle")
		State.MOVE:
			AnimPlayer.stop()
			AnimPlayer.play("Walk")
		State.ATTACK:
			AnimPlayer.stop()
			AnimPlayer.play("Attack")
		State.HIT:
			AnimPlayer.stop()
			AnimPlayer.play("Hit")

func flip_player(horizontal_difference: int) -> void:
	if !flipped && horizontal_difference < 0 \
			or flipped && horizontal_difference > 0:
		flipped = !flipped
		Sprite.flip_h = flipped

func _anim_attack_end() -> void:
	state = State.MOVE
	update_state(State.IDLE)

func _anim_parry_end() -> void:
	state = State.MOVE
	update_state(State.IDLE)
