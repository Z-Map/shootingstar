extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (float) var start_time: float = 2.0
export (float) var spawn_time: float = 0.8
export (float) var spawn_spread: float = 0.1
export (float) var Char_Lifetime: float = 60.0


var char_elm = preload("res://elements/Character.tscn")

func set_timer(t):
	t = t + rand_range(-spawn_spread, spawn_spread)
	$spawntime.start(t)
	$anim.play("spawn_anim", 0, 1 / t)

func _ready():
	set_timer(start_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	if Global.level_finished:
		$spawntime.stop()
		$anim.stop()
		$visual.frame = 0
	else:
		var inst:KinematicBody2D = char_elm.instance()
		inst.transform.origin = $SpawnPosition.global_transform.origin
		inst.lifetime = Char_Lifetime
		get_parent().add_child(inst)
		set_timer(spawn_time)
