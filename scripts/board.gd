extends Node2D
# Script del tablero.
# Guarda las bolas, las celdas, los vecinos y elimina los grupos.

# esta senal avisa cuando se elimina un grupo (la usaremos en la Fase 5)
signal grupo_eliminado(cantidad)

var escena_bola = preload("res://scenes/marble.tscn")

# tamanos
var ancho_pantalla = 1280
var radio = 24.0
var diametro = 48.0
var alto_fila = 41.57  # es 48 * 0.866

# cuantas bolas hay al empezar
var columnas = 14
var filas = 7
var cantidad_colores = 5

# filas posibles en total (para poder agregar bolas abajo)
var filas_maximas = 11

# minimo de bolas juntas para que desaparezcan
var minimo_grupo = 3

# guarda las bolas: celda -> bola
var grid = {}

# donde empieza el tablero
var origen = Vector2(0, 0)

# limites a los lados (los usa game_manager para los rebotes)
var limite_izquierdo = 0.0
var limite_derecho = 0.0


func _ready():
	# centramos el tablero
	var ancho_tablero = columnas * diametro + radio
	origen.x = (ancho_pantalla - ancho_tablero) / 2 + radio
	origen.y = 110

	limite_izquierdo = origen.x
	limite_derecho = origen.x + columnas * diametro - radio

	crear_tablero()
	print("Tablero creado con ", grid.size(), " bolas")

	# para que se dibuje el cuadro del tablero
	queue_redraw()


# ---------- celdas y vecinos ----------

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


# dice si una celda esta en la fila 0 o tiene una bola vecina
func tiene_apoyo(celda):
	if celda.y == 0:
		return true

	var vecinos = obtener_vecinos(celda)
	for v in vecinos:
		if grid.has(v):
			return true

	return false


# ---------- crear el tablero ----------

# crea todas las bolas
func crear_tablero():
	var colores = generar_colores()

	for celda in colores.keys():
		var bola = escena_bola.instantiate()
		bola.position = celda_a_posicion(celda)
		bola.preparar(colores[celda], celda)
		add_child(bola)
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


# cuenta cuantas bolas del mismo color estan juntas (solo para crear el tablero)
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


# ---------- disparo ----------

# dice si una posicion toco el techo o alguna bola del tablero
func hay_colision(pos):
	# el techo
	if pos.y <= origen.y:
		return true

	# las bolas
	for celda in grid.keys():
		var otra = grid[celda]
		if pos.distance_to(otra.position) < 44:
			return true

	return false


# busca la celda libre mas cercana y deja la bola ahi
# devuelve true si pudo colocarla
func colocar_bola(bola):
	var pos = bola.position
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

	if encontrada == false:
		# no deberia pasar, pero por si acaso
		bola.queue_free()
		print("No se encontro celda libre")
		return false

	bola.position = celda_a_posicion(mejor_celda)
	bola.celda = mejor_celda
	grid[mejor_celda] = bola
	print("Bola colocada en la celda ", mejor_celda)

	# revisamos si se formo un grupo
	revisar_grupo(mejor_celda)
	return true


# ---------- grupos ----------

# busca todas las bolas conectadas del mismo color que la celda dada
func buscar_grupo(inicio):
	var color = grid[inicio].color_index
	var grupo = [inicio]
	var visitadas = {}
	visitadas[inicio] = true
	var pendientes = [inicio]

	while pendientes.size() > 0:
		var actual = pendientes.pop_back()
		var vecinos = obtener_vecinos(actual)

		for vecina in vecinos:
			# la vecina debe tener bola, no haber sido visitada y ser del mismo color
			if grid.has(vecina) and not visitadas.has(vecina):
				if grid[vecina].color_index == color:
					visitadas[vecina] = true
					grupo.append(vecina)
					pendientes.append(vecina)

	return grupo


# revisa el grupo de la bola recien colocada y lo elimina si es de 3 o mas
func revisar_grupo(celda):
	var grupo = buscar_grupo(celda)
	print("Grupo del mismo color: ", grupo.size(), " bolas")

	if grupo.size() >= minimo_grupo:
		eliminar_grupo(grupo)
	else:
		print("El grupo es muy pequeno, no se elimina")


# quita las bolas del grupo del tablero y del grid
func eliminar_grupo(grupo):
	var cantidad = grupo.size()

	for celda in grupo:
		var bola = grid[celda]
		grid.erase(celda)   # la sacamos de la estructura de datos
		bola.queue_free()   # la quitamos de la pantalla

	print("Se eliminaron ", cantidad, " bolas. Quedan ", grid.size())

	# avisamos que se elimino un grupo
	grupo_eliminado.emit(cantidad)


# ---------- dibujo ----------

# dibuja el cuadro oscuro detras de las bolas
func _draw():
	var ancho_tablero = columnas * diametro + radio
	var alto_tablero = (filas_maximas - 1) * alto_fila + diametro
	var cuadro = Rect2(origen.x - radio - 24, origen.y - radio - 24, ancho_tablero + 48, alto_tablero + 48)
	draw_rect(cuadro, Color("0f1b2d"))
	draw_rect(cuadro, Color("324a6d"), false, 3.0)
