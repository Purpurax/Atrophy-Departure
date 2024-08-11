extends RigidBody2D

const time_before_delete = 1.0

var time_elapsed = 0.0

func _physics_process(delta):
	self.rotation = 0
	time_elapsed += delta
	if time_elapsed >= time_before_delete:
		queue_free()

func set_velocity(amount: Vector2):
	linear_velocity = amount

