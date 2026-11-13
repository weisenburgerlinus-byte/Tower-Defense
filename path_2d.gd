extends Path2D

#loading a saved enemy template
var enemy_scene: PackedScene = preload("res://enemy.tscn")

@export var max_enemies: int = 5
var spawned_enemies: int = 0
var current_wave: int = 0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var next_wave_button: Button = $"../CanvasLayer/NextWaveButton"

func _ready() -> void:
	$Line2D.points = curve.get_baked_points()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	next_wave_button.pressed.connect(_on_next_wave_pressed)
	
func _on_next_wave_pressed() -> void:
	next_wave_button.visible = false
	current_wave += 1
	max_enemies = 2 + (current_wave * 3)
	spawned_enemies = 0
	spawn_timer.start()
	
func _on_spawn_timer_timeout() -> void:
		if spawned_enemies < max_enemies:
			var new_enemy = enemy_scene.instantiate()
			add_child(new_enemy)
			
			var type = "normal"
			var roll = randf()
			
			if current_wave >= 3 and roll < 0.20:
				type = "tank"
			elif current_wave >= 2 and roll < 0.50:
				type = "runner"
				
			new_enemy.setup_enemy(type, current_wave)
			
			spawned_enemies += 1
		else:
			#stops the timer and shows next wave button again
			spawn_timer.stop()
			next_wave_button.text = "Start Wave" + str(current_wave + 1)
			next_wave_button.visible = true
