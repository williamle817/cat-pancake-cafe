extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	print("Animation finished:", anim_name)
	if anim_name == "faded_to_black":
		print("matched!")
		on_transition_finished.emit()
		animation_player.play("faded_to_normal")
	elif anim_name == "faded_to_normal":
		color_rect.visible = false

func fade_to_scene(path: String):
	color_rect.visible = true
	animation_player.play("faded_to_black")
	await on_transition_finished
	get_tree().change_scene_to_file(path)
