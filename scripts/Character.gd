extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (float) var lifetime: float = 60.0

export (float) var gravity_force: float = 500.0
export (float) var walk_speed: float = 50.0
export (float) var bounce_multiply: float = 350.0
export (float) var speed_modif: float = 0.05
export (float) var flash_speed: float = 5.0


export (int) var anim_idle_start: int = 0
export (int) var anim_idle_end: int = 4
export (float) var anim_idle_frametime: float = 0.2

export (int) var anim_falling_start: int = 18
export (int) var anim_falling_end: int = 21
export (float) var anim_falling_frametime: float = 0.1

export (int) var anim_walking_start: int = 8
export (int) var anim_walking_end: int = 13
export (float) var anim_walking_frametime: float = 0.1

export (int) var trans_falling_start: int = 15
export (int) var trans_falling_end: int = 17
export (float) var trans_falling_frametime: float = 0.1

export (int) var trans_walking_start: int = 6
export (int) var trans_walking_end: int = 7
export (float) var trans_walking_frametime: float = 0.2

export (int) var trans_landing_start: int = 22
export (int) var trans_landing_end: int = 27
export (float) var trans_landing_frametime: float = 0.1

export (int) var trans_death_start: int = 27
export (int) var trans_death_end: int = 44
export (float) var trans_death_frametime: float = 0.07

var direction: Vector2 = Vector2(1, 0.0)
var gravity_dir: Vector2 = Vector2(0.0, 1)
var gravity_x: bool = false

var falling: bool = false
var landing: bool = false
var walking: bool = false

var active_trans: bool = false

var transition: float = 0.0

var anim_s: int = 0
var anim_e: int = 4
var anim_f: int = 0
var anim_d: float = 0.2

var speed_mult:float = 1.0
var grav_speed_mult: float = 1.0
var target_velocity: Vector2 = Vector2(0.0, 0.0)
var gravity: Vector2 = Vector2(0.0,0.0)
var velocity: Vector2 = Vector2(0.0,0.0)
var inertia: Vector2 = Vector2(0.0,0.0)

var last_jump_bloc: int = 0
var last_gravity_bloc: int = 0

var on_ground:bool = false
var flash:int = 0
var dead:bool = false
var go_to_heaven: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$lifetime.start(lifetime)
	
func set_transition():
	active_trans = true
	if go_to_heaven:
		anim_s = 15
		anim_e = 18
		anim_d = 0.5
	elif dead:
		anim_s = trans_death_start
		anim_e = trans_death_end
		anim_d = trans_death_frametime
	elif falling:
		anim_s = trans_falling_start
		anim_e = trans_falling_end
		anim_d = trans_falling_frametime
	elif walking:
		anim_s = trans_walking_start
		anim_e = trans_walking_end
		anim_d = trans_walking_frametime
	elif landing:
		anim_s = trans_landing_start
		anim_e = trans_landing_end
		anim_d = trans_landing_frametime
	anim_f = anim_s
	
func set_animation():
	if falling:
		anim_s = anim_falling_start
		anim_e = anim_falling_end
		anim_d = anim_falling_frametime
	elif walking:
		anim_s = anim_walking_start
		anim_e = anim_walking_end
		anim_d = anim_walking_frametime
	anim_f = anim_s

func process_special_bloc(colide: KinematicCollision2D):
	var n = colide.collider
	if n.current_paint == 1 and last_jump_bloc != colide.collider_id:
		last_jump_bloc = colide.collider_id
		var bounce_vec = colide.normal * bounce_multiply
		if falling:
			on_ground = false
			velocity = inertia.bounce(colide.normal)
			var bounce_acc = bounce_vec.length() / velocity.length()
			if bounce_acc > 1.0:
				velocity *= bounce_acc
		else:
			velocity += bounce_vec
		
func process_collision():
	on_ground = is_on_floor()
	var bump = false
	var touch_paint = false
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if (collision.normal + direction).length() < 0.1:
			bump = true
		if collision.collider.is_in_group("painted") and collision.collider.current_paint == 1:
			process_special_bloc(collision)
			touch_paint = true
	if not touch_paint:
		last_jump_bloc = 0

func _physics_process(delta):
	if dead or go_to_heaven:
		return
	if flash:
		speed_mult += ((flash_speed - speed_mult) / 2) * delta
	elif speed_mult > 1.0:
		speed_mult = clamp(speed_mult - speed_modif, 1.0, flash_speed)
	inertia += gravity_dir * gravity_force * delta
	if speed_mult > 1.0:
		speed_mult = clamp(speed_mult - speed_modif, 1.0, .0)
	if walking:
		target_velocity = direction * walk_speed * speed_mult
	else:
		target_velocity = Vector2(0,0)
	if (inertia * direction.abs()).length() < target_velocity.length():
		inertia += target_velocity
	var snap = gravity_dir 
	velocity = move_and_slide_with_snap(inertia, snap, -gravity_dir)
	var bump = process_collision()
	if on_ground:
		if falling:
			falling = false
			landing = true
			walking = false
			set_transition()
			velocity = Vector2(0,0)
		elif walking and bump:
			direction = -direction
			$CharSprite.scale.x = -$CharSprite.scale.x
	elif not falling:
		falling = true
		walking = false
		landing = false
		set_transition()
	inertia = velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	transition += delta
	if go_to_heaven:
		$CharSprite.global_transform.origin.y -= 32 * delta 
		$CharSprite.modulate.a -= 0.58 * delta
	var t = anim_d / speed_mult
	if transition > t:
		transition -= t
		anim_f += 1
	if anim_f > anim_e:
		if dead or go_to_heaven:
			queue_free()
		elif active_trans:
			active_trans = false
			if landing:
				landing = false
				walking = true
				set_transition()
			else:
				set_animation()
		else:
			anim_f = anim_s
	$CharSprite.frame = anim_f

func invert_gravity():
	gravity_dir = -gravity_dir
	$CharSprite.scale.y = -$CharSprite.scale.y
	gravity = gravity_dir

func change_gravity(surface_vec:Vector2):
	if abs(surface_vec.x) > 0.01:
		if gravity_x:
			invert_gravity()
		else:
			gravity_x = true
			direction = Vector2(0.0, direction.x * gravity_dir.y * -surface_vec.x)
			gravity_dir = Vector2(-surface_vec.x, 0)
			$CharSprite.scale.x =  abs($CharSprite.scale.x) * direction.y
			$CharSprite.scale.y =  abs($CharSprite.scale.y) * gravity_dir.x
			transform.x = Vector2(0,1)
			transform.y = Vector2(1,0)
		inertia.x = 0.0
	else:
		if gravity_x:
			gravity_x = false
			direction = Vector2(direction.y * gravity_dir.x * -surface_vec.y, 0.0)
			gravity_dir = Vector2(0, -surface_vec.y)
			$CharSprite.scale.x =  abs($CharSprite.scale.x) * direction.x
			$CharSprite.scale.y =  abs($CharSprite.scale.y) * gravity_dir.y
			transform.x = Vector2(1,0)
			transform.y = Vector2(0,1)
		else:
			invert_gravity()
		inertia.y = 0.0

func kill():
	dead = true
	set_transition()

func win():
	go_to_heaven = true
	$CharSprite.scale.y = 1
	speed_mult = 1.0
	set_transition()
	
func be_the_flash(to_be_or_not_to_be: bool = true):
	if to_be_or_not_to_be:
		flash += 1 
	else:
		flash -= 1

func _on_lifetime_timeout():
	$lifetime.stop()
	kill()
