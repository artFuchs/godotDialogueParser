extends Node

export var file_name = String();
export var output = NodePath(); # the displayer of the dialogue.
var dialogues = {};

# variables to parse an dialogue
var branch = {}; # current character / set of dialogues
var curr_dialogue = null; # current dialogue to parse
var reached_end = false;

# input information
var textInput = null;
var variableToChange = "" # next variable to change

# resources
var backgrounds = {}
var images = {}


func _ready():
	output = get_node(output); 
	var file = File.new();
	if (file.file_exists("res://dialogues/" + file_name)):
		file.open("res://dialogues/" + file_name, File.READ);
		var text = file.get_as_text();
		dialogues = parse_json(text);
		file.close();

func start_dialogue(var set):
	if (dialogues.has(set)):
		load_resources(dialogues[set])
		if (dialogues[set].has("current_branch")):
			var curr_b = dialogues[set]["current_branch"]
			branch = dialogues[set][curr_b];
		else:
			branch = dialogues[set];
		curr_dialogue = branch["current"];
		reached_end = false;
		output.open();
		parse_dialogue();

func load_resources(var b):
	backgrounds = {};
	images = {};
	if b.has("background"):
		for bck in b["background"]:
			var tex = load(b["background"][bck]);
			backgrounds[bck] = tex;
			if (bck == "default"):
				output.set_background(tex)
	if b.has("images"):
		for img in b["images"]:
			var tex = load(b["images"][img]);
			images[img] = tex;
	

func parse_dialogue():
	if (reached_end==true):
		output.close();
	elif (branch.has(curr_dialogue)):
		if (textInput!=null):
			change_variable(variableToChange, textInput.get_text());
			textInput = null;
			variableToChange = "";
			
		output.clear_inputs();
		
		var dialog = branch[curr_dialogue];
		
		if (dialog.has("event")):
			activate_event(dialog["event"]);
		
		if dialog.has("speaker"):
			output.set_name(dialog["speaker"]);
		else:
			output.set_name("");
		
		var text = parse_variables();
		
		if (dialog.has("write")):
			create_text_input();
			
		if (dialog.has("image")):
			if (images.has(dialog["image"])):
				output.set_image(images[dialog["image"]]);
			else:
				output.set_image(null);
				
		if (dialog.has("background")):
			if (backgrounds.has(dialog["background"])):
				output.set_background(backgrounds[dialog["background"]]);
			else:
				output.set_background(backgrounds["default"]);

		
		output.set_text(text);
		if (dialog.has("options")):
			create_buttons();
		elif (dialog.has("isEnd")):
			reached_end = true;
			branch["current"] = dialog["next"]
		else:
			curr_dialogue = dialog["next"];

func create_buttons():
	var options = branch[curr_dialogue]["options"];
	var i = 0;
	for opt in options:
		var b = Button.new();
		b.set_text(opt["text"]);
		b.connect("pressed", self, "select_button", [i])
		output.add_button(b);
		i+=1;

func select_button(var index):
	var option = branch[curr_dialogue]["options"][index];
	curr_dialogue = option["next"];
	parse_dialogue();
	
func create_text_input():
	variableToChange = branch[curr_dialogue]["write"];
	textInput = TextEdit.new();
	textInput.set_text(dialogues["variables"][variableToChange])
	#textInput.connect("tree_exiting", self, "change_variable", [variable, textInput]);
	textInput.size_flags_horizontal = 3;
	textInput.size_flags_horizontal = 3;
	output.add_input(textInput);

func change_variable(var variable, var value):
	if (dialogues["variables"].has(variable)):
		dialogues["variables"][variable] = value;
		
func activate_event(var event):
	if (dialogues["events"].has(event)):
		dialogues["events"][event]["value"] = true;
		for dialog in dialogues["events"][event]:
			if dialogues.has(dialog):
				for element in dialogues["events"][event][dialog]:
					dialogues[dialog][element] = dialogues["events"][event][dialog][element];

func parse_variables():
	var found = false;
	var variable = "";
	var text = branch[curr_dialogue]["text"];
	for c in branch[curr_dialogue]["text"]:
		if (found == false) and (c == "%"):
			found = true;
		elif found == true and c == "%":
			if dialogues["variables"].has(variable):
				text = text.replace("%"+variable+"%",dialogues["variables"][variable]);
			variable = "";
			found == false;
		elif found == true:
			variable+=c;
			pass;
	return text;