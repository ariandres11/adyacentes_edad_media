extends Node2D
class_name Nodo

var id: int
var vecinos: Array[Nodo] = []
var personaje_actual: PersonajeDatos = null

signal nodo_cliqueado(nodo: Nodo)

# Esta es la función que te faltaba
func actualizar_visual() -> void:
	# Verificamos que el nodo tenga el Sprite2D adentro
	if has_node("SpritePersonaje"):
		var sprite = $SpritePersonaje
		
		# Si hay un personaje con imagen, la cargamos
		if personaje_actual != null and personaje_actual.textura_visual != null:
			sprite.texture = personaje_actual.textura_visual
			sprite.visible = true
		else:
			# Si la casilla está vacía, ocultamos el dibujo
			sprite.visible = false
			sprite.texture = null
	else:
		push_warning("Asegúrate de agregar un nodo Sprite2D llamado 'SpritePersonaje' dentro de tu escena Casilla.")

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		nodo_cliqueado.emit(self)
