extends TileMapLayer

@export var bubble_asset: PackedScene

var bubble_instances = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

#func _on_child_entered_tree(node: Node) -> void:
#	if node is BubblePlaceholder:
#		bubble_instances.append(node)
#		node.reparent(get_tree().root)
