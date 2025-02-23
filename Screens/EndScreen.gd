extends Control

var currentpage = 0

func _on_button_pressed() -> void:
	match currentpage:
		0:
			$Panel2.show()
			$Panel2/AnimationPlayer.play("enter")
		1:
			$Panel2/AnimationPlayer.play("flippage")
			$Button.text = "Bye"
		2:
			get_tree().change_scene_to_file("res://Screens/MainMenu.tscn")
	currentpage += 1
