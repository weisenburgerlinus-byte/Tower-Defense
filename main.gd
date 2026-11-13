extends Node2D

var tower_scene: PackedScene = preload("res://tower.tscn")

@export var gold: int = 100
@export var base_health: int = 10
@export var tower_cost: int = 50
@export var min_tower_distance: float = 130.0

var tower_positions: Array[Node2D] = []
var selected_tower: Node2D = null

@onready var stats_label: Label = $CanvasLayer/StatsLabel

func _ready() -> void:
	if has_node("Tower"):
		tower.append("$Tower")
	update_ui()
	
func _unhandled_input(event: InputEvent) -> void:
	# left click is building a tower at mouse position
	if event is InputEventMouseButton and event.pressed:
		#new tower
		if event.button_index == MOUSE_BUTTON_LEFT:
		build_tower(get_global_mouse_position())
		#merge
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			handle_merge_click(get_global_mouse_position())
		
func build_tower(pos: Vector2) -> void:
	#proofs if there is a tower already
	for tower in towers:
		if pos.distance_to(existing_pos) < min_tower_distance:
			print("Here is already a tower!")
			return
			
	if gold >= tower_cost:
		gold -= tower_cost
		var new_tower = tower_scene.instantiate()
		add_child(new_tower)
		new_tower.global_position = pos
		towers.append(new_tower)
		update_ui()
	else:
		print("Not enough gold!")
		
		
func add_gold(amount: int) -> void:
	gold += amount
	update_ui()

func take_base_damage(amount: int) -> void:
	base_health -= amount
	update_ui()
	if base_health <= 0:
		print("GAME OVER!")
		get_tree().paused = true
		
func update_ui() -> void:
	stats_label.text = "Gold: "  + str(gold) + " | Leben: " +str(base_health) + " (Turm: 50G  per click)"
