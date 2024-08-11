extends Area2D


@onready var World = get_tree().root.get_child(0)


func _on_body_entered(body):
	if (body.name == "Player"):
		World.add_coins()
		queue_free()
