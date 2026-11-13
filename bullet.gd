extends Area2D

@export var speed: float = 400.0
var damage: int = 1
var target: Node2D = null

func _process(delta: float) -> void:
	#the bullet gets deleted if the enemy dies before it arrives
	if not is_instance_valid(target):
		queue_free()
		return
		
		#fly straight to the enemy
		global_position = global_position.move_toward(target.global_position, speed * delta)
		look_at(target.global_position)
		
		#if the bullet close enough the the enemy it will be count as an hit
		if global_position.distance_to(target.global_position) < 10.0:
			target.take_damage(damage)
			queue_free()
