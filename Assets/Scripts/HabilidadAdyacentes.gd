extends HabilidadBase
class_name HabilidadAdyacentes

func calcular_nodos_validos(nodo_origen: Nodo) -> Array[Nodo]:
	var validos: Array[Nodo] = []
	for vecino in nodo_origen.vecinos:
		if vecino.personaje_actual == null:
			validos.append(vecino)
	return validos
