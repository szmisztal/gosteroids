extends Area2D

@export var bullet_scene : PackedScene
@export var speed = 150
@export var rotation_speed = 120
@export var health = 3
@export var bullet_spread = 0.2

var follow = PathFollow2D.new()
var target = null

func shoot():
	var dir = global_position.direction_to(target.global_position)
	dir = dir.rotated(randf_range(-bullet_spread, bullet_spread))
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(global_position, dir)
	$LaserSound.play()

func _ready():
	$Sprite2D.frame = randi() % 3
	var path = $EnemyPaths.get_children()[randi() % $EnemyPaths.get_child_count()]
	path.add_child(follow)
	follow.loop = false
	
func _physics_process(delta: float) -> void:
	rotation += deg_to_rad(rotation_speed) * delta
	follow.progress += speed * delta
	position = follow.global_position
	if follow.progress_ratio >= 1:
		queue_free()

func _on_gun_cooldown_timeout() -> void:
	shoot()
	
func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()
		
func explode():
	speed = 0
	$GunCooldown.stop()
	$CollisionShape2D.set_deferred("disabled", "true")
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()
	$ExplosionSound.play()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("rocks") or area.is_in_group("bullet"):
		return
	explode()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("rocks") or body.is_in_group("bullet"):
		return
	body.shield -= 50
	explode()
