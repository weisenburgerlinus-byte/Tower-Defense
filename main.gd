extends Node2D

var tower_scene: PackedScene = preload("res://tower.tscn")

@export var gold: int = 100
@export var base_health: int = 10
@export var tower_cost: int = 50
@export var min_tower_distance: float = 130.0

var towers: Array[Node2D] = []
var selected_tower: Node2D = null
var selected_build_type: int = 1

@onready var stats_label: Label = $CanvasLayer/StatsLabel
var restart_button: Button = null
var message_label: Label = null
var btn_tower_1: Button = null
var btn_tower_2: Button = null #I'll add a sniper tower later

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.18, 0.38, 0.22))
	if has_node("Tower"):
		towers.append($Tower)
	setup_ui_design()
	update_ui()
	
	#restart button
	restart_button = Button.new()
	restart_button.text = "GAME OVER! Click to restart"
	restart_button.position = Vector2(400, 280)
	restart_button.size = Vector2(320, 70)
	restart_button.visible = false
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart_pressed)
	$CanvasLayer.add_child(restart_button)
	
func setup_ui_design() -> void:
	var top_bar = ColorRect.new()
	top_bar.color = Color(0.1, 0.12, 0.15, 0.88)
	top_bar.position = Vector2(0, 0)
	top_bar.size = Vector2(1152, 50)
	$CanvasLayer.add_child(top_bar)
	$CanvasLayer.move_child(top_bar, 0)
	
	stats_label.position = Vector2(20, 12)
	stats_label.add_theme_font_size_override("font_size", 20)
	
	var side_bar = ColorRect.new()
	side_bar.color = Color(0.12, 0.14, 0.18, 0.92)
	side_bar.position = Vector2(930, 50)
	side_bar.size = Vector2(222, 598)
	$CanvasLayer.add_child(side_bar)
	$CanvasLayer.move_child(side_bar, 0)
	
	var shop_title = Label.new()
	shop_title.text = "--- Tower Shop ---"
	shop_title.position = Vector2(965, 70)
	shop_title.add_theme_font_size_override("font_size", 18)
	$CanvasLayer.add_child(shop_title)
	
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
		if pos.distance_to(tower.global_position) < min_tower_distance:
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
		print("Nor enough gold")
		
#merge
func handle_merge_click(click_pos: Vector2) -> void:
	var clicked_tower: Node2D = null
	
	#looks if there is a tower
	for tower in towers:
		if click_pos.distance_to(tower.global_position) < 65.0:
			clicked_tower = tower
			break
		
	#if clicked into nothing removed the tower selection
	if clicked_tower == null:
		if selected_tower != null:
			selected_tower.set_selected(false)
			selected_tower = null
		return
		
	#if not tower is selcted, select the tower
	if selected_tower == null:
		selected_tower = clicked_tower
		selected_tower.set_selected(true)
		
	#two times the same tower removes teh selection
	elif selected_tower == clicked_tower:
		selected_tower.set_selected(false)
		selected_tower = null
		
	#merge if two towers with same level are selected
	elif selected_tower.level == clicked_tower.level:
		clicked_tower.upgrade_from_merge()
		towers.erase(selected_tower)
		selected_tower.queue_free()
		selected_tower = null
		print("Successfully reached level", clicked_tower.level, "gemerged!")
		
	#changes the selection if towers are not at the same level
	else:
		print("Towers have not the same level!")
		selected_tower.set_selected(false)
		selected_tower = clicked_tower
		selected_tower.set_selected(true)
		
func add_gold(amount: int) -> void:
	gold += amount
	update_ui()

func take_base_damage(amount: int) -> void:
	base_health -= amount
	update_ui()
	if base_health <= 0:
		print("GAME OVER!")
		restart_button.text = "GAME OVER (Wave " + str($Path2D.current_wave) + ") - Restart"
		restart_button.visible = true
		get_tree().paused = true
		
func update_ui() -> void:
	stats_label.text = "Gold: "  + str(gold) + " | Leben: " +str(base_health) + " (L-click: build 50G | R-click: Merge)"
	
func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
