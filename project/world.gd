extends Node3D

@onready var player = $Player

const ENEMY_SCENE = preload("res://bigfoot/bigfoot.tscn")

func _physics_process(delta):
	get_tree().call_group("enemies", "update_target_location", player.get_node("Marker3D").global_transform.origin)

func _on_timer_timeout():
	#spawn enemy
	var init_enemy_position = $EnemySpawnMarker.position
	
	var enemy_instance = ENEMY_SCENE.instantiate()
	enemy_instance.position = init_enemy_position
	add_child(enemy_instance)
