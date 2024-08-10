extends Area2D

@export var Message: Label

func _ready():
	Message.visible = false

func _on_body_entered(body):
	Message.visible = true


func _on_body_exited(body):
	Message.visible = false
