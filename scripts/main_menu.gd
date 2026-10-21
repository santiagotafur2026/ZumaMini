extends Control
# Menu principal (Fase 6)

func _ready():
	# conectamos los botones con sus funciones
	$CenterContainer/VBoxContainer/BotonJugar.pressed.connect(al_jugar)
	$CenterContainer/VBoxContainer/BotonSalir.pressed.connect(al_salir)


# cambia a la escena del juego
func al_jugar():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


# cierra el juego
func al_salir():
	get_tree().quit()
