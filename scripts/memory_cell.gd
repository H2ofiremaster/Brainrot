class_name MemoryCell extends PanelContainer

@export var index: int = 0:
	get: 
		return index;
	set(value):
		index = value;
		index_label.text = " " + str(value) + " ";
@export var value: int = 0:
	get:
		return value;
	set(new_value):
		value = new_value;
		label.text = " " + str(value) + " ";

@onready var label: Label = $Margins/Container/Label
@onready var index_label: Label = $Margins/Container/IndexLabel

func set_color(color: Color) -> void:
	label.modulate = color;
	index_label.modulate = color;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = 0;
	index_label.text = " " + str(index) + " ";
	pass # Replace with function body.
