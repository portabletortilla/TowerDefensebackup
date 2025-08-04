extends Node

const UDP_IP = "127.0.0.1"
const UDP_PORT = 4247

var server := UDPServer.new()
var process_pids := []
var thread: Thread
var tween
signal packet_recieved(chat_packet)

var DIR = OS.get_executable_path().get_base_dir()
var interpreter_path = DIR.path_join("PythonFiles/venv/Scripts/python")
var script_path = DIR.path_join("PythonFiles/notify.py")


func _ready():
	#print("hiya")
	set_process(false)
	if !OS.has_feature("standalone"): # if NOT exported version
		interpreter_path = ProjectSettings.globalize_path("res://PythonFiles/venv/Scripts/python")
		print(interpreter_path)
		script_path = ProjectSettings.globalize_path("res://PythonFiles/EnemyStatsIteration.py")
		print(script_path)

func notify(stats=Global.baseEnemyTemplatesStats,towerInvest=[0,0,0,0], intensity = 3, playerRanking= 3):
	get_node("GA").show()
	tween = create_tween().set_loops()
	tween.tween_property(self.get_node("GA"), "modulate:a", 0.6, 1.5)
	tween.tween_property(self.get_node("GA"), "modulate:a", 1, 1.5)
	
	start_listening()
	var s = str(stats)
	var t = str(towerInvest)
	print("checking : " + s + "  " + t)
	thread = Thread.new()
	thread.start(_execPython.bind(s,t,intensity,playerRanking))

func _execPython(stats="template", towers= "template2",intensity = "2", playerRanking= "3"):	
	var output = []
	print("stats:" + stats + "  " + towers + " " + str(intensity) + " " +  str(playerRanking))
	var PID = OS.execute(interpreter_path, [script_path, stats, towers, intensity, playerRanking] , output)
	process_pids.append(float(PID))
	
func _process(_delta):
# warning-ignore:return_value_discarded
	server.poll()
	if server.is_connection_available():
		print("Found packet")
		var peer : PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet().get_string_from_utf8()
		#packet = JSON.parse(packet).result
		#print(packet)
		emit_signal("packet_recieved", packet)
		stop_listening()

func start_listening():
# warning-ignore:return_value_discarded
	server.listen(UDP_PORT)
	set_process(true)
	print("Im listening")

func stop_listening():
	server.stop()
	set_process(false)
	if tween:
		tween.kill() # Abort the previous animation.
	get_node("GA").hide()
	kill_processes()

func kill_processes():
	for pid in process_pids:
# warning-ignore:return_value_discarded
		OS.kill(pid)	
