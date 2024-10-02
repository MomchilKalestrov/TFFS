extends Node;

var player_reference: CharacterBody3D = null;

func set_player(player_ref: CharacterBody3D) -> void:
    player_reference = player_ref;
    
func get_player() -> CharacterBody3D:
    return player_reference;
