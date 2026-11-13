extends Node2D

@export var damage: int = 1
var level: int = 1
var level_label: Label = null

var bullet_scene: PackedScene = preload("res://bullet.tscn")
var enemies_in_range: Array[Node2D] = []

@onready var range_area: Area2D = $Range
@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	range_area.area_entered.connect(_on_area_entered)
	range_area.area_exited.connect(_on_area_exited)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	#lv over the tower
	level_label = Label.new()
	level_label.text = "Lv. 1"
	level_label.position = Vector2(-20, -85)
	add_child(level_label)
	
	#Spins the tower in direction of the enemy
func _process(_delta: float) -> void:
	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		look_at(target.global_position)
		level_label.global_rotation = 0
		
func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.has_method("take_damage"):
		enemies_in_range.append(parent)
		
func _on_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	enemies_in_range.erase(parent)
		
func _on_shoot_timer_timeout() -> void:
	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		
		#new bullet appears
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		bullet.target = target
		bullet.damage = damage
		
#if two towers merge:
func upgrade_from_merge() -> void:
	level += 1
	damage *= 2
	shoot_timer.wait_time = max(0.15, shoot_timer.wait_time * 0.75)
	scale *= 1.15
	level_label.text = "Lv. " + str(level)
	set_selected(false)
	
#change the color after merge
func set_selected(selected: bool) -> void:
	if selected:
		modulate = Color(0.3, 1.0, 0.3)
	else:
		if level == 1:
			modulate = Color(1, 1, 1)
		elif level == 2:
			modulate = Color(1.0, 0.8, 0.2)
		elif level == 3:
			modulate = Color(0.2, 0.8, 1.0)
		else:
			modulate = Color(1.0, 0.2, 0.8)
