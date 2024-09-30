extends CharacterBody3D

@export var fall_acceleration = 75
@export var mouse_sens = 0.01
@export var speed = 10
@export var jump_force = 10

@export var rot_x = 0
@export var rot_y = 0

var target_velocity = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_just_pressed("jump") and is_on_floor():
		target_velocity.y = jump_force
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		direction = direction.rotated(Vector3.UP, rot_x)
		
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y -= fall_acceleration * delta
	else:
		target_velocity.y = 0

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
func _input(event):
	if event is InputEventMouseMotion:
		rot_x -= event.relative.x * mouse_sens
		rot_y -= event.relative.y * mouse_sens
		
		rot_y = clamp(rot_y, -PI / 2, PI / 2)
		
		$Pivot.rotation_degrees.y = rad_to_deg(rot_x)
		$Pivot.rotation_degrees.x = rad_to_deg(rot_y)
