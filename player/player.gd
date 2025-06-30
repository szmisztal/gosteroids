extends RigidBody2D

enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = INIT

@export var engine_power = 500
@export var spin_power = 8000

var thrust = Vector2.ZERO
var rotation_dir = 0
var screensize = Vector2.ZERO

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
	state = new_state

func _ready():
	screensize = get_viewport_rect().size
	change_state(ALIVE)
	
func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate left", "rotate right")

func _physics_process(delta):
	get_input()
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state):
	var new_transform = physics_state.transform
	new_transform.origin.x = wrapf(new_transform.origin.x, 0, screensize.x)
	new_transform.origin.y = wrapf(new_transform.origin.y, 0, screensize.y)
	physics_state.transform = new_transform
	
