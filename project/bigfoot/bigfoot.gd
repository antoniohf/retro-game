extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

var dead = false

func _ready():
	$"bigfoot-fixed/AnimationPlayer".play("bigfoot-walking")

func _physics_process(delta):
	if dead:
		return
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location)
	
	velocity = new_velocity
	move_and_slide()
	
func update_target_location(target_location):
	if dead:
		return
	look_at(target_location, Vector3.UP, true)
	nav_agent.target_location = target_location

func _on_navigation_agent_3d_target_reached():
	$"bigfoot-fixed/AnimationPlayer".play("bigfoot-attack")
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "bigfoot-attack":
		$"bigfoot-fixed/AnimationPlayer".play("bigfoot-walking")
	elif anim_name == "bigfoot-dying":
		queue_free()

func _on_hit():
	dead = true
	$"bigfoot-fixed/AnimationPlayer".stop()
	$"bigfoot-fixed/AnimationPlayer".play("bigfoot-dying")
