extends Node

const DEFAULT_PORT: int = 38426
var upnp: UPNP
var upnp_open: bool = false
var peer: MultiplayerPeer
var port: int
var thread := Thread.new()
var is_multiplayer: bool = false

# TODO: add support to transition from multiplayer back to singleplayer
#		don't forget to clear the players again
# TODO: disable port remapping when server is open so it closes the correct port

#=== UTILITY ===

func get_port() -> int:
	return port or DEFAULT_PORT

func setup_upnp():
	upnp = UPNP.new()
	var upnp_discover_result = upnp.discover() as UPNP.UPNPResult
	if upnp_discover_result == UPNP.UPNP_RESULT_SUCCESS and upnp.get_gateway().is_valid_gateway():
		var udp_mapping_result = upnp.add_port_mapping(get_port(), 0,
			ProjectSettings.get_setting("application/config/name") as String)
		if udp_mapping_result == UPNP.UPNP_RESULT_SUCCESS:
			print("UPNP Port Forward Succeeded")
		else:
			printerr("UPNP Port Forward Failed: %s" % UPNP.UPNPResult[str(udp_mapping_result)])
		print(upnp.query_external_address())
	else:
		printerr("Gateway not discovered: %s" % upnp_discover_result)

func host_game():
	thread.start(setup_upnp)
	peer = ENetMultiplayerPeer.new()
	peer.create_server(get_port(), 4)
	multiplayer.multiplayer_peer = peer
	is_multiplayer = true

func join_game(server_ip: String):
	PlayerManager.drop_all_players()
	peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip, get_port())
	multiplayer.multiplayer_peer = peer
	is_multiplayer = true

func leave_server():
	if thread.is_alive():
		thread.wait_to_finish()
	if upnp_open:
		upnp.delete_port_mapping(port)
	peer = OfflineMultiplayerPeer.new()
	multiplayer.multiplayer_peer = peer
	is_multiplayer = false

#=== SIGNAL CALLBACKS ===

func _exit_tree():
	if thread.is_alive():
		thread.wait_to_finish()
	if upnp_open:
		upnp.delete_port_mapping(port)
