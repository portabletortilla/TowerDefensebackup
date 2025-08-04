extends ProgressBar


func setup():
	self.max_value = get_parent().get_parent().maxHealth
	self.value = get_parent().get_parent().health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.value = get_parent().get_parent().health
	if self.value < self.max_value:
		self.show()
	else:
		self.hide()
