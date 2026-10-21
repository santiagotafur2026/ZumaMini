extends Node2D
# Script principal del juego (coordinador).
# Controla el clic, el vuelo de la bola, el puntaje y conecta las demas partes.
# El tablero (celdas, vecinos, grupos) esta en board.gd

var escena_bola = preload("res://scenes/marble.tscn")

var ancho_pantalla = 1280
var alto_pantalla = 720

# nodos de la escena (los nombres deben ser iguales a los de la escena)
@onready var tablero = $Board
@onready var etiqueta = $UI/InfoLabel
@onready var etiqueta_puntaje = $UI/ScoreLabel
@onready var lanzador = $Shooter

# variables del disparo
var disparando = false
var bola_disparada = null
var direccion_disparo = Vector2(0, -1)
var velocidad = 900.0

# puntaje: 10 puntos por cada bola eliminada
var puntos = 0
var puntos_por_bola = 10


func _ready():
	# ponemos el lanzador abajo en el centro
	lanzador.position = Vector2(640, 650)

	# cuando el tablero elimine un grupo, se ejecuta al_eliminar_grupo
	tablero.grupo_eliminado.connect(al_eliminar_grupo)

	etiqueta.text = "Apunta con el raton y dispara con clic izquierdo"
	actualizar_puntaje()

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
func al_eliminar_grupo(cantidad, posicion):
	var ganados = cantidad * puntos_por_bola
	puntos += ganados
	actualizar_puntaje()
	mostrar_puntos(ganados, posicion)
	print("Puntos ganados: ", ganados, " | Total: ", puntos)


# cambia el texto del puntaje
func actualizar_puntaje():
	etiqueta_puntaje.text = "Puntaje: " + str(puntos)


# muestra un texto "+30" que sube y se desvanece
func mostrar_puntos(ganados, posicion):
	var texto = Label.new()
	texto.text = "+" + str(ganados)
	texto.add_theme_font_size_override("font_size", 32)
	texto.add_theme_color_override("font_color", Color("ffd23f"))
	texto.add_theme_color_override("font_outline_color", Color("0f1b2d"))
	texto.add_theme_constant_override("outline_size", 6)
	texto.position = posicion - Vector2(30, 20)
	texto.z_index = 10
	add_child(texto)

	# animacion: sube 60 pixeles y se hace transparente en 0.9 segundos
	var animacion = create_tween()
	animacion.set_parallel(true)
	animacion.tween_property(texto, "position:y", texto.position.y - 60, 0.9)
	animacion.tween_property(texto, "modulate:a", 0.0, 0.9)
	animacion.chain().tween_callback(texto.queue_free)


# dibuja el fondo de la pantalla
func _draw():
	# fondo de la pantalla
	draw_rect(Rect2(0, 0, ancho_pantalla, alto_pantalla), Color("1b2a41"))

	# linea donde esta el lanzador
	draw_line(Vector2(0, 640), Vector2(ancho_pantalla, 640), Color("324a6d"), 2.0)
