extends Node2D
# Este script crea el tablero con las bolas quietas (Fase 2).
# Las bolas estan en una cuadricula hexagonal: las filas impares
# se mueven media bola a la derecha para que encajen.

const ESCENA_BOLA = preload("res://scenes/marble.tscn")

const ANCHO_PANTALLA = 1280
const ALTO_PANTALLA = 720
const RADIO = 24.0                 # la mitad del espacio que ocupa una bola
const DIAMETRO = 48.0
const ALTO_FILA = 41.57            # 48 * 0.866, distancia vertical entre filas
const COLUMNAS = 14
const FILAS = 7
const CANTIDAD_COLORES = 5

@onready var tablero = $Board
@onready var etiqueta = $UI/InfoLabel

# Diccionario: celda (columna, fila) -> bola que esta ahi
var grid = {}

# Posicion donde empieza el tablero
var origen = Vector2(0, 0)


func _ready():
	# Calculamos el origen para que el tablero quede centrado
	var ancho_tablero = COLUMNAS * DIAMETRO + RADIO
	origen.x = (ANCHO_PANTALLA - ancho_tablero) / 2 + RADIO
	origen.y = 110

	crear_tablero()

	etiqueta.text = "Fase 2: " + str(grid.size()) + " bolas estaticas"
	print("Tablero creado con ", grid.size(), " bolas")
	queue_redraw()


# Convierte una celda (columna, fila) a una posicion en la pantalla
func celda_a_posicion(celda):
	var x = origen.x + celda.x * DIAMETRO
	# Las filas impares se corren media bola
	if celda.y % 2 == 1:
		x = x + RADIO
	var y = origen.y + celda.y * ALTO_FILA
	return Vector2(x, y)


# Devuelve las celdas vecinas de una celda (maximo 6)
func obtener_vecinos(celda):
	var desplazamientos = []

	if celda.y % 2 == 0:
		# fila par
		desplazamientos = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1),
			Vector2i(-1, -1), Vector2i(0, 1), Vector2i(-1, 1)]
	else:
		# fila impar
		desplazamientos = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1),
			Vector2i(1, -1), Vector2i(0, 1), Vector2i(1, 1)]

	var vecinos = []
	for d in desplazamientos:
		var vecina = celda + d
		# Solo la agregamos si esta dentro del tablero
		if vecina.x >= 0 and vecina.x < COLUMNAS and vecina.y >= 0 and vecina.y < FILAS:
			vecinos.append(vecina)
	return vecinos


# Crea todas las bolas
func crear_tablero():
	var colores = generar_colores()

	for celda in colores.keys():
		var bola = ESCENA_BOLA.instantiate()
		bola.position = celda_a_posicion(celda)
		bola.preparar(colores[celda], celda)
		tablero.add_child(bola)
		grid[celda] = bola


# Elige un color para cada celda. Intenta que al empezar no haya
# grupos de 3 o mas bolas iguales juntas.
func generar_colores():
	seed(12345)  # semilla fija: el tablero sale igual siempre
	var colores = {}

	for fila in FILAS:
		for columna in COLUMNAS:
			var celda = Vector2i(columna, fila)

			# Probamos hasta 20 colores al azar hasta encontrar uno que no forme grupo de 3
			for intento in 20:
				colores[celda] = randi_range(0, CANTIDAD_COLORES - 1)
				if tamano_grupo(colores, celda) < 3:
					break

	return colores


# Cuenta cuantas bolas del mismo color estan conectadas a "inicio"
func tamano_grupo(colores, inicio):
	var color = colores[inicio]
	var visitadas = {}
	visitadas[inicio] = true
	var pendientes = [inicio]

	while pendientes.size() > 0:
		var actual = pendientes.pop_back()
		for vecina in obtener_vecinos(actual):
			if colores.has(vecina) and not visitadas.has(vecina) and colores[vecina] == color:
				visitadas[vecina] = true
				pendientes.append(vecina)

	return visitadas.size()


# Dibuja el fondo
func _draw():
	# Fondo de toda la pantalla
	draw_rect(Rect2(0, 0, ANCHO_PANTALLA, ALTO_PANTALLA), Color("1b2a41"))

	# Panel oscuro detras de las bolas
	var ancho_tablero = COLUMNAS * DIAMETRO + RADIO
	var alto_tablero = (FILAS - 1) * ALTO_FILA + DIAMETRO
	var panel = Rect2(origen.x - RADIO - 24, origen.y - RADIO - 24, ancho_tablero + 48, alto_tablero + 48)
	draw_rect(panel, Color("0f1b2d"))
	draw_rect(panel, Color("324a6d"), false, 3.0)

	# Linea donde ira el lanzador (Fase 3)
	draw_line(Vector2(0, 640), Vector2(ANCHO_PANTALLA, 640), Color("324a6d"), 2.0)
