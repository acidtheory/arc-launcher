extends Resource
class_name ArcGame

@export var name : StringName
@export var location : StringName
@export var description : String
@export var game_executable : String
@export var video_path : String

func _init(_location, _name, _description, _game_executable, _video_path):
	location = _location
	name = _name
	description = _description
	game_executable = _game_executable
	video_path = _video_path
