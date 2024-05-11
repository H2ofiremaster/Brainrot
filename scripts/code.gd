class_name Code extends CodeEdit

# Exports
@export var steps_per_frame: float;

# Nodes
@onready var memory: Memory = $"../../Memory"
@onready var timer: Timer = $Timer
@onready var output: TextEdit = $"../IO/Output"
@onready var input: LineEdit = $"../IO/Input"

# Variables
var highlighter: BFHighlighter = BFHighlighter.new();

var frame_time: float = 0;

var is_running: bool = false;

var memory_pointer: int = 0:
	get:
		return memory_pointer;
	set(value):
		memory_pointer = value;
		memory.selected_cell = value;
var instruction_pointer: int = 0;
var instruction_pointer_coords: Vector2i = Vector2i.ZERO;
var last_instruction_pointer_coords: Vector2i = Vector2i.ZERO;

var brackets: Dictionary = {};

var input_buffer: Array[int] = [];

var breakpoints: Array[int] = [];

# Functions
func run() -> void:
	is_running = true;

func step() -> void:
	if instruction_pointer >= text.length():
		if is_running:
			is_running = false;
		else:
			reset();
		return;
	var character = text[instruction_pointer];
	match character:
		"+": 
			memory.increment(memory_pointer);
			increment_instruction_pointer()
		"-": 
			memory.decrement(memory_pointer);
			increment_instruction_pointer()
		"<": 
			memory_pointer -= 1;
			if memory_pointer < 0:
				memory_pointer = memory.memory_size - 1;
			increment_instruction_pointer()
		">": 
			memory_pointer += 1;
			if memory_pointer >= memory.memory_size:
				memory_pointer = 0;
			increment_instruction_pointer()
			
		"[":
			if memory.get_value(memory_pointer) == 0:
				instruction_pointer = brackets.get(instruction_pointer);
				update_instruction_pointer_coords();
			else:
				increment_instruction_pointer()
		"]":
			if memory.get_value(memory_pointer) != 0:
				instruction_pointer = brackets.find_key(instruction_pointer);
				update_instruction_pointer_coords();
			else:
				increment_instruction_pointer()
		",": 
			var input_char: int = 0;
			if not input_buffer.is_empty():
				input_char = input_buffer.pop_front();
			memory.set_value(memory_pointer, input_char);
			increment_instruction_pointer()
		".": 
			output.text += char(memory.get_value(memory_pointer))
			#print("Printing: '" + char(memory.get_value(memory_pointer)) + "', (" + str(memory.get_value(memory_pointer)) + ")")
			increment_instruction_pointer()
			
		_: 
			increment_instruction_pointer()
	
	if instruction_pointer < text.length() and not "+-<>[],.".contains(text[instruction_pointer]):
		#print(text[instruction_pointer])
		step()
	if breakpoints.has(instruction_pointer_coords.y):
		is_running = false;

func reset() -> void:
	memory.reset();
	is_running = false;
	memory_pointer = 0;
	instruction_pointer = 0;
	instruction_pointer_coords = Vector2i.ZERO;
	input_buffer.assign(input.text.to_ascii_buffer())
	output.text = "";

func update_brackets() -> void:
	output.text = ""; 
	brackets = {};
	var opening: Array[int] = [];
	for i in range(text.length()):
		if text[i] == "[":
			opening.push_back(i);
		elif text[i] == "]":
			if opening.is_empty(): output.text = "Unbalanced brackets: " + str(i); 
			brackets[opening.pop_back()] = i;
	if not opening.is_empty(): 
		output.text = "Unbalanced brackets: " + str(opening[0]);
	pass

func increment_instruction_pointer():
	if text[instruction_pointer] == "\n":
		instruction_pointer_coords.y += 1;
		instruction_pointer_coords.x = 0;
	else:
		instruction_pointer_coords.x += 1;
	instruction_pointer += 1

func update_instruction_pointer_coords():
	instruction_pointer_coords = Vector2i.ZERO;
	var index = 0;
	var text_until_pointer := text.substr(0, instruction_pointer);
	var lines := text_until_pointer.count("\n");
	instruction_pointer_coords.y = lines;
	var split := text_until_pointer.rsplit("\n", true, 1);
	if split.size() < 2:
		split[0] = "";
	var column = instruction_pointer - split[0].length();
	instruction_pointer_coords.x = column - 1
	# #print("IP: " + str(instruction_pointer) + ", New: " + str(instruction_pointer_coords), ", split: " + str(split));
	#instruction_pointer_coords = Vector2i.ZERO;
	#for i in range(instruction_pointer):
		# #print("i: " + str(i) + ", coords: " + str(instruction_pointer_coords))
		#if text[i] == "\n":
			#instruction_pointer_coords.y += 1;
			#instruction_pointer_coords.x = 0;
		#else:
			#instruction_pointer_coords.x += 1;
	#print("IP: " + str(instruction_pointer) + ", Old: " + str(instruction_pointer_coords));

# Overrides
func _ready() -> void:
	syntax_highlighter = highlighter;

func _process(_delta: float) -> void:
	#print(Engine.get_frames_per_second());
	if(last_instruction_pointer_coords != instruction_pointer_coords):
		highlighter.update_pointer_pos(instruction_pointer_coords);
	if not is_running: return
	for _i in range(steps_per_frame):
		if is_running: step()

# Signals
func _on_text_changed() -> void:
	update_brackets()
	is_running = false;

func _on_input_text_changed(new_text: String) -> void:
	input_buffer.assign(new_text.to_ascii_buffer());

func _on_step_button_pressed() -> void:
	step()


func _on_run_button_pressed() -> void:
	reset()
	run()


func _on_reset_button_pressed() -> void:
	reset()


func _on_breakpoint_toggled(line: int) -> void:
	if breakpoints.has(line):
		breakpoints.erase(line);
	else:
		breakpoints.append(line);


func _on_output_text_set() -> void:
	output.scroll_vertical = output.get_line_count() - 1;
