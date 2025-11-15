extends Node2D
class_name GameManager

# Buttons
@onready var back_button = get_node("../CanvasLayer/Back")

# Musics
@onready var hover_sound = get_node("../CanvasLayer/HoverSound")
@onready var click_sound = get_node("../CanvasLayer/ClickSound")
@onready var interact_sound = get_node("../CanvasLayer/InteractiveSound")

# Hover scale factor
const HOVER_SCALE = 0.30
const NORMAL_SCALE = 0.25

# =================== GAME STATE ===================
var coins: int = 10
var current_order: String = ""
var prepared_item: String = ""
var preparing_item: bool = false
var order_timer: float = 0.0
var max_order_time: float = 30.0

var orders = ["Strawberry Pancake", "Blueberry Pancake", "Pancake", "Tea", "Coffee"]

# =================== NODE REFERENCES ===================
@onready var order_label  = get_node("../CanvasLayer/OrderLabel")
@onready var coins_label  = get_node("../CanvasLayer/CoinsLabel")
@onready var customer_node = get_node("../Customer")
@onready var order_icon = customer_node.get_node("OrderIcon") as Sprite2D
@onready var player_node   = get_node("../Player")
@onready var hotbar_icon = get_node("../CanvasLayer/HotbarSlot")

# =================== HOTBAR TEXTURES ===================
var hotbar_textures = {
	"Empty": load("res://Hotbar/EmptyHotBar.png"),
	"Pancake": load("res://Hotbar/PancakeHotBar.png"),
	"Strawberry Pancake": load("res://Hotbar/StrawberryHotBar.png"),
	"Blueberry Pancake": load("res://Hotbar/BlueberryHotBar.png"),
	"Tea": load("res://Hotbar/TeaHotBar.png"),
	"Coffee": load("res://Hotbar/CoffeeHotBar.png")
}

var order_textures = {
	"Tea": load("res://Orders/Tea.png"),
	"Coffee": load("res://Orders/Coffee.png"),
	"Pancake": load("res://Orders/Pancake.png"),
	"Strawberry Pancake": load("res://Orders/StrawberryPancake.png"),
	"Blueberry Pancake": load("res://Orders/BlueberryPancake.png")
}

# =================== MUSIC ===================
func click_sound_play(timeout):
	click_sound.play()
	await get_tree().create_timer(timeout).timeout

func interact_sound_play(timeout):
	interact_sound.play()
	await get_tree().create_timer(timeout).timeout
	
# =================== BUTTONS ===================
func _on_back_pressed():
	# Go back to Main Menu
	await click_sound_play(0.1)
	get_tree().change_scene_to_file("res://LevelSelect.tscn")
	
func _on_back_hover():
	if hover_sound != null: hover_sound.play()
	back_button.modulate = Color(1, 1, 0.7)
	back_button.scale = Vector2(HOVER_SCALE, HOVER_SCALE)

func _on_back_exit():
	back_button.modulate = Color(1, 1, 1)
	back_button.scale = Vector2(NORMAL_SCALE, NORMAL_SCALE)
	
func connect_button():
	back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(_on_back_hover)
	back_button.mouse_exited.connect(_on_back_exit)

# =================== GAME LOOP ===================
func _ready():
	randomize()  # ensure different orders each run

	# Debug: check nodes
	print("GameManager parent children:")
	for child in get_parent().get_children():
		print(child.name)

	if serve_button == null:
		print("ServeButton not found at path ../CanvasLayer/ServeButton")
	if order_label == null:
		print("OrderLabel not found at path ../CanvasLayer/OrderLabel")
	if score_label == null:
		print("ScoreLabel not found at path ../CanvasLayer/ScoreLabel")
	if cat_label == null:
		print("CatLabel not found at path ../CanvasLayer/CatLabel")

	# Connect serve button if it exists
	if serve_button != null:
		serve_button.pressed.connect(_on_serve_pressed)

	generate_new_order()
	update_ui()


# Called when "Serve Order" button is pressed
func _on_serve_pressed():
	score += 1
	check_unlocks()
	generate_new_order()
	update_ui()


# Pick a random order from the list
func generate_new_order():
	if order_label == null:
		return
	if orders.size() == 0:
		order_label.text = "No orders available!"
		return
	var rand_index = randi() % orders.size()
	order_label.text = "Customer wants: " + orders[rand_index]


# Update the score and cat level display
func update_ui():
	if score_label != null:
		score_label.text = "Score: " + str(score)
	if cat_label != null:
		cat_label.text = "Cat Chef Level: " + str(level)


# Check if the player unlocked a new cat
func check_unlocks():
	match score:
		5:
			level = 2
			if cat_label != null:
				cat_label.text = "Unlocked: Fast Chef Cat!"
		10:
			level = 3
			if cat_label != null:
				cat_label.text = "Unlocked: Patient Cat!"
		15:
			level = 4
			if cat_label != null:
				cat_label.text = "Unlocked: Lucky Cat!"
		20:
			level = 5
			if cat_label != null:
				cat_label.text = "Final Unlock: Master Chef Cat! You Win!"
			if serve_button != null:
				serve_button.disabled = true
