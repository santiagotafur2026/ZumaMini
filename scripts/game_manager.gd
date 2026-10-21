extends Node2D
# Script del tablero (Fase 3)
# Crea las bolas quietas y controla el disparo.

var escena_bola = preload("res://scenes/marble.tscn")

# tamanos
var ancho_pantalla = 1280
var alto_pantalla = 720
var radio = 24.0
var diametro = 48.0
var alto_fila = 41.57  # es 48 * 0.866

# cuantas bolas hay al empezar
var columnas = 14
var filas = 7
var cantidad_colores = 5

# filas posibles en total (para poder agregar bolas abajo)
var filas_maximas = 11

# nodos de la escena (los nombres deben ser iguales a los de la escena)
@onready var tablero = $Board
@onready var etiqueta = $UI/InfoLabel
@onready var lanzador = $Shooter

# guarda las bolas: celda -> bola
var grid = {}

# donde empieza el tablero
var origen = Vector2(0, 0)

# variables del disparo
var disparando = false
var bola_disparada = null
var direccion_disparo = Vector2(0, -1)
var velocidad = 900.0


func _ready():
	# centramos el tablero
	var ancho_tablero = columnas * diametro + radio
	origen.x = (ancho_pantalla - ancho_tablero) / 2 + radio
	origen.y = 110

	crear_tablero()

	# ponemos el lanzador abajo en el centro
	lanzador.position = Vector2(640, 650)

	etiqueta.text = "Fase 3: apunta con el raton y dispara con clic izquierdo"
	print("Tablero creado con ", grid.size(), " bolas")

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
	bola_disparada.position = lanzador.position
	bola_disparada.preparar(lanzador.color_actual, Vector2i(0, 0))
	tablero.add_child(bola_disparada)

	# escondemos la bola del lanzador mientras la otra vuela
	lanzador.bola_vista.visible = false
	print("Disparo con color ", lanzador.color_actual)


# mueve la bola y revisa si choco
func mover_bola(delta):
	bola_disparada.position += direccion_disparo * velocidad * delta
	var pos = bola_disparada.position

	# limites a los lados (la bola rebota)
	var limite_izquierdo = origen.x
	var limite_derecho = origen.x + 648

	if pos.x < limite_izquierdo:
		bola_disparada.position.x = limite_izquierdo
		direccion_disparo.x = abs(direccion_disparo.x)
	if pos.x > limite_derecho:
		bola_disparada.position.x = limite_derecho
		direccion_disparo.x = -abs(direccion_disparo.x)

	# si llega al techo, se pega ahi
	if pos.y <= origen.y:
		colocar_bola()
		return

	# si toca otra bola, se pega
	for celda in grid.keys():
		var otra = grid[celda]
		if pos.distance_to(otra.position) < 44:
			colocar_bola()
			return


# busca la celda libre mas cercana y deja la bola ahi
func colocar_bola():
	var pos = bola_disparada.position
	var mejor_celda = Vector2i(0, 0)
	var mejor_distancia = 999999.0
	var encontrada = false

	for fila in range(filas_maximas):
		for columna in range(columnas):
			var celda = Vector2i(columna, fila)

			# la celda debe estar libre
			if grid.has(celda):
				continue

			# y debe estar pegada al techo o a otra bola
			if tiene_apoyo(celda) == false:
				continue

			var distancia = pos.distance_to(celda_a_posicion(celda))
			if distancia < mejor_distancia:
				mejor_distancia = distancia
				mejor_celda = celda
				encontrada = true

	if encontrada == true:
		bola_disparada.position = celda_a_posicion(mejor_celda)
		bola_disparada.celda = mejor_celda
		grid[mejor_celda] = bola_disparada
		print("Bola colocada en la celda ", mejor_celda)
	else:
		# no deberia pasar, pero por si acaso
		bola_disparada.queue_free()
		print("No se encontro celda libre")

	# preparamos el siguiente disparo
	disparando = false
	bola_disparada = null
	lanzador.nuevo_color()
	lanzador.bola_vista.visible = true


# dice si una celda esta en la fila 0 o tiene una bola vecina
func tiene_apoyo(celda):
	if celda.y == 0:
		return true

	var vecinos = obtener_vecinos(celda)
	for v in vecinos:
		if grid.has(v):
			return true

	return false


# pasa de celda (columna, fila) a posicion en pantalla
func celda_a_posicion(celda):
	var x = origen.x + celda.x * diametro

	# si la fila es impar se mueve media bola
	if celda.y % 2 == 1:
		x = x + radio

	var y = origen.y + celda.y * alto_fila
	return Vector2(x, y)


# devuelve las celdas que estan al lado de una celda
func obtener_vecinos(celda):
	var cambios = []

	if celda.y % 2 == 0:
		# fila par
		cambios = [
			Vector2i(1, 0), Vector2i(-1, 0),
			Vector2i(0, -1), Vector2i(-1, -1),
			Vector2i(0, 1), Vector2i(-1, 1)
		]
	else:
		# fila impar
		cambios = [
			Vector2i(1, 0), Vector2i(-1, 0),
			Vector2i(0, -1), Vector2i(1, -1),
			Vector2i(0, 1), Vector2i(1, 1)
		]

	var vecinos = []
	for c in cambios:
		var vecina = celda + c
		# solo si esta dentro del tablero
		if vecina.x >= 0 and vecina.x < columnas and vecina.y >= 0 and vecina.y < filas_maximas:
			vecinos.append(vecina)

	return vecinos


# crea todas las bolas
func crear_tablero():
	var colores = generar_colores()

	for celda in colores.keys():
		var bola = escena_bola.instantiate()
		bola.position = celda_a_posicion(celda)
		bola.preparar(colores[celda], celda)
		tablero.add_child(bola)
		grid[celda] = bola


# elige un color para cada celda
# intenta que no queden 3 iguales juntas al empezar
func generar_colores():
	seed(12345)  # para que siempre salga igual
	var colores = {}

	for fila in range(filas):
		for columna in range(columnas):
			var celda = Vector2i(columna, fila)

			# probamos colores hasta que no se forme un grupo de 3
			for intento in range(20):
				colores[celda] = randi_range(0, cantidad_colores - 1)
				if tamano_grupo(colores, celda) < 3:
					break

	return colores


# cuenta cuantas bolas del mismo color estan juntas
func tamano_grupo(colores, inicio):
	var color = colores[inicio]
	var visitadas = {}
	visitadas[inicio] = true
	var pendientes = [inicio]

	while pendientes.size() > 0:
		var actual = pendientes.pop_back()
		var vecinos = obtener_vecinos(actual)

		for vecina in vecinos:
			if colores.has(vecina) and not visitadas.has(vecina):
				if colores[vecina] == color:
					visitadas[vecina] = true
					pendientes.append(vecina)

	return visitadas.size()


# dibuja el fondo
func _draw():
	# fondo de la pantalla
	draw_rect(Rect2(0, 0, ancho_pantalla, alto_pantalla), Color("1b2a41"))

	# cuadro oscuro detras de las bolas
	var ancho_tablero = columnas * diametro + radio
	var alto_tablero = (filas_maximas - 1) * alto_fila + diametro
	var cuadro = Rect2(origen.x - radio - 24, origen.y - radio - 24, ancho_tablero + 48, alto_tablero + 48)
	draw_rect(cuadro, Color("0f1b2d"))
	draw_rect(cuadro, Color("324a6d"), false, 3.0)

	# linea donde esta el lanzador
	draw_line(Vector2(0, 640), Vector2(ancho_pantalla, 640), Color("324a6d"), 2.0)
