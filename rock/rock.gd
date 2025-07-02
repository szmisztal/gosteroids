extends RigidBody2D

signal exploded
var screensize = Vector2.ZERO
var size
var radius
var scale_factor = 0.4

func start(_position, _velocity, _size):
	position = _position
	size = _size
	mass = 1.5 * size
	$Sprite2D.scale = Vector2.ONE * scale_factor * size
	radius = int($Sprite2D.texture.get_size().x/2 * $Sprite2D.scale.x)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)
	$Explosion.scale = Vector2.ONE * 0.3 * size
	
func _integrate_forces(physics_state):
	var new_transform = physics_state.transform
	new_transform.origin.x = wrapf(new_transform.origin.x, 0 - radius, screensize.x + radius)
	new_transform.origin.y = wrapf(new_transform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = new_transform

func explode():
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Explosion/AnimationPlayer.play("explosion")
	$Explosion.show()
	exploded.emit(size, radius, position, linear_velocity)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()
