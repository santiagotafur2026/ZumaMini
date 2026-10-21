extends Node2D
# Script del lanzador (Fase 3)
# Apunta al raton y guarda el color de la bola que se va a disparar.

var escena_bola = preload("res://scenes/marble.tscn")

var cantidad_colores = 5
var color_actual = 0
var bola_vista = null      # la bolita que se ve dentro del lanzador
var angulo_disparo = -1.57 # hacia arriba por defecto


func _ready():
	# creamos la bola que se ve en el lanzador
	bola_vista = escena_bola.instantiate()
	add_child(bola_vista)
	nuevo_color()


# elige un color nuevo al azar para la siguiente bola
func nuevo_color():
	color_actual = randi_range(0, cantidad_colores - 1)
	bola_vista.preparar(color_actual, Vector2i(0, 0))


func _process(delta):
	# direccion desde el lanzador hasta el raton
	var raton = get_global_mouse_position()
	var direccion = raton - global_position

	var angulo = direccion.angle()

	# si el raton esta mas abajo que el lanzador, apuntamos casi horizontal
	if angulo > 0:
		if direccion.x >= 0:
			angulo = -0.17
		else:
			angulo = -2.97

	# no dejamos que apunte demasiado horizontal
	angulo = clamp(angulo, -2.97, -0.17)

	angulo_disparo = angulo
	# el canon se dibuja hacia arriba, por eso sumamos PI / 2
	rotation = angulo + PI / 2


# dibujamos el lanzador con formas
func _draw():
	# base
	draw_circle(Vector2(0, 0), 38, Color("324a6d"))
	draw_circle(Vector2(0, 0), 30, Color("1b2a41"))

	# canon
	draw_rect(Rect2(-14, -62, 28, 44), Color("4a6a9a"))
	draw_rect(Rect2(-14, -62, 28, 44), Color("0f1b2d"), false, 2.0)

	# linea de ayuda para apuntar
	draw_line(Vector2(0, -66), Vector2(0, -220), Color(1, 1, 1, 0.25), 2.0)
