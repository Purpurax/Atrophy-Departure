extends Area2D

@onready var World = get_tree().root.get_child(0)


func _on_body_entered(body):
	print("entered")
	if (body.name == "Player"):
		print("PLAYER")
		World.add_coins()
		queue_free()
