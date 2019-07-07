extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (int) var paint: int = 0

func test_display():
	if paint == 3 or paint == 0:
		visible = true
	elif paint == 2 and Global.current_level > 3:
		visible = true
	elif paint == 1 and Global.current_level > 1:
		visible = true
	else:
		visible = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.paint_selected == paint:
		disabled = true
	Global.paint_colors[paint] = self_modulate
	test_display()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	test_display()


func _on_btn_pressed():
	for btn in get_tree().get_nodes_in_group("color_btn"):
	    btn.disabled = false
	Global.paint_selected = paint
	disabled = true


func _on_btn_mouse_entered():
	Global.paint_prevent_focus = true

func _on_btn_mouse_exited():
	Global.paint_prevent_focus = false