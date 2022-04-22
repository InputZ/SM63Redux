extends Sprite

const glow = preload("res://shaders/glow.tres")

onready var cam = $"/root/Main/LDCamera"
onready var main = $"/root/Main"
onready var control = $"/root/Main/UILayer/LDUI"

export(String) var item_name

var glow_factor = 1
var pulse = 0
var ghost = false


func on_selection_changed(new_selection):
	if ghost:
		modulate.a = 1
		ghost = false
	
	if new_selection.head == self:
#			if Input.is_action_pressed("LD_many"):
#				main.place_item(item_name)
		material = glow
	else:
		material = null

func _ready():
	if ghost:
		modulate.a = 0.5
		position = get_global_mouse_position()
	$ClickArea/CollisionShape2D.shape.extents = texture.get_size() / 2
	
	main.connect("selection_changed", self, "on_selection_changed")

func _process(delta):
	if ghost:
		position = get_global_mouse_position()
	
	if material:
		pulse = fmod((pulse + 0.1), 2 * PI)
		material.set_shader_param("outline_color", Color(1, 1, 1, (sin(pulse) * 0.25 + 0.5) * glow_factor))
