extends CanvasLayer

const EMPTY_FRAME = 199

var coins: int = 0
var frames: Array[int] = []

@export var coins_label: Label
@export var DecayProgressBar: TextureProgressBar
@export var HealthBar: TextureProgressBar
@export var Items: Array[TextureRect]

func _ready():
	update_coin_label("0")
	update_health(1.0)
	update_decay(0.0)
	
	for _i in range(len(Items)):
		frames.append(EMPTY_FRAME)
	update_frames()

func update_coin_label(text: String):
	coins_label.text = text

func update_decay(decay: float):
	DecayProgressBar.value = int(DecayProgressBar.max_value * decay)

func update_health(percentage: float):
	var value: int = int(percentage * 100)
	HealthBar.value = value

func update_frames():
	for i in range(len(Items)):
		Items[i].set_frame(frames[i])

func get_item_frames() -> Array[int]:
	return frames

func equip_item(new_frame: int) -> bool:
	var successful: bool = EMPTY_FRAME in frames
	if !successful:
		return successful
	
	for i in range(len(frames)):
		if frames[i] == EMPTY_FRAME:
			frames[i] = new_frame
			update_frames()
			break
		if i == len(frames) - 1:
			successful = false
	return successful
