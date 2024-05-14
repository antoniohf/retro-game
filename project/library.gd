@tool
extends EditorScript

func _run():
	print("starting...")
	for meshInstance3dNode in get_all_meshinstance3d_children(get_scene()):
		print(meshInstance3dNode)
		meshInstance3dNode.owner = get_scene()
		
func get_all_meshinstance3d_children(in_node, children_acc = []):
	for child in in_node.get_children():
		if child.is_instance_of(MeshInstance3D):
			children_acc.push_back(child)
		children_acc = get_all_meshinstance3d_children(child, children_acc)

	return children_acc
