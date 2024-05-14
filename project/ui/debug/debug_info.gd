extends Control

func _process(delta: float) -> void:
	$fps_label.set_text("FPS: " + String.num(Engine.get_frames_per_second()))
