extends Node

var upnp: UPNP
var peer: ENetMultiplayerPeer
var port: int
var thread := Thread.new()

const DEFAULT_PORT: int = 38426

# TODO: add support to transition from multiplayer back to singleplayer
#		don't forget to clear the players again

func get_port() -> int:
	return port or DEFAULT_PORT

func setup_upnp():
	upnp = UPNP.new()
	var upnp_discover_result = upnp.discover() as int
	if upnp_discover_result == UPNP.UPNP_RESULT_SUCCESS and upnp.get_gateway().is_valid_gateway():
		var udp_mapping_result = upnp.add_port_mapping(get_port(), 0,
			ProjectSettings.get_setting("application/config/name") as String)
		if udp_mapping_result == UPNP.UPNP_RESULT_SUCCESS:
			print("UPNP Port Forward Succeeded")
		else:
			printerr("UPNP Port Forward Failed: %s" % udp_mapping_result)
		print(upnp.query_external_address())
	else:
		printerr("Gateway not discovered: %s" % upnp_discover_result)

func host_game():
	thread.start(setup_upnp)
	peer = ENetMultiplayerPeer.new()
	peer.create_server(get_port(), 4)
	multiplayer.multiplayer_peer = peer
	PlayerManager.is_multiplayer = true

func join_game(server_ip: String):
	PlayerManager.drop_all_players()
	peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip, get_port())
	multiplayer.multiplayer_peer = peer
	PlayerManager.is_multiplayer = true

func _exit_tree():
	thread.wait_to_finish()