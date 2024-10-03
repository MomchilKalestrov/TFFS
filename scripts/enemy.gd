extends CharacterBody3D;


@export var bullet_scene: PackedScene;
@export var speed: float = 6.0;
@export var stabbing_range: float = 2.0;
@export var shooting_range: float = 10.0;
@export var detection_range: float = 30.0;
@export var designated_location: Vector3;
@export var fall_acceleration: float = 45.0;
@export var shooting_timeout: float = 5;
@export var health: float = 100;
@export var navmesh: NavigationRegion3D;

var can_attack: bool = true;
var target_npc: RigidBody3D = null;
var state: String = "Idle";
var path: PackedVector3Array;
var current_path_index: int = 0;
var navigation_map: RID;

func _ready() -> void:
    add_to_group("Enemies");
    $Timer.wait_time = shooting_timeout;
    navigation_map = navmesh.get_navigation_map();

func _process(delta: float) -> void:
    match state:
        "AttackPlayer":
            look_at(Globals.player.global_transform.origin, Vector3.UP);
            chase_player(delta);
        "AttackNPC":
            if is_instance_valid(target_npc):
                var target: Vector3 = target_npc.global_transform.origin;
                target.y -= 1;
                look_at(target, Vector3.UP);
            attack_npc(delta);
        "GoToLocation":
            var target: Vector3 = designated_location;
            target.y = global_transform.origin.y;
            look_at(target, Vector3.UP);
            go_to_location(delta);
        _:
            find_target();
            
func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= fall_acceleration * delta;
    else:
        velocity.y = 0;
    move_and_slide();
    

func _on_attack_timer_timeout():
    can_attack = true;

func find_target() -> void:
    if Globals.player and is_target_near(Globals.player):
        state = "AttackPlayer";
    elif find_closest_npc():
        state = "AttackNPC";
    else:
        state = "GoToLocation";

func is_in_shooting_distance(target: Node3D) -> bool:
    return global_transform.origin.distance_to(target.global_transform.origin) <= shooting_range;
    
func is_in_stabbing_distance(target: Node3D) -> bool:
    return global_transform.origin.distance_to(target.global_transform.origin) <= stabbing_range;

func is_target_near(target: Node3D) -> bool:
    return global_transform.origin.distance_to(target.global_transform.origin) <= detection_range;

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
    if Globals.player and is_target_near(Globals.player):
        var location: Vector3 = Globals.player.global_transform.origin;
        if is_in_shooting_distance(Globals.player):
            velocity = Vector3.ZERO;
            move_and_slide();
            shoot();
            return;
            
        move_towards(location, delta, false);
        if is_in_stabbing_distance(Globals.player):
            stab(Globals.player);
    else:
        state = "Idle";


func attack_npc(delta: float) -> void:
    if not is_instance_valid(target_npc):
        state = "Idle";
        path.clear();
        return;
    
    if target_npc and is_target_near(target_npc):
        if is_in_shooting_distance(target_npc):
            velocity = Vector3.ZERO;
            move_and_slide();
            shoot();
            return;
        
        move_towards(target_npc.global_transform.origin, delta, false);
        if is_in_stabbing_distance(target_npc):
            stab(target_npc);
    else:
        state = "Idle";
        path.clear();

func go_to_location(delta: float) -> void:
    if global_transform.origin.distance_to(designated_location) >= 0.5:
        move_towards(designated_location, delta, true);
    state = "Idle";

func move_towards(target_position: Vector3, delta: float, look: bool) -> void:
    navmesh_move_towards(target_position, delta, look);
    return;
    var direction: Vector3 = (target_position - global_transform.origin).normalized();
    direction.y = 0;
    velocity = direction * speed;
    move_and_slide();
    return;

func navmesh_move_towards(target_position: Vector3, delta: float, look: bool) -> void:
    if path.is_empty() or current_path_index >= path.size():
        path = NavigationServer3D.map_get_path(navigation_map, global_transform.origin, target_position, false);
        current_path_index = 0;

    if path.size() > 1 and current_path_index < path.size():
        var next_point = path[current_path_index];
        if global_transform.origin.distance_to(next_point) < 0.5:
            current_path_index += 1;
        else:
            var direction: Vector3 = (next_point - global_transform.origin).normalized();
            direction.y = 0;
            if direction.x < 0.001 and direction.z < 0.001:
                # next node is basically the same location as now.
                # try to brute force it
                print("ROUTE FAILED. BRUTE FORCING...");
                path.clear();
                direction = (target_position - global_transform.origin).normalized();
                direction.y = 0;
                velocity = direction * speed;
                move_and_slide();
                state = "Idle";
            else:
                velocity = direction * speed;
                move_and_slide();
            if look:
                var look_direction: Vector3 = next_point;
                look_direction.y = global_transform.origin.y;
                look_at(look_direction, Vector3.UP);
    else:
        velocity = Vector3.ZERO;
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
    
