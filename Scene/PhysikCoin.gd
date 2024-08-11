extends RigidBody2D


@onready var World = get_tree().root.get_child(0)

func _physics_process(delta):
	self.rotation = 0

func set_velocity(amount: Vector2):
	linear_velocity = amount

func _on_area_2d_body_entered(body):
	if (body.name == "Player"):
		World.add_coins()
		World.play_audio("Coin Collect")
		queue_free()
