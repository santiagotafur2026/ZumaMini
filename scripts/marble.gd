extends Node2D
class_name Marble
# Esta es una bola del tablero.
# Si existe la imagen balls.png la usa, y si no, dibuja un circulo de color.

# Colores por si no hay imagen (0 rojo, 1 azul, 2 verde, 3 amarillo, 4 morado)
const COLORES = [
	Color("e63946"),
	Color("3a86ff"),
	Color("2ec27e"),
	Color("ffd23f"),
	Color("9d4edd"),
]

# Datos de la imagen opcional: cada bolita mide 32x32 pixeles
const RUTA_IMAGEN = "res://assets/sprites/balls.png"
const TAMANO_FRAME = 32
const TOTAL_FRAMES = 51

# En que columna de la imagen esta cada color:
# rojo = 3, azul = 0, verde = 1, amarillo = 5, morado = 2
const COLUMNAS = [3, 0, 1, 5, 2]

# Tamano con el que se dibuja la bola en pantalla
const TAMANO_PANTALLA = 46.0

var color_index = 0          # que color tiene la bola (0 a 4)
var celda = Vector2i(0, 0)   # en que lugar de la cuadricula esta
var frame = 0                # que fila de la imagen usamos
var imagen = null            # aqui guardamos la imagen si existe


# Esta funcion la llamamos desde game_manager para preparar la bola
func preparar(indice, la_celda):
	color_index = indice
	celda = la_celda

	# Cada bola usa un frame distinto para que no se vean todas iguales
	frame = (celda.x * 7 + celda.y * 13) % TOTAL_FRAMES

	# Revisamos si la imagen existe
	if ResourceLoader.exists(RUTA_IMAGEN):
		imagen = load(RUTA_IMAGEN)

	queue_redraw()  # le pedimos a Godot que vuelva a dibujar


func _draw():
	if imagen != null:
		# Cortamos un cuadradito de la imagen grande
		var corte = Rect2(COLUMNAS[color_index] * TAMANO_FRAME, frame * TAMANO_FRAME, TAMANO_FRAME, TAMANO_FRAME)
		# Lugar donde se dibuja (centrado en la posicion de la bola)
		var destino = Rect2(-TAMANO_PANTALLA / 2, -TAMANO_PANTALLA / 2, TAMANO_PANTALLA, TAMANO_PANTALLA)
		draw_texture_rect_region(imagen, destino, corte)
	else:
		# Si no hay imagen, dibujamos circulos
		var color = COLORES[color_index]
		draw_circle(Vector2.ZERO, 22, color.darkened(0.45))   # borde oscuro
		draw_circle(Vector2.ZERO, 19, color)                  # cuerpo
		draw_circle(Vector2(-6, -7), 7, Color(1, 1, 1, 0.45)) # brillo
