extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	level = Global.current_level

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	body.win()
	if Global.current_level <= level:
		Global.level_finished = true
		Global.should_spawn = false
