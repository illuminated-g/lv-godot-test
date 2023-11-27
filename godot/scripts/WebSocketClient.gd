extends Node
class_name WebSocketClient

@export var url = "ws://localhost/vis"
@export var connected = false

@export var control : Rocket

var ws = WebSocketPeer.new()
var wsUrl = ""

func getWsUrl():
	var urlParam = JavaScriptBridge.eval("""
			var wsUrl = new URL(\"""" + url + """\");
			var url = new URL(window.location.href);
			wsUrl.port = url.port;
			window.wsUrl = wsUrl;
			wsUrl.toString();
		""")
	
	if urlParam == null:
		return url
	else:
		return urlParam

# Called when the node enters the scene tree for the first time.
func _ready():
	wsUrl = getWsUrl()

func publishState():
	var payload = PackedByteArray()
	payload.resize(48)
	var velocity = control.linear_velocity
	payload.encode_double(0, velocity.x)
	payload.encode_double(8, velocity.y)
	payload.encode_double(16, control.actThrust.x)
	payload.encode_double(24, control.actThrust.y)
	payload.encode_double(32, control.posThrust.x)
	payload.encode_double(40, control.posThrust.y)
	ws.send(payload)

func dispatchPacket(msg: PackedByteArray):
	#print(msg)
	var type = msg.decode_u8(0)
	match (type):
		1:
			if !control:
				return
				
			#thrust / thrustAngle values
			var thrust = msg.decode_double(1)
			var thrustAngle = msg.decode_double(9)
			control.setControl(thrust, thrustAngle)
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ws.poll()
	var state = ws.get_ready_state()
	#print(state)
	if state == WebSocketPeer.STATE_OPEN:
		publishState()
		#print("O")
		#var pkts = ws.get_available_packet_count()
		#print(pkts)
		while ws.get_available_packet_count():
			dispatchPacket(ws.get_packet())
			
	if state == WebSocketPeer.STATE_CLOSING:
		#print("closing")
		pass
		
	if state == WebSocketPeer.STATE_CLOSED:
		#print("closed")
		var code = ws.get_close_code()
		var reason = ws.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		
		var err = ws.connect_to_url(wsUrl)
		if err:
			printerr(err)
