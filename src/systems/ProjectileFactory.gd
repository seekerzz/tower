class_name ProjectileFactory
extends RefCounted

const PROJECTILE_SCENE = preload("res://src/objects/Projectile.tscn")

static func spawn_projectile(parent: Node, from_pos: Vector2, target: Variant, _type: String = "default"):
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.global_position = from_pos

	if target is Node2D:
		projectile.target = target
		projectile.homing = true
		# Initial aim
		projectile.velocity = (target.global_position - from_pos).normalized() * projectile.speed
		projectile.rotation = projectile.velocity.angle()
	elif target is Vector2:
		projectile.homing = false
		projectile.velocity = (target - from_pos).normalized() * projectile.speed
		projectile.rotation = projectile.velocity.angle()

	parent.add_child(projectile)
	return projectile
