extends ResourceFormatLoader
class_name BeatMapLoader

func _get_recognized_extensions():
	return ["beat"]
	
func _get_resource_script_class(path):
	return "beat_map.gd"
	
func _get_resource_type(path):
	return "BeatMap"
	
func _load(path, original_path, use_sub_threads, cache_mode):
	var all_bytes: PackedByteArray = FileAccess.get_file_as_bytes(original_path)
	var tracks = {}
	var track_offset = 1
	# Loop through all the tracks
	for i in range(all_bytes.decode_u8(0)):
		var end = all_bytes.find(0x0b)
		var bytes = all_bytes.slice(track_offset, end)
		track_offset += end
		# Track name
		var offset = bytes.find(0x0a)
		var track_name = bytes.slice(0, offset).get_string_from_utf8()
		offset += 1
		# Track data
		var beat_map = []
		while end - 1 > offset:
			beat_map.append(bytes.decode_float(offset))
			offset += 4
		tracks[track_name] = beat_map
	return BeatMap.new(tracks)
