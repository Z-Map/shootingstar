extends StaticBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (float) var min_anim_time = 1.0
export (float) var max_anim_time = 5.0

var mouse_on:bool = false
var anti_focus:bool = false
export (int) var current_paint:int = 0

var effect: Sprite = null
var current_effect: Sprite = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$Target_paint.visible = false
	set_paint(current_paint)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_on:
		if Global.paint_prevent_focus:
			mouse_on = false
			anti_focus = true
			$Target_paint.visible = false
		else:
			$Target_paint.modulate = Global.paint_colors[Global.paint_selected]
			if Global.paint_selected != current_paint:
				$Target_paint.visible = true
			else:
				$Target_paint.visible = false
	elif anti_focus and not Global.paint_prevent_focus:
		mouse_on = true

func set_paint(paint:int):
	current_paint = paint
	$visual.frame = paint
	if paint:
		add_to_group("painted")
		if paint == 3:
			effect = $eclair
		elif paint == 2:
			effect = $gravite
		set_anim()
	else:
		if is_in_group("painted"):
			remove_from_group("painted")
		effect = null

func set_anim():
	if $delay.is_stopped() and not $anim.is_playing():
		$delay.start(rand_range(min_anim_time, max_anim_time))

func _input(event):
	if mouse_on and event.is_action_pressed("Paint"):
		set_paint(Global.paint_selected)
		$Target_paint.visible = false
		Global.paint_autoset = true

func _on_WhiteTile_mouse_entered():
	mouse_on = true
	if Global.paint_autoset:
		set_paint(Global.paint_selected)
	

func _on_WhiteTile_mouse_exited():
	mouse_on = false
	anti_focus = false
	$Target_paint.visible = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if current_effect:
		current_effect.visible = false
		current_effect = null
	if current_paint:
		set_anim()

func _on_timeout():
	if effect:
		current_effect = effect
		current_effect.visible = true
		$anim.play("sprites", 0, 1.5)
