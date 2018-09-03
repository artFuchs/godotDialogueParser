extends Control

var background_rect = null
var character_rect = null

var textLabel = null;
var nameLabel = null
var button_next = null;
var input_container = null;

func _ready():
	background_rect = get_node("Background");
	character_rect = get_node("CharacterImage");
	textLabel = get_node("Dialogue_Panel/TextLabel");
	nameLabel = get_node("Dialogue_Panel/NameLabel");
	button_next = get_node("Dialogue_Panel/NextButton");
	input_container = get_node("Dialogue_Panel/HBoxContainer");
	close();
	
func open():
	button_next.show();
	
func set_text(var t):
	textLabel.set_text(t);
	
func set_name(var t):
	nameLabel.set_text(t);

func close():
	textLabel.set_text("");
	nameLabel.set_text("");
	button_next.hide();

func add_button(var button):
	button_next.hide();
	input_container.add_child(button);
	
func add_input(var input):
	input_container.add_child(input);
	
func clear_inputs():
	for c in input_container.get_children():
		c.queue_free();
	button_next.show();
	
func set_background(var texture):
	background_rect.set_texture(texture);
	
func set_image(var texture):
	character_rect.set_texture(texture);