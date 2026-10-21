extends Node2D
# Efecto de explosion (Fase 5)
# Dibuja un anillo, un destello y unas particulas que salen disparadas.
# Se borra solo cuando termina.

var color = Color(1, 1, 1)
var tiempo = 0.0
var duracion = 0.5
var particulas = []   # cada particula es una direccion con velocidad


# se llama justo despues de crear la explosion
func preparar(el_color):
	color = el_color

	# creamos 8 particulas que salen en distintas direcciones
	for i in range(8):
		var angulo = i * (TAU / 8) + randf_range(-0.2, 0.2)
		var velocidad = randf_range(80, 160)
		particulas.append(Vector2.from_angle(angulo) * velocidad)


func _process(delta):
	tiempo += delta

	# cuando termina el tiempo, la explosion se borra
	if tiempo >= duracion:
		queue_free()
		return

	queue_redraw()


func _draw():
	# avance va de 0 (inicio) a 1 (final)
	var avance = tiempo / duracion
	var transparencia = 1.0 - avance
	var color_fade = Color(color.r, color.g, color.b, transparencia)

	# anillo que se hace mas grande
	draw_arc(Vector2(0, 0), 10 + avance * 30, 0, TAU, 32, color_fade, 4.0)

	# destello blanco en el centro que se achica
	draw_circle(Vector2(0, 0), 18 * (1.0 - avance), Color(1, 1, 1, transparencia * 0.8))

	# particulas que se alejan del centro
	for p in particulas:
		draw_circle(p * tiempo, 5 * (1.0 - avance) + 1, color_fade)
