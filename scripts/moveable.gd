extends RigidBody3D;

var player_near: bool = false;
var picked_up: bool = false;

func _on_body_entered(body: Node3D):
    if body.get_class() == "CharacterBody3D":
        player_near = true;
        Globals.get_player().find_child("TakeHint").visible = true;

func _on_body_exited(body: Node3D):
    if body.get_class() == "CharacterBody3D":
        player_near = false;
        Globals.get_player().find_child("TakeHint").visible = false;

func _input(event: InputEvent):
    if event.is_action_pressed("pick_up") and player_near and not picked_up:
        picked_up = true;
    elif event.is_action_pressed("place_down") and picked_up:
        picked_up = false;
        self.global_position = Globals.get_player().global_position;
