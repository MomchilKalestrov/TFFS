extends Area3D

@export var speed: float = 20.0;
@export var damage: float = 10.0;
@export var lifetime: float = 10.0;
@export var shooter: String;

func _ready() -> void:
    $Timer.wait_time = lifetime;
    add_to_group("Bullets");

func _process(delta: float) -> void:
    var direction: Vector3 = transform.basis.z.normalized();
    global_transform.origin += direction * speed * delta;

func _on_body_entered(body: Node) -> void:
    if body.has_method("subtract_health"):
        body.subtract_health(damage);
    queue_free();

func _on_timer_timeout() -> void:
    queue_free();

func _on_collision(body: Node) -> void:
    if body.is_in_group("Bullets") or body.name == shooter:
        return;
    
    if body.has_method("subtract_health"):
        body.subtract_health(damage);
    
    queue_free();
