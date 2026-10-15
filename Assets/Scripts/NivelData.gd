extends Resource
class_name NivelData

@export var posiciones_nodos: Array[Vector2] = []
@export var conexiones: Array[Vector2] = []

# Le decimos a Godot: Clave (int) -> Valor (String)
@export var mapa_personajes: Dictionary[int, String] = {}

# Le decimos a Godot: Clave (String) -> Valor (Texture2D)
@export var imagenes_personajes: Dictionary[String, Texture2D] = {}
