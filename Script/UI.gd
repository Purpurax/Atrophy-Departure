extends CanvasLayer

var coins: int = 0

@export var coins_label: Label

func update_coin_label(text: String):
	coins_label.text = text
