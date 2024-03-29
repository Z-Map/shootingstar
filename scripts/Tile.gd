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
	$speed_area/area.disabled = true
	$gravity_area/area.disabled = true
	if paint:
		add_to_group("painted")
		if paint == 3:
			effect = $eclair
			$speed_area/area.disabled = false
		elif paint == 2:
			effect = $gravite
			$gravity_area/area.disabled = false
		elif paint == 1:
			effect = $bubble
		set_anim()
	else:
		if is_in_group("painted"):
			remove_from_group("painted")
		effect = null

func set_anim():
	if $delay.is_stopped() and not $anim.is_playing():
		var min_t = min_anim_time
		var max_t = max_anim_time
		if current_paint == 2:
			min_t *= 0.9
			max_t *= 0.25
		elif current_paint == 1:
			min_t *= 3
			max_t *= 2
		$delay.start(rand_range(min_t, max_t))

func _input(event):
	if Global.paint_selected != current_paint:
		if mouse_on and event.is_action_pressed("Paint"):
			set_paint(Global.paint_selected)
			$Target_paint.visible = false
			Global.paint_autoset = true
		elif event is InputEventScreenTouch and event.pressed:
			var tr = get_canvas_transform()
			var pos = Vector2(event.position.x / tr.x.x, event.position.y / tr.y.y)
			if Rect2(global_position - Vector2(16,16),Vector2(32,32)).has_point(pos):
				print("I'm in " + name)
				set_paint(Global.paint_selected)
				$Target_paint.visible = false
		elif event is InputEventScreenDrag:
			var tr = get_canvas_transform()
			var pos = Vector2(event.position.x / tr.x.x, event.position.y / tr.y.y)
			if Rect2(global_position - Vector2(16,16),Vector2(32,32)).has_point(pos):
				print("I'm passing through " + name)
				set_paint(Global.paint_selected)
				$Target_paint.visible = false

func _on_WhiteTile_mouse_entered():
	mouse_on = true
	if Global.paint_autoset:
		set_paint(Global.paint_selected)
	

func _on_WhiteTile_mouse_exited():
	mouse_on = false
	anti_focus = false
	$Target_paint.visible = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if current_paint:
		set_anim()
	elif current_effect:
		current_effect.visible = false
		current_effect = null

func _on_timeout():
	if current_effect:
		current_effect.visible = false
		current_effect = null
	if effect:
		current_effect = effect
		current_effect.visible = true
		$anim.play("sprites", 0, 1.5)


func _on_speed_area_body_entered(body):
	body.be_the_flash(true)


func _on_speed_area_body_exited(body):
	body.be_the_flash(false)


func _on_gavity_area_body_entered(body):
	body.change_gravity(-transform.y, get_rid().get_id())
