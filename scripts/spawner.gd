extends Node

@export var defense_scene: PackedScene
var player_in_area: bool = false;

func _on_body_entered(body: Node3D):
    if body.get_class() == "CharacterBody3D":
        var hint = Globals.get_player().find_child("InteractHint")
        hint.visible = true
        player_in_area = true


func _on_body_exited(body: Node3D):
    if body.get_class() == "CharacterBody3D":
        var hint = Globals.get_player().find_child("InteractHint")
        hint.visible = false
        player_in_area = false
func _input(event: InputEvent):
    if event.is_action_pressed("interact") and player_in_area:
        var defense = defense_scene.instantiate()
        add_child(defense)
