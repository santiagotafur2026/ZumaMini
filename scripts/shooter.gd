extends Node2D
# Script del lanzador con imagen de sapo (Fase 3)
# El sapo gira hacia el raton y lleva la bola en la boca.

var escena_bola = preload("res://scenes/marble.tscn")


var ruta_sapo = "res://assets/sprites/sapo.png"
var escala_sapo = 0.5                    # sube o baja para cambiar el tamano
var rotacion_imagen = 0.0                # 0 si el sapo mira arriba, 3.14159 si mira abajo
var posicion_boca = Vector2(0, -30)      # donde se ve la bola (x, y)


var cantidad_colores = 5
var color_actual = 0
var bola_vista = null      # la bolita que tiene en la boca
var sprite = null          # la imagen del sapo
var angulo_disparo = -1.57 # hacia arriba por defecto


func _ready():
	# si existe la imagen del sapo la ponemos
	if ResourceLoader.exists(ruta_sapo):
		sprite = Sprite2D.new()
		sprite.texture = load(ruta_sapo)
		sprite.scale = Vector2(escala_sapo, escala_sapo)
		sprite.rotation = rotacion_imagen
		add_child(sprite)

	# creamos la bola que se ve en la boca (se agrega despues para quedar encima)
	bola_vista = escena_bola.instantiate()
	bola_vista.position = posicion_boca
	add_child(bola_vista)
	nuevo_color()


# elige un color nuevo al azar para la siguiente bola
# elige un color nuevo para la siguiente bola
# si recibe una lista, elige solo entre esos colores
func nuevo_color(lista = []):
	if lista.size() > 0:
		color_actual = lista[randi_range(0, lista.size() - 1)]
	else:
		color_actual = randi_range(0, cantidad_colores - 1)
	bola_vista.preparar(color_actual, Vector2i(0, 0))


func _process(delta):
	# direccion desde el sapo hasta el raton
	var raton = get_global_mouse_position()
	var direccion = raton - global_position

	var angulo = direccion.angle()

	# si el raton esta mas abajo que el sapo, apuntamos casi horizontal
	if angulo > 0:
		if direccion.x >= 0:
			angulo = -0.17
		else:
			angulo = -2.97

	# no dejamos que apunte demasiado horizontal
	angulo = clamp(angulo, -2.97, -0.17)

	angulo_disparo = angulo
	# la imagen mira hacia arriba, por eso sumamos PI / 2
	rotation = angulo + PI / 2


func _draw():
	# si no hay imagen, dibujamos una base simple para no dejarlo vacio
	if sprite == null:
		draw_circle(Vector2(0, 0), 38, Color("324a6d"))
		draw_circle(Vector2(0, 0), 30, Color("1b2a41"))

	# linea de ayuda para apuntar
	draw_line(Vector2(0, -56), Vector2(0, -220), Color(1, 1, 1, 0.25), 2.0)
