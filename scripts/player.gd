extends CharacterBody3D;

@export var fall_acceleration: float = 45;
@export var speed: float = 10;
@export var jump_force: float = 10;

@export var rot_x: float = 0;
@export var rot_y: float = 0;

var target_velocity: Vector3 = Vector3.ZERO;

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
    Globals.player = self;

func _physics_process(delta: float) -> void:
    var direction = Vector3.ZERO;
    if Input.is_action_pressed("move_back"):
        direction.z += 1;
    if Input.is_action_pressed("move_forward"):
        direction.z -= 1;
    if Input.is_action_pressed("move_left"):
        direction.x -= 1;
    if Input.is_action_pressed("move_right"):
        direction.x += 1;
    
    if direction != Vector3.ZERO:
        direction = direction.normalized();
        direction = direction.rotated(Vector3.UP, rot_x);
        
    target_velocity.x = direction.x * speed;
    target_velocity.z = direction.z * speed;

    if not is_on_floor():
        target_velocity.y -= fall_acceleration * delta;
    else:
        target_velocity.y = 0;
        if Input.is_action_just_pressed("jump"):
            target_velocity.y = jump_force;

    velocity = target_velocity;
    move_and_slide();
    
func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        rot_x -= event.relative.x / 700;
        rot_y -= event.relative.y / 700;
        
        rot_y = clamp(rot_y, -PI / 2, PI / 2);
        
        $Pivot.rotation_degrees.y = rad_to_deg(rot_x);
        $Pivot.rotation_degrees.x = rad_to_deg(rot_y);
