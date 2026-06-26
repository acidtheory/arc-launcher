extends Control

const GAMES_LOCATION  = "user://arc-games"

var available_games : Array[ArcGame] = []
var current_game : ArcGame

func _ready():
	available_games = get_available_games()
	current_game = available_games[0]
	update_game()
	
func get_available_games() -> Array[ArcGame]:
	var array : Array[ArcGame] = []
	var dir = DirAccess.open(GAMES_LOCATION)
	var locations : PackedStringArray = DirAccess.get_directories_at(GAMES_LOCATION)
	for location in locations:
		if dir.file_exists(location + "/game.json"):
			var game_json_file = FileAccess.open(GAMES_LOCATION + "/" + location + "/game.json",FileAccess.READ)
			var game_json_text = game_json_file.get_as_text()
			var json = JSON.new()
			assert(json.parse(game_json_text) == OK,"JSON parsing failed.")
			if dir.file_exists(location + "/" + json.data.game_exec):
				var new_game : ArcGame = ArcGame.new(location,json.data.name,json.data.desc,json.data.game_exec,json.data.video)
				array.append(new_game)
	return array

@onready var volume_tween : Tween = create_tween()

func update_game():
	%VideoPlayer.stream = FFmpegVideoStream.new()
	var video_full_path = "%s/%s/%s" % [GAMES_LOCATION,current_game.location,current_game.video_path]
	%VideoPlayer.stream.file = video_full_path
	volume_tween.stop()
	%VideoPlayer.volume = 0
	volume_tween.tween_property(%VideoPlayer,"volume",1,1.5)
	volume_tween.play()
	%VideoPlayer.play()
	
	%GameTitle.text = current_game.name
	%GameDesc.text = current_game.description

func _process(_delta):
	if Input.is_action_just_pressed("ui_right"):
		var index : int = available_games.find(current_game)
		index = (index+1) % available_games.size()
		current_game = available_games[index]
		update_game()
	if Input.is_action_just_pressed("ui_left"):
		var index : int = available_games.find(current_game)
		index = (index-1) % available_games.size()
		current_game = available_games[index]
		update_game()
	if Input.is_action_just_pressed("ui_accept"):
		%VideoPlayer.paused = true
		OS.execute(ProjectSettings.globalize_path(GAMES_LOCATION + "/" + current_game.location + "/" + current_game.game_executable),[])
		%VideoPlayer.paused = false
