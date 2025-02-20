extends CharacterBody2D

@export var gravity = 750
@export var run_speed = 750
@export var jump_speed = -300

enum {IDLE, RUN, JUMP, HURT, DEAD}
var state = IDLE

func _ready() -> void:
	change_state(IDLE)
	
func reset(_position):
	position = _position
	show()
	change_state(IDLE)
	
func get_input():
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	
	# movement occurs in all states
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	# only allow jumping when on the ground
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
	# IDLE transitions to RUN when moving
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	# Run transition to IDLE when standing still
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	# transition to JUMP when in the air
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)
		
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		RUN:
			$AnimationPlayer.play("run")
		HURT:
			$AnimationPlayer.play("hurt")
		JUMP:
			$AnimationPlayer.play("jump_up")
		DEAD:
			hide()

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	get_input()
	
	move_and_slide()
	
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	
	if state == JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")
	
