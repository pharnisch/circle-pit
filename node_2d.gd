extends Node2D

const IP_ADDRESS = "ec2-13-51-107-226.eu-north-1.compute.amazonaws.com"


var heart_beats = 0
var timer = 0
var peer_ids = []

var player_scene = preload("res://character_body_2d.tscn")

var with_websockets = true
var peer_reference = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("dedicated_server")
		start_host()
	else:
		print("client!")
		connect_to_host()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if peer_reference:
		peer_reference.poll()
		
	
	
	if OS.has_feature("dedicated_server"):
		timer += delta
		var cnt = int(timer)
		if cnt >= heart_beats:
			heart_beats += 1
			#print("HEARTBEAT")
			for peer_id in peer_ids:
				print(" -> send it to ", str(peer_id))
				send_data_to_client(peer_id, "Heartbeat " + str(heart_beats) + "")
	else:
		pass



func start_host():
	if with_websockets:
		var peer = WebSocketMultiplayerPeer.new()
		peer_reference = peer

		# Start the server on port 7777
		var result = peer.create_server(7777)
		if result != OK:
			print("Failed to start host: ", result)
			return
		
		# Assign the peer to SceneMultiplayer
		get_tree().get_multiplayer().multiplayer_peer = peer
		print("Host started on port 7777")

		# Connect signals
		get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)
		get_tree().get_multiplayer().peer_disconnected.connect(_on_peer_disconnected)
	else:
		var peer = ENetMultiplayerPeer.new()

		# Start the server on port 7777
		var result = peer.create_server(7777)
		if result != OK:
			print("Failed to start host: ", result)
			return
		
		# Assign the peer to SceneMultiplayer
		get_tree().get_multiplayer().multiplayer_peer = peer
		print("Host started on port 7777")

		# Connect signals
		get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)
		get_tree().get_multiplayer().peer_disconnected.connect(_on_peer_disconnected)


# Server-side function to receive data from the client
@rpc("any_peer")
func receive_data_from_client(data: String) -> void:
	print("Server received data: ", data)

# Function to send data to a specific client
func send_data_to_client(peer_id: int, data: String) -> void:
	rpc_id(peer_id, "receive_data_from_server", data)

# Called when a peer connects
func _on_peer_connected(peer_id: int):
	print("Peer connected: ", peer_id)
	peer_ids.append(peer_id)
	
	var new_player = player_scene.instantiate()
	new_player.name = str(peer_id)
	call_deferred("add_child", new_player)

func _on_peer_disconnected(peer_id):
	print("Peer disconnected: ", peer_id)
	var new_peer_ids = []
	for peer_id_i in peer_ids:
		if peer_id_i != peer_id:
			new_peer_ids.append(peer_id_i)
	peer_ids = new_peer_ids
	
	# Delete Player Node of disconnected player
	for c in get_children():
		if c.name.to_int() == peer_id:
			c.queue_free()
	
func connect_to_host(ip: String = IP_ADDRESS, port: int = 7777):
	if with_websockets:
		var peer = WebSocketMultiplayerPeer.new()
		peer_reference = peer

		# Connect to the server
		var result = peer.create_client("ws://" + ip + ":7777")
		if result != OK:
			print("Failed to connect to host: ", result)
			return

		# Assign the peer to SceneMultiplayer
		get_tree().get_multiplayer().multiplayer_peer = peer
		print("Connected (websocket) to host at ", ip, ":", port)

		# Connect signals
		get_tree().get_multiplayer().connected_to_server.connect(_on_connected_to_server)
		get_tree().get_multiplayer().server_disconnected.connect(_on_server_disconnected)
	else:
		var peer = ENetMultiplayerPeer.new()

		# Connect to the server
		var result = peer.create_client(ip, port)
		if result != OK:
			print("Failed to connect to host: ", result)
			return

		# Assign the peer to SceneMultiplayer
		get_tree().get_multiplayer().multiplayer_peer = peer
		print("Connected to host at ", ip, ":", port)

		# Connect signals
		get_tree().get_multiplayer().connected_to_server.connect(_on_connected_to_server)
		get_tree().get_multiplayer().server_disconnected.connect(_on_server_disconnected)


# Client-side function to send data to the server
func send_data_from_client():
	rpc("receive_data_from_client", "Hello from the client!")

# Function to receive data from the server
@rpc
func receive_data_from_server(data: String) -> void:
	print("Data received from server: ", data)

# Called when connected to the server
func _on_connected_to_server():
	print("Successfully connected to the server!")
	send_data_from_client()  # Example: Send data to the server when connected

func _on_server_disconnected():
	print("Disconnected from server.")


	
