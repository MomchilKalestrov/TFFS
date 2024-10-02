extends RigidBody3D;

@export var shooting_range: float = 30.0;
@export var bullet_scene: PackedScene;
@export var health: float = 200.0;
@export var shooting_timeout: float = 5;

var player_near: bool = false;
var picked_up: bool = false;
var player: CharacterBody3D;
var target_enemy: CharacterBody3D;
var can_attack: bool = true;

func _ready() -> void:
    player = Globals.get_player();
    add_to_group("NPCs");
    $Timer.wait_time = shooting_timeout;
    
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    rotation.x = 0;
    rotation.z = 0;
    
func _process(delta: float) -> void:
    if not get_closest_enemy():
        return;
    
    if not is_instance_valid(target_enemy):
        return;
        
    if global_transform.origin.distance_to(target_enemy.global_transform.origin) <= shooting_range:
        var target = target_enemy.global_transform.origin;
        target.y += 1;
        look_at(target, Vector3.UP);
        shoot();

func _on_body_entered(body: Node3D) -> void:
    if body == player:
        player_near = true;
        player.find_child("TakeHint").visible = true;

func _on_body_exited(body: Node3D) -> void:
    if body == player:
        player_near = false;
        player.find_child("TakeHint").visible = false;

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pick_up") and player_near and not picked_up:
        picked_up = true;
    elif event.is_action_pressed("place_down") and picked_up:
        picked_up = false;
        global_position = player.global_position;

func _on_attack_timer_timeout():
    can_attack = true;

func shoot() -> void:
    if can_attack:
        can_attack = false;
        get_node("Timer").start();
        var bullet = bullet_scene.instantiate() as Area3D;
        bullet.global_transform = $GunEnd.global_transform;
        bullet.shooter = name;
        get_tree().root.add_child(bullet);

func get_closest_enemy() -> bool:
    var enemies = get_tree().get_nodes_in_group("Enemies");
    var closest_distance: float = shooting_range;
    target_enemy = null;

    for enemy in enemies:
        var distance = global_transform.origin.distance_to(enemy.global_transform.origin);
        if distance < closest_distance:
            closest_distance = distance;
            target_enemy = enemy;
    
    return target_enemy != null;
        
func subtract_health(ammount: float) -> void:
    health -= ammount;
    if (health <= 0):
        queue_free();
