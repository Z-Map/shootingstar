extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$Wintext.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start_current():
	if current != null:
		current.queue_free()
	var scene = Global.levels[Global.current_level]
	current = scene.instance()
	$ViewportContainer/Viewport.add_child(current)


func _on_Button_pressed():
	$CenterContainer/VBoxContainer/Button.disabled = true
	#Global.current_level = 0
	start_current()
	$scene_animation.play("Gamplay", 0, 2.0)


func _on_TextureButton_pressed():
	Global.level_finished = false
	Global.current_level += 1
	$TextureButton.visible = false
	if Global.current_level >= len(Global.levels):
		$Wintext.visible = true
		$scene_animation.play("Winscreen")
	else:
		start_current()
