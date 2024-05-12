class_name SavePrompt extends ConfirmationDialog

const DEFAULT_TEXT: String = "'{0}' has unsaved changes.\nWould you like to save?"

@onready var _discard_button: Button;

func get_discard_button() -> Button:
	return _discard_button;

func _set_expand(nodes: Array[Node]) -> void:
	for node in nodes:
		(node as Control).size_flags_horizontal |= Control.SIZE_EXPAND;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent: HBoxContainer = (get_cancel_button().get_parent() as HBoxContainer);
	var children := parent.get_children();
	(self.get_children(true)[1] as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	for c in children:
		parent.remove_child(c);
	
	var discard_button := Button.new();
	discard_button.text = "Discard";
	_discard_button = discard_button;
	discard_button.pressed.connect(_on_discard_button_pressed);
	
	_set_expand([discard_button, get_ok_button(), get_cancel_button()]);
	(children[2] as Control).size_flags_stretch_ratio = 0.1;
	(children[4] as Control).size_flags_stretch_ratio = 0.1;
	#var spacer := Control.new();
	#spacer.size_flags_horizontal |= Control.SIZE_EXPAND;
	
	children.remove_at(0);
	var cancel_button: Node = children.pop_at(2);
	var spacer: Node = children.pop_at(2);
	children.push_back(discard_button);
	children.push_back(spacer);
	children.push_back(cancel_button);
	
	for c in children:
		parent.add_child(c);

func _on_discard_button_pressed() -> void:
	self.hide();
