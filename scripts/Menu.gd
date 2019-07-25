extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current = null

var tuto_state : int = 0
var example_tile_paint: int = 0

var paint_placement := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Wintext.visible = false
	$DeathCounter.visible = false
	$special.visible = false
	$NextBtn.visible = false
	$ExampleTile.visible = false
	$ExampleTile/Pencil.visible = false
	$horloger.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tuto_state < 1000:
		tuto_process()
	if Global.level_resetable:
		$ResetBtn.visible = true
	else:
		$ResetBtn.visible = false

func start_current(reset = false):
	if current != null:
		current.queue_free()
	var scene = Global.levels[Global.current_level]
	current = scene.instance()
	$LvlContainer/lvlViewport.add_child(current)
	Global.should_spawn = true
	if not reset and Global.current_level in [11,14]:
		if $scene_animation.current_animation:
			$scene_animation.queue("special_placement")
		else:
			$scene_animation.play("special_placement", -1, 2.0)


func _on_Button_pressed():
	$TitleCont/TitleVCont/playBtn.disabled = true
	#Global.current_level = 0
	$scene_animation.play("Gamplay", -1, 2.0)
	start_current()
	$horloger.stop()
	$horloger.start(1.0)
	


func _on_TextureButton_pressed():
	Global.level_finished = false
	Global.level_resetable = false
	if Global.current_level in [11,14]:
		$scene_animation.play("special_placement", -1, -2.0, true)
	Global.current_level += 1
	$NextBtn.visible = false
	if Global.current_level >= len(Global.levels):
		$Wintext.visible = true
		$DeathCounter.visible = true
		if Global.death_counter:
			$DeathCounter.text = "By killing %d test subjects ..." % Global.death_counter
			$scene_animation.play("Winscreen")
		else:
			$DeathCounter.text = "And without any loss of test subject !"
			$scene_animation.play("TrueWinscreen")
	else:
		start_current()

func tuto_process():
	if tuto_state == 0 and Global.paint_selected:
		tuto_state = 10
		$ExampleTile.visible = true
	elif tuto_state == 20:
		$scene_animation.play("Start", 0, 1.0)
		tuto_state = 30

func _on_Timer_timeout():
	if tuto_state == 0 and Global.current_level > 0:
		tuto_state = 1000
		_on_Button_pressed()
	elif Global.current_level > 0:
		$TitleCont.visible = false
		$ExampleTile.visible = false
	$horloger.stop()


func _on_ExampleTile_mouse_entered():
	if example_tile_paint != Global.paint_selected:
		$ExampleTile/Pencil.visible = true
		$ExampleTile/Pencil.modulate = Global.paint_colors[Global.paint_selected]


func _on_ExampleTile_mouse_exited():
	$ExampleTile/Pencil.visible = false


func _on_ExampleTile_pressed():
	if example_tile_paint != Global.paint_selected:
		$ExampleTile/Pencil.visible = false
		$ExampleTile/All_Tile.frame = Global.paint_selected
		example_tile_paint = Global.paint_selected
		if tuto_state < 20:
			tuto_state = 20


func _on_ResetBtn_pressed():
	start_current(true)
