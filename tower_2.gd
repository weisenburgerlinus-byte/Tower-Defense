extends Node2D

@export var damage: int = 1
var enemies_in_range: Array[Node2D] = []

@onready var range_area: Area2D = $Range
@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	range_area.area_entered.connect(_on_area_entered)
	range_area.area_exited.connect(_on_area_exited)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	#Spins the tower in direction of the enemy
func _process(_delta: float) -> void:
	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		look_at(target.global_position)
		
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
		target.take_damage(damage)
