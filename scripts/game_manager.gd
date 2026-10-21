extends Node2D
# Script principal del juego (coordinador).
# Controla el clic, el vuelo de la bola y conecta las demas partes.
# El tablero (celdas, vecinos, grupos) esta ahora en board.gd

var escena_bola = preload("res://scenes/marble.tscn")

var ancho_pantalla = 1280
var alto_pantalla = 720

# nodos de la escena (los nombres deben ser iguales a los de la escena)
@onready var tablero = $Board
@onready var etiqueta = $UI/InfoLabel
@onready var lanzador = $Shooter

# variables del disparo
var disparando = false
var bola_disparada = null
var direccion_disparo = Vector2(0, -1)
var velocidad = 900.0


func _ready():
	# ponemos el lanzador abajo en el centro
	lanzador.position = Vector2(640, 650)

	# cuando el tablero elimine un grupo, se ejecuta al_eliminar_grupo
	tablero.grupo_eliminado.connect(al_eliminar_grupo)

	etiqueta.text = "Forma grupos de 3 o mas bolas del mismo color"

	# para que se dibuje el fondo
	queue_redraw()


# detecta el clic del raton
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# solo disparamos si no hay otra bola en el aire
			if disparando == false:
				disparar()


func _process(delta):
	if disparando == true:
		mover_bola(delta)


# crea la bola disparada y empieza a moverla
func disparar():
	disparando = true
	direccion_disparo = Vector2.from_angle(lanzador.angulo_disparo)

	bola_disparada = escena_bola.instantiate()
	bola_disparada.position = lanzador.position + direccion_disparo * 30
	bola_disparada.preparar(lanzador.color_actual, Vector2i(0, 0))
	tablero.add_child(bola_disparada)

	# escondemos la bola del lanzador mientras la otra vuela
	lanzador.bola_vista.visible = false
	print("Disparo con color ", lanzador.color_actual)


# mueve la bola y revisa si choco
func mover_bola(delta):
	bola_disparada.position += direccion_disparo * velocidad * delta
	var pos = bola_disparada.position

	# la bola rebota en los lados del tablero
	if pos.x < tablero.limite_izquierdo:
		bola_disparada.position.x = tablero.limite_izquierdo
		direccion_disparo.x = abs(direccion_disparo.x)
	if pos.x > tablero.limite_derecho:
		bola_disparada.position.x = tablero.limite_derecho
		direccion_disparo.x = -abs(direccion_disparo.x)

	# si toco el techo o una bola, la dejamos en el tablero
	if tablero.hay_colision(bola_disparada.position):
		terminar_disparo()


# deja la bola en el tablero y prepara el siguiente disparo
func terminar_disparo():
	tablero.colocar_bola(bola_disparada)

	disparando = false
	bola_disparada = null
	lanzador.nuevo_color()
	lanzador.bola_vista.visible = true


# se ejecuta cuando el tablero avisa que elimino un grupo
func al_eliminar_grupo(cantidad):
	print("game_manager: se elimino un grupo de ", cantidad, " bolas")
	# aqui sumaremos puntos en la Fase 5


# dibuja el fondo de la pantalla
func _draw():
	# fondo de la pantalla
	draw_rect(Rect2(0, 0, ancho_pantalla, alto_pantalla), Color("1b2a41"))

	# linea donde esta el lanzador
	draw_line(Vector2(0, 640), Vector2(ancho_pantalla, 640), Color("324a6d"), 2.0)
