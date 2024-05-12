class_name SpeedEditor extends LineEdit

@onready var code: Code = $"../../../VSplitContainer/Code"


func _ready() -> void:
	text = str(code.steps_per_frame);

func _on_run_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := (event as InputEventMouseButton);
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
			self.visible = !self.visible;


func _on_text_submitted(new_text: String) -> void:
	print(new_text)
	var new_value := new_text as float;
	print(new_value)
	if new_value:
		code.steps_per_frame = new_value;
	text = str(code.steps_per_frame);
