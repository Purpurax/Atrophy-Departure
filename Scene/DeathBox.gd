extends Area2D

@export var World: Node2D


func _on_body_entered(body):
	World.delete_entity(body)
