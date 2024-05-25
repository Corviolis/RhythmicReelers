@tool
extends EditorPlugin

#var importer
var loader

func _enter_tree():
	#importer = preload("import.gd").new()
	loader = preload("loader.gd").new()
	#add_import_plugin(importer)
	ResourceLoader.add_resource_format_loader(loader)

func _exit_tree():
	#remove_import_plugin(importer)
	ResourceLoader.remove_resource_format_loader(loader)
	#importer = null
	loader = null
