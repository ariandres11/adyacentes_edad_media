extends Resource
class_name PersonajeDatos

var nombre: String
var ruta_imagen: String
var habilidades: Array[HabilidadBase] = []

# Cuando el tablero necesite dibujarlo, le pides la textura cargada:
func obtener_textura() -> Texture2D:
	return load(ruta_imagen)
