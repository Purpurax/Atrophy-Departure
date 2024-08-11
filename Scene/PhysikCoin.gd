extends RigidBody2D


@onready var World = get_tree().root.get_child(0)


func _on_area_2d_body_entered(body):
		print(body.name)
		if (body.name == "Player"):
			World.add_coins()
			queue_free()
			
