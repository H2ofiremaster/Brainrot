class_name Memory extends ScrollContainer


@export var memory_size: int = 32;
@export var memory_cell: PackedScene;
var cells: Array[MemoryCell];
var selected_cell: int = 0:
	get:
		return selected_cell;
	set(value):
		if selected_cell < memory_size and selected_cell >= 0:
			cells[selected_cell].set_color(Color.WHITE);
		if value < memory_size and value >= 0:
			cells[value].set_color(Color.GREEN);
		selected_cell = value;

@onready var memory_container: HBoxContainer = $MemoryContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in memory_size:
		cells.append(_create_memory_cell(i));
	cells[selected_cell].set_color(Color.GREEN);

func _create_memory_cell(index: int) -> MemoryCell:
	var cell: MemoryCell = memory_cell.instantiate();
	memory_container.add_child(cell);
	cell.index = index;
	return cell;

func increment(index: int) -> void:
	cells[index].value += 1;
	if cells[index].value > 255:
		cells[index].value = 0;

func decrement(index: int) -> void:
	cells[index].value -= 1;
	if cells[index].value < 0:
		cells[index].value = 255;

func set_value(index: int, value: int) -> void:
	if value > 255: cells[index].value = 255;
	elif value < 0: cells[index].value = 0;
	else: cells[index].value = value;
	
func get_value(index: int) -> int:
	return cells[index].value;
	
func reset() -> void:
	for cell in cells:
		cell.value = 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
