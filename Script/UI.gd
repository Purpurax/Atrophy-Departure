extends CanvasLayer

var coins: int = 0

@export var coins_label: Label
@export var DecayProgressBar: TextureProgressBar
@export var HealthBar: TextureProgressBar

func _ready():
	update_coin_label("0")
	update_health(1.0)
	update_decay(0.0)

func update_coin_label(text: String):
	coins_label.text = text

func update_decay(decay: float):
	DecayProgressBar.value = int(DecayProgressBar.max_value * decay)

func update_health(percentage: float):
	var value: int = int(percentage * 100)
	HealthBar.value = value
