extends KinematicBody2D


export var A = 0
export var G = 0
export var MAX_SPEED = 0
export var MAX_RUN_SPEED = 0
export var MAX_FALLING_SPEED = 0
export var MAX_JUMP_SPEED = 0


var speed = 0
var current_falling_speed = 0
var spr


func _ready():
	Global.Player = self
	spr = $Body/AnimSprite

func set_it(anim):
	if spr.animation != anim:
		print("anim: ", anim)
		spr.animation = anim


func set_anim(anim):
	var main_list = ["StartJump", "Fall"]
	
	if anim in main_list:
		set_it(anim)
		return
	
	if "Attack" in [spr.animation, anim]:
		spr.get_child(0).visible = true
		speed = 0
		
		if spr.frame == 5:
			spr.animation = "Default"
	
	if not "Attack" in spr.animation or spr.frame == 5:
		set_it(anim)


func _physics_process(delta):
	var velocity = 0
	var max_speed = MAX_SPEED
	
	if Input.is_action_pressed("ui_right"):
		velocity = 1
		spr.flip_h = false
	if Input.is_action_pressed("ui_left"):
		velocity = -1
		spr.flip_h = true
	if Input.is_action_pressed("run"):
		velocity *= 2
		max_speed = MAX_RUN_SPEED
	
	
	var delta_speed = velocity * A * delta
	
	if speed != 0:
		var dir = speed / abs(speed)
		if (delta_speed == 0 or dir != velocity / abs(velocity)):
			delta_speed = -dir * A * delta * 4
	
	if is_on_wall():
		speed = 0
	
	if is_on_ceiling():
		current_falling_speed = 0
	
	if is_on_floor():
		current_falling_speed = 0
		
		if Input.is_action_pressed("jump"):
			current_falling_speed = -MAX_JUMP_SPEED
		
		if current_falling_speed < 0:
			set_anim("StartJump")
		elif Input.is_action_pressed("sAttack"):
			set_anim("StandartAttack")
		elif velocity == 0:
			set_anim("Ready")
		elif max_speed != MAX_SPEED:
			set_anim("Run")
		else:
			set_anim("Walk")
	else:
		if velocity == 0:
			delta_speed /= 8
		
		if current_falling_speed > G * delta * 2:
			set_anim("Fall")
		current_falling_speed = clamp(current_falling_speed + G * delta,-MAX_JUMP_SPEED, MAX_FALLING_SPEED)
	
	speed = clamp(delta_speed + speed, -max_speed, max_speed)
	
	if abs(speed) < 20 and velocity == 0:
		speed = 0
	
	move_and_slide(Vector2(speed, current_falling_speed), Vector2.UP)


func _on_Attack_body_entered(body):
	print(body.name)
