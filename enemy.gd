extends PathFollow2D

@export var speed: float = 150.0
@export var health: int = 3
@export var gold_reward: int = 20

var max_health: int = 3
var health_bar: ProgressBar = null

#health bar
func _ready() -> void:
	rotates = false
	max_health = health
	
	health_bar = ProgressBar.new()
	health_bar.show_percentage = false
	health_bar.size = Vector2(60, 10)
	health_bar.position = Vector2(-30, -55)
	health_bar.value = health
	health_bar.modulate = Color(0.2, 1.0, 0.2)
	add_child(health_bar)
	
	#new stats for every enemy type
func setup_enemy(type: String, wave:int) -> void:
	if type == "runner":
		health = 1 + int(wave * 0.8)
		speed = 240.0 + (wave * 20.0)
		gold_reward = 15
		scale = Vector2(0.75, 0.75)
		if has_node("Sprite2D"):
			$Sprite2D.self_modulate = Color(1.0, 0.9, 0.2)
	elif type == "tank":
		health = (2 + wave) * 3
		speed = 85.0 + (wave * 8.0)
		gold_reward = 50
		scale = Vector2(1.35, 1.35)
		if has_node("Sprite2D"):
				$Sprite2D.self_modulate = Color(0.6, 0.2, 1.0)
	else:
		health = 2 + wave
		speed = 130.0 + (wave * 15.0)
		gold_reward = 20
				
	max_health = health
	if health_bar != null:
		health_bar.max_value = max_health
		health_bar.value = health

func _process(delta: float) -> void:
	progress += speed * delta
	if progress_ratio >= 1.0:
		get_tree().current_scene.take_base_damage(1)
		queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	
	if health_bar != null:
		health_bar.value = health
		var ratio = float(health) / float(max_health)
		if ratio <= 0.35:
			health_bar.modulate = Color(1.0, 0.2, 0.2)
		elif ratio <= 0.7:
			health_bar.modulate = Color(1.0, 0.8, 0.2)
	if health <= 0:
		get_tree().current_scene.add_gold(gold_reward)
		queue_free()
