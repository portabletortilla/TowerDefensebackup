extends ProgressBar

signal roundStart

func _ready():
	activate()

func _process(_delta):
	if self.visible == true:
		self.value = self.get_node("Timer").wait_time - get_node("Timer").time_left

func activate(duration=20):
	self.get_node("Timer").wait_time = duration
	self.max_value= duration
	self.get_node("Timer").start()
	


func _on_timer_timeout():
	self.visible = false
	
