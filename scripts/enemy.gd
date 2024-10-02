extends CharacterBody3D;


@export var bullet_scene: PackedScene;
@export var speed: float = 3.0;
@export var stab_range: float = 2.0;
@export var shooting_range: float = 10.0;
@export var detection_range: float = 30.0;
@export var designated_location: Vector3;
@export var fall_acceleration: float = 45.0;
@export var shooting_timeout: float = 5;
@export var health: float = 100;

var can_attack: bool = true;
var player: CharacterBody3D = null;
var target_npc: RigidBody3D = null;
var state: String = "Idle";

func _ready() -> void:
    player = Globals.get_player();
    add_to_group("Enemies");
    $Timer.wait_time = shooting_timeout;

func _process(delta: float) -> void:
    match state:
        "AttackPlayer":
            look_at(player.global_transform.origin, Vector3.UP);
            chase_player(delta);
        "AttackNPC":
            if is_instance_valid(target_npc):
                var target = target_npc.global_transform.origin;
                target.y -= 1;
                look_at(target, Vector3.UP);
            attack_npc(delta);
        "GoToLocation":
            go_to_location(delta);
        _:
            find_target();
            
func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= fall_acceleration * delta;
    else:
        velocity.y = 0;
    velocity.x = 0;
    velocity.z = 0;
    move_and_slide();
    

func _on_attack_timer_timeout():
    can_attack = true;

func find_target() -> void:
    if player and is_player_near():
        state = "AttackPlayer";
    elif find_closest_npc():
        state = "AttackNPC";
    else:
        state = "GoToLocation";

func is_player_near() -> bool:
    return global_transform.origin.distance_to(player.global_transform.origin) <= detection_range;

func find_closest_npc() -> bool:
    var npcs = get_tree().get_nodes_in_group("NPCs");
    var closest_distance: float = detection_range;
    target_npc = null;

    for npc in npcs:
        var distance = global_transform.origin.distance_to(npc.global_transform.origin);
        if distance < closest_distance:
            closest_distance = distance;
            target_npc = npc;

    return target_npc != null;

func chase_player(delta: float) -> void:
    if is_player_near():
        var location: Vector3 = player.global_transform.origin;
        if global_transform.origin.distance_to(location) <= shooting_range:
            shoot();
            return;
        move_towards(location, delta);
        if global_transform.origin.distance_to(location) <= stab_range:
            stab(player);
    else:
        state = "Idle";

func attack_npc(delta: float) -> void:
    if not is_instance_valid(target_npc):
        state = "Idle";
        return;
    
    if target_npc and global_transform.origin.distance_to(target_npc.global_transform.origin) <= detection_range:
        if global_transform.origin.distance_to(target_npc.global_transform.origin) <= shooting_range:
            shoot();
            return;
        move_towards(target_npc.global_transform.origin, delta);
        if global_transform.origin.distance_to(target_npc.global_transform.origin) <= stab_range:
            stab(target_npc);
    else:
        state = "Idle";

func go_to_location(delta: float) -> void:
    if global_transform.origin.distance_to(designated_location) < 0.5:
        state = "Idle";
    else:
        move_towards(designated_location, delta);

func move_towards(target_position: Vector3, delta: float) -> void:
    var direction: Vector3 = (target_position - global_transform.origin).normalized();
    direction.y = 0;
    velocity = direction * speed;
    move_and_slide();

func stab(target: Object) -> void:
    if target.has_method("subtract_health") and can_attack:
        can_attack = false;
        get_node("Timer").start();
        target.subtract_health(45.0);

func shoot() -> void:
    if can_attack:
        can_attack = false;
        get_node("Timer").start();
        var bullet = bullet_scene.instantiate() as Area3D;
        bullet.global_transform = $GunEnd.global_transform;
        bullet.shooter = name;
        get_tree().root.add_child(bullet);

func subtract_health(ammount: float) -> void:
    health -= ammount;
    if (health <= 0):
        queue_free();
    
