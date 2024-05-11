class_name BFHighlighter extends SyntaxHighlighter

const CHAR_COLORS = {
	"-": { "color": Color.RED },
	"+": { "color": Color.GREEN },
	"<": { "color": Color.AQUA },
	">": { "color": Color.AQUA },
	"[": { "color": Color.DARK_CYAN },
	"]": { "color": Color.DARK_CYAN },
	",": { "color": Color.MAGENTA },
	".": { "color": Color.PURPLE },
}

var selected_coords: Vector2i = Vector2i.ZERO;

func update_pointer_pos(pointer_coords: Vector2i) -> void:
	selected_coords = pointer_coords;
	get_text_edit().queue_redraw();
	update_cache();

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var colors := {};
	var editor := get_text_edit();
	var line_text: String = editor.get_line(line);
	
	colors[0] = _default();
	for i in line_text.length():
		if CHAR_COLORS.has(line_text[i]):
			colors[i] = CHAR_COLORS[line_text[i]];
			colors[i + 1] = _default();
		if selected_coords.y == line and selected_coords.x == i :
			colors[i] = { "color": Color.YELLOW }
			colors[i + 1] = _default();
	return colors;

func _default() -> Dictionary:
	return { "color": Color.GRAY };

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
