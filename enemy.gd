extends PathFollow2D

@export var speed: float = 150.0
@export var health: int = 3
@export var gold_reward: int = 20

func _process(delta: float) -> void:
	progress += speed * delta
	if progress_ratio >= 1.0:
		get_tree().current_scene.take_base_damage(1)
		queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		get_tree().current_scene.add_gold(gold_reward)
		queue_free()
