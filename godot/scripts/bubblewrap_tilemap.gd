extends TileMapLayer

@export var bubble_asset: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_child_entered_tree(_node: Node) -> void:
	pass
#	if node is BubblePlaceholder:
#		bubble_instances.append(node)
#		node.reparent(get_tree().root)
