extends Node

var bpm: float = 60
var beat_duration: float = 60 / bpm
var beats_per_measure: int = 4
var measure_duration: float = beats_per_measure * beat_duration
# var offset: float = 0.2

var nextbeat: float = 0
var beatcount: int = 0  # NOTE: BEATS START AT 0, NOT 1
signal beat(count: int)
signal measure

# components of a rhythm game
# player's input
# - emits on button pressed
# music player -> music_player singleton
# - plays music
# - plays dynamic music, cues, switches tracks, and handles players
# - indicates time position in the song
# metronome -> here
# - counts the beats (1, 2, 3, 4) ; needs bpm
# - counts the bars ; needs time signature
# - possibly track parts (solo approaching I guess?)
# - might be hooked up to an external file
# *- emits signal on active beat window open and close
# *composer -> https://editor.rhythmnator.com
# - writes a document that tells which buttons must be pressed on which beat
# - can answer what is the next required input
# judge -> minigame
# - validates player input
# - gets correct input from composer and compares that to player input
# pitcher -> minigame
# - creates the visual notes
# referee -> game script
# - applies game rules
# - gives the track to the music player, bpm to metronome, tracks score,
#		listens to judge, stops level, etc.

# TODO: finish the core 4 minigames
# TODO: add song timer to map
# TODO: add solo section
# - song timer
# - minigame flashing and lockout

# bullet types: air, water, extra damage


func _ready():
	MusicPlayer.update_song_position.connect(_on_song_position)


func get_time_of_next_measure() -> float:
	var beats_left_in_measure = beats_per_measure - beatcount
	return nextbeat + beat_duration * beats_left_in_measure


func _on_song_position(song_position: float):
	if song_position > nextbeat:
		if beatcount == 0:
			measure.emit()
		beat.emit(beatcount)
		beatcount += 1
		beatcount %= beats_per_measure
		nextbeat += beat_duration
