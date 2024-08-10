extends TextureProgressBar

var time=0
func _ready():
	value=max_value
	
func _process(delta):
	time +=delta
	value = int(time)
	print(value)
