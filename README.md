# Zuma Mini

Videojuego 2D de un solo nivel inspirado en la mecánica de *Zuma Deluxe*.
El jugador dispara bolas de colores desde un lanzador hacia un conjunto de bolas
**estáticas**; al formar un grupo conectado de 3 o más bolas del mismo color, estas
explotan y suman puntos.




## Tecnologías
- Godot Engine 4.x (estable, probado con la configuración 4.3)
- GDScript
- Git / GitHub

## Requisitos
- Godot 4.3 o superior de la rama 4.x: https://godotengine.org/download
- Un equipo de escritorio (Windows, macOS o Linux)

## Instalación y ejecución
1. Clona el repositorio: `https://github.com/santiagotafur2026/ZumaMini.git`
2. Abre Godot y pulsa **Importar** (o *Import*).
3. Selecciona el archivo `project.godot` de esta carpeta.
4. Pulsa **Importar y editar**.
5. Ejecuta con **F5** (escena principal: `scenes/main_menu.tscn`).

## Controles (previstos)
- Ratón: apuntar
- Clic izquierdo: disparar

## Reglas (previstas)
- Un solo nivel con bolas estáticas.
- Grupos conectados de 3+ bolas del mismo color desaparecen.
- 10 puntos por bola eliminada.
- Victoria al eliminar todas las bolas objetivo.

## Estructura de carpetas
```
ZumaMini/
  project.godot
  README.md
  .gitignore
  scenes/      # escenas (.tscn)
  scripts/     # scripts (.gd)
  docs/        # documentación y capturas
  assets/      # audio, fuentes y sprites originales
```

## Gráficos
Se usarán formas geométricas y recursos propios o con licencia compatible.

## Funcionalidades
- [x] Fase 1: proyecto, resolución 1280x720, escena inicial
- [ x] Fase 2: tablero y bolas estáticas
- [x ] Fase 3: lanzador y disparo
- [x ] Fase 4: coincidencias y eliminación
- [ x] Fase 5: explosiones y puntuación
- [ x] Fase 6: menú, HUD y reinicio
- [ ] Fase 7: pruebas y entrega
