extends Area2D

@onready var World = get_tree().root.get_child(0)



func _on_body_entered(body):
	if (body.name == "Player"):
		queue_free()
		World.add_coins()
