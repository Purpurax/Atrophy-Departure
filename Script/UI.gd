extends CanvasLayer

var coins: int = 0

@export var coins_label: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_coin_label()


func update_coin_label():
	coins_label.text = str(coins)

func coins_increase():
	coins += 1

func coins_decrease_by(n: int):
	coins -= n
