class_name Memory extends ScrollContainer


@export var memory_size: int = 32;
@export var memory_cell: PackedScene;
var storage: PackedInt32Array;
var cells: Array[MemoryCell];
var selected_cell: int = 0;

@onready var memory_container: HBoxContainer = $MemoryContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in memory_size:
		storage.append(0);
		cells.append(_create_memory_cell(i));
	cells[0].set_color(Color.GREEN);

func _create_memory_cell(index: int) -> MemoryCell:
	var cell: MemoryCell = memory_cell.instantiate();
	memory_container.add_child(cell);
	cell.index = index;
	return cell;

func increment(index: int) -> void:
	storage[index] += 1;
	if storage[index] > 255:
		storage[index] = 0;

func decrement(index: int) -> void:
	storage[index] -= 1;
	if storage[index] < 0:
		storage[index] = 255;

func set_value(index: int, value: int) -> void:
	if value > 255: storage[index] = 255;
	elif value < 0: storage[index] = 0;
	else: storage[index] = value;
	
func get_value(index: int) -> int:
	return storage[index]
	
func reset() -> void:
	storage.fill(0);

func update_display(memory_pointer: int) -> void:
	if memory_pointer != selected_cell:
		cells[selected_cell].set_color(Color.WHITE);
		cells[memory_pointer].set_color(Color.GREEN);
		selected_cell = memory_pointer;
	for i in range(cells.size()):
		cells[i].value = storage[i];

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
