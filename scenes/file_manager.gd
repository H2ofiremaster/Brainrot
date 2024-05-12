class_name FileManager extends Button

enum Action {
	NEW,
	LOAD,
	EXIT,
	NONE,
}

var current_file: String = "";
var to_load: String = "";
var modified: bool = false;
var queued_action: Action = Action.NONE;

@onready var file_menu: PopupMenu = $FileMenu;
@onready var save_prompt: SavePrompt = $SavePrompt;
@onready var save_dialog: FileDialog = $SaveDialog;
@onready var load_dialog: FileDialog = $LoadDialog;
@onready var code: Code = $"../../../VSplitContainer/Code";

func prompt_save(action: Action) -> void:
	queued_action = action;
	var segments := current_file.split("\\")
	var file_name := segments[segments.size() - 1];
	if current_file.is_empty(): file_name = "Untitled"
	save_prompt.dialog_text = save_prompt.DEFAULT_TEXT.format([file_name])
	save_prompt.show();
	pass

func perform_queued_action() -> void:
	match queued_action:
		Action.NEW: new_file(false);
		Action.LOAD: load_file(false);
		Action.EXIT: exit(false);

func save(is_new_file: bool = false) -> void:
	if current_file.is_empty() || is_new_file:
		save_dialog.show();
		return;
	var file := FileAccess.open(current_file, FileAccess.WRITE);
	file.store_string(code.text);
	modified = false;

func new_file(should_prompt: bool = true) -> void:
	if modified and should_prompt:
		prompt_save(Action.NEW);
	else:
		current_file = "";
		code.reset();
		code.input.text = "";
		code.input.text_changed.emit("");
		code.text = "";

func load_file(should_prompt: bool = true) -> void:
	if modified and should_prompt:
		prompt_save(Action.LOAD);
		return;
	
	if to_load.is_empty():
		load_dialog.show();
		return;
	print(to_load)
	var file := FileAccess.open(to_load, FileAccess.READ);
	var content := file.get_as_text();
	print("'" + content + "'")
	code.text = content;
	code._on_text_changed();
	current_file = to_load;
	to_load = "";
	
func exit(should_prompt: bool = true) -> void:
	if modified and should_prompt:
		prompt_save(Action.EXIT)
	else:
		get_tree().quit();
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().auto_accept_quit = false;
	save_prompt.get_ok_button().pressed.connect(_on_save_prompt_ok_pressed);
	save_prompt.get_discard_button().pressed.connect(_on_save_prompt_discard_pressed);
	save_prompt.get_cancel_button().pressed.connect(_on_save_prompt_cancel_pressed);

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		exit();


func _on_save_dialog_file_selected(path: String) -> void:
	current_file = path;
	save();


func _on_pressed() -> void:
	file_menu.size = self.get_rect().size;
	file_menu.position = self.get_global_rect().position;
	@warning_ignore("narrowing_conversion")
	file_menu.position.y += self.get_rect().size.y;
	file_menu.show();

func _on_file_menu_id_pressed(id: int) -> void:
	match id:
		0: new_file();
		1: save(false);
		2: save(true);
		3: load_file();
		_: return;

func _on_save_prompt_ok_pressed() -> void:
	save(false);
	perform_queued_action();
	

func _on_save_prompt_discard_pressed() -> void:
	perform_queued_action()

func _on_save_prompt_cancel_pressed() -> void:
	queued_action = Action.NONE;

func _on_code_text_changed() -> void:
	modified = true;

func _on_load_dialog_file_selected(path: String) -> void:
	to_load = path;
	load_file(false);


