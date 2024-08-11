extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -800.0
const HIT_VELOCITY = 1200.0
const HIT_VELOCITY_VERTICAL = -200.0
const FAST_FALL_FACTOR = 4

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum State {IDLE, MOVE, ATTACK, HIT, DEATH}
var state: State = State.IDLE
var flipped: bool = false
var on_player: bool = false
var time_elapsed: float = 0.0
var time_elapsed_hit: float = 0.0
var health: int = 0
var death: bool = false

#region Properties
var stationary: bool
var trigger_distance: int
var attack_speed: float
var base_damage: float
var max_health: int
var pause_time_after_hit: float
#endregion

enum EntityType {MUSHROOM, LURP}
@export var entity_type: EntityType
@export var AnimPlayer: AnimationPlayer
@export var Sprite: Sprite2D
@export var Hitbox: Area2D
@export var Hurtbox: Area2D

@onready var World: Node2D = get_tree().root.get_child(0)

func _ready() -> void:
	update_state(State.IDLE)
	update_properties()
	health = max_health

func update_properties():
	match entity_type:
		EntityType.MUSHROOM: 
			stationary = false
			trigger_distance = 500
			attack_speed = 5.0
			base_damage = 40.0
			max_health = 40
			pause_time_after_hit = 2.0
		EntityType.LURP:
			stationary = false
			trigger_distance = 500
			attack_speed = -1.0
			base_damage = 30.0
			max_health = 20
			pause_time_after_hit = 2.0

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta

func _process(delta: float):
	time_elapsed += delta
	time_elapsed_hit += delta
	
	if on_player and time_elapsed_hit >= 1.5:
		time_elapsed_hit = 0.0
		var direction = -1
		if flipped:
			direction = 1
		World.damage_player(base_damage, direction)
	
	var player_position: Vector2 = World.get_player_position()
	var horizontal_difference: int = player_position.x - self.get_transform().get_origin().x
	
	var player_is_in_proximity = abs(horizontal_difference) <= trigger_distance
	if player_is_in_proximity:
		Movement(player_position, horizontal_difference)
		if is_on_floor() and time_elapsed >= attack_speed and attack_speed > 0:
			time_elapsed = 0.0
			Attack()


func Movement(player_position: Vector2, horizontal_difference: int) -> void:
	if !stationary:
		# determine direction
		var direction: int = 0
		if horizontal_difference < 0:
			direction = -1
		elif horizontal_difference > 0:
			direction = 1
		
		if state != State.ATTACK and state != State.HIT and state != State.DEATH:
			velocity.x = direction * SPEED
			update_state(State.MOVE)
			flip_player(-direction)
		else:
			update_state(State.IDLE)
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func Attack() -> void:
	# calculate damage depending on Decay
	update_state(State.ATTACK)

func Hit() -> void:
	var player_position: Vector2 = World.get_player_position()
	var horizontal_difference: int = player_position.x - self.get_transform().get_origin().x
	
	if horizontal_difference < 0:
		velocity.x = HIT_VELOCITY
	else:
		velocity.x = -HIT_VELOCITY
	velocity.y = HIT_VELOCITY_VERTICAL
	
	update_state(State.HIT)

func Death() -> void:
	update_state(State.DEATH)

func update_state(new_state: State) -> void:
	if state == new_state:
		return
	if (state == State.ATTACK or state == State.HIT or state == State.DEATH) and new_state != State.HIT: # attacks cannot be canceled
		return
	state = new_state
	match new_state:
		State.IDLE:
			AnimPlayer.stop()
			AnimPlayer.play("Idle")
		State.MOVE:
			AnimPlayer.stop()
			AnimPlayer.play("Run")
		State.ATTACK:
			AnimPlayer.stop()
			AnimPlayer.play("Attack")
		State.HIT:
			AnimPlayer.stop()
			AnimPlayer.play("Hit")
		State.DEATH:
			AnimPlayer.stop()
			AnimPlayer.play("Death")

func flip_player(direction: int) -> void:
	if !flipped && direction == -1 or flipped && direction == 1:
		flipped = !flipped
		Sprite.flip_h = flipped
		Hitbox.scale = Vector2(float(direction), 1.0)
		Hurtbox.scale = Vector2(float(direction), 1.0)

func _anim_attack_end() -> void:
	state = State.MOVE
	update_state(State.IDLE)

func _anim_parry_end() -> void:
	state = State.MOVE
	update_state(State.IDLE)

func _anim_hit_end() -> void:
	state = State.MOVE
	update_state(State.IDLE)
	if death:
		Death()

func _anim_death_end() -> void:
	queue_free()


func _on_hitbox_area_entered(area):
	if area.name == "Player Hurtbox":
		on_player = true
		if time_elapsed_hit >= 1.5:
			time_elapsed_hit = 0.0
			var direction: int = -1
			if flipped:
				direction = 1
			World.damage_player(base_damage, direction)


func _on_hitbox_area_exited(area):
	if area.name == "Player Hurtbox":
		on_player = false


func _on_hurtbox_area_entered(area):
	if !death:
		var damage_taken: int = int(str(area.name))
		health -= damage_taken
		if health <= 0:
			death = true
			Hitbox.queue_free()
			Hurtbox.queue_free()
		Hit()
