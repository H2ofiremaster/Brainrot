class_name Code extends CodeEdit

# Exports
@export var steps_per_frame: float;

# Nodes
@onready var memory: Memory = $"../../Memory"
@onready var output: TextEdit = $"../IO/Output"
@onready var input: LineEdit = $"../IO/Input"
@onready var pause_button: Button = $"../../StatusBar/PauseButton"
@onready var speed_editor: LineEdit = $"../../StatusBar/RunButtonContainer/SpeedEditor"

# Variables
var highlighter: BFHighlighter = BFHighlighter.new();

var frame_counter: float = 0;

var is_running: bool = false;

var memory_pointer: int = 0;
var instruction_pointer: int = 0;
var last_instruction_pointer: int = 0;
var instruction_pointer_coords: Vector2i = Vector2i.ZERO;

var brackets: Dictionary = {};

var input_buffer: PackedByteArray = [];
var output_buffer: PackedByteArray = [];

var breakpoints: Array[int] = [];

# Functions
func run() -> void:
	is_running = true;

func step() -> void:
	
	if instruction_pointer >= text.length():
		if is_running: is_running = false;
		else: reset();
		return;
	
	var character := text[instruction_pointer];
	match character:
		"+": increment();
		"-": decrement();
		"<": shift_left();
		">": shift_right();
		"[": start_loop();
		"]": end_loop();
		",": get_input();
		".": output_char();
		
	filter_pointless_chars();

func increment() -> void:
	memory.increment(memory_pointer);
	instruction_pointer += 1;
	
func decrement() -> void:
	memory.decrement(memory_pointer);
	instruction_pointer += 1;

func shift_left() -> void:
	memory_pointer -= 1;
	if memory_pointer < 0:
		memory_pointer = memory.memory_size - 1;
	instruction_pointer += 1;

func shift_right() -> void:
	memory_pointer += 1;
	if memory_pointer >= memory.memory_size:
		memory_pointer = 0;
	instruction_pointer += 1;

func start_loop() -> void:
	if memory.get_value(memory_pointer) == 0:
		instruction_pointer = brackets.get(instruction_pointer);
	else:
		instruction_pointer += 1;

func end_loop() -> void:
	if memory.get_value(memory_pointer) != 0:
		instruction_pointer = brackets.find_key(instruction_pointer);
	else:
		instruction_pointer += 1;

func reset() -> void:
	memory.reset();
	is_running = false;
	memory_pointer = 0;
	instruction_pointer = 0;
	instruction_pointer_coords = Vector2i.ZERO;
	input_buffer = input.text.to_ascii_buffer();
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

func get_input() -> void:
	var input_char: int = 0;
	if not input_buffer.is_empty():
		input_char = input_buffer[0];
		input_buffer.remove_at(0);
	memory.set_value(memory_pointer, input_char);
	instruction_pointer += 1;

func output_char() -> void:
	output_buffer.append(memory.get_value(memory_pointer));
	instruction_pointer += 1;

func filter_pointless_chars() -> void:
	while (instruction_pointer < text.length() and 
		is_pointless(text[instruction_pointer])):
		var character := text[instruction_pointer];
		if character == "\n":
			var lines := text.substr(0, instruction_pointer).count("\n");
			if breakpoints.has(lines + 1): is_running = false
			
		instruction_pointer += 1;

func is_pointless(character: String) -> bool:
	return character not in "+-<>[],.";

func update_instruction_pointer_coords() -> void:
	instruction_pointer_coords = Vector2i.ZERO;
	var text_until_pointer := text.substr(0, instruction_pointer);
	var lines := text_until_pointer.count("\n");
	instruction_pointer_coords.y = lines;
	var split := text_until_pointer.rsplit("\n", true, 1);
	if split.size() < 2:
		split[0] = "";
	var column := instruction_pointer - (split[0].length() + 1);
	instruction_pointer_coords.x = column
	print("IPC: " + str(instruction_pointer_coords) + ", IP: " + str(instruction_pointer))

# Overrides
func _ready() -> void:
	syntax_highlighter = highlighter;
	

func _process(_delta: float) -> void:
	#print(Engine.get_frames_per_second());
	pause_button.text = "Pause" if is_running else "Unpause"
	
	if (instruction_pointer == 0 and
			not text.is_empty() and 
			is_pointless(text[0])):
		filter_pointless_chars();
	
	if last_instruction_pointer != instruction_pointer:
		update_instruction_pointer_coords();
		highlighter.update_pointer_pos(instruction_pointer_coords);
		last_instruction_pointer = instruction_pointer;
	
	memory.update_display(memory_pointer);
	if steps_per_frame < 1:
		frame_counter += steps_per_frame;
		if frame_counter >= 1:
			if is_running: step()
			frame_counter = 0;
	else:
		for _i in range(steps_per_frame):
			if is_running: step()
	output.text += output_buffer.get_string_from_ascii();
	output_buffer.clear();

# Signals
func _on_text_changed() -> void:
	update_brackets();
	is_running = false;

func _on_input_text_changed(new_text: String) -> void:
	input_buffer = new_text.to_ascii_buffer();

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


func _on_pause_button_pressed() -> void:
	is_running = !is_running;
