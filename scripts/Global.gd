extends Node

var current_scene = null

var paint_selected: int = 0
export (Array) var paint_colors: Array = [Color(1,1,1), Color(0.9,0,1), Color(0.4, 0.35, 1.0), Color(1, 0.87, 0) ]
var paint_autoset := false
var paint_prevent_focus := false

var level_finished: bool = false

# Pour rajouter un level :
# Ajouter une virgule après le dernier preload, passer à la ligne et 
# écrire :
# preload("res://levels/nom.tscn")
# En modifiant "nom" par le nom du niveau.
const levels = [preload("res://levels/tuto1.tscn"),
	preload("res://levels/tuto2.tscn"),
	preload("res://levels/tuto3.tscn"),
	preload("res://levels/lvl1.tscn"),
	preload("res://levels/lvl2.tscn"),
	preload("res://levels/lvl3.tscn"),
	preload("res://levels/lvl4.tscn")
	]

var current_level := 0

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


func _input(event):
	if event.is_action_released("Paint"):
		paint_autoset = false
	if event.is_action_pressed("Exit"):
		get_tree().quit()