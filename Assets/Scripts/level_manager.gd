extends Node3D
class_name LevelManager

# ================= VARIABLES DE CONFIGURACIÓN =================

@export var escena_nodo: PackedScene # La escena Casilla.tscn que contiene el Sprite2D y Area2D
@export var escena_pj: PackedScene # La escena Casilla.tscn que contiene el Sprite2D y Area2D

const TAM_CELDA: float = 2.0 # Escala para distanciar los nodos en la pantalla

# Opción 1: El nivel armado a mano en Godot (Resource)
@export var nivel_resource: NivelData

# Opción 2: La ruta al archivo JSON
@export_file("*.json") var ruta_json: String 

# Opcional: Si cargas desde JSON (que es solo texto), necesitas un lugar donde guardar 
# las fotos de "Campesino", "Rey", etc. para que el script las encuentre.
@export var imagenes_json_fallback: Dictionary[String, Texture2D] = {}

var mapa_nodos: Dictionary = {} # Guarda las instancias creadas { id: NodoGrafo }

# ================= FLUJO PRINCIPAL =================

func _ready() -> void:
	#if nivel_resource != null:
		#print("Cargando nivel desde Resource...")
		#cargar_desde_resource(nivel_resource)
	#elif ruta_json != "":
		#print("Cargando nivel desde JSON...")
		#cargar_desde_json(ruta_json)
	#else:
		#push_warning("No se asignó ningún nivel para cargar.")

	var datos_nivel := cargar_datos_nivel(ruta_json)
	generar_nivel(datos_nivel)
	
func cargar_datos_nivel(ruta: String) -> Dictionary:
	var archivo = FileAccess.open(ruta, FileAccess.READ)
	if not archivo: 
		push_error("No se pudo abrir el JSON")
		return {}
		
	var json = JSON.new()
	if json.parse(archivo.get_as_text()) != OK:
		return {}
	return json.data

func generar_nivel(datos) -> void:
	# 1. y 2. Instanciar Nodos y Asignar Personajes
	for i in range(datos.nodos.size()):
		var nodo = datos.nodos[i]
		
		var nuevo_nodo = escena_nodo.instantiate()
		nuevo_nodo.name = "Personaje" + str(i)
		nuevo_nodo.position = Vector3(nodo.posicion.x, 0, nodo.posicion.y) * TAM_CELDA
		add_child(nuevo_nodo)
		
				
		var mapa_pj = datos.personajes
		# Revisamos si el diccionario de personajes tiene registrado este ID
		var tipo_personaje = mapa_pj[i]
		# Creamos la ficha de datos (suponiendo que usas el sistema ECS que hablamos)
		var pj = escena_pj.instantiate()
		nuevo_nodo.add_child(pj)
		
		
		# mapa_nodos[i] = nuevo_nodo

	## 3. Dibujar las líneas y unir el Grafo
	#for con in conexiones:
		#var id_1 = int(con.x)
		#var id_2 = int(con.y)
		#
		## Verificamos que ambos nodos existan antes de conectarlos
		#if mapa_nodos.has(id_1) and mapa_nodos.has(id_2):
			#var nodo_1 = mapa_nodos[id_1]
			#var nodo_2 = mapa_nodos[id_2]
			#
			## Enlace lógico (Matemático)
			#nodo_1.vecinos.append(nodo_2)
			#nodo_2.vecinos.append(nodo_1)
			#
			## Enlace visual (Dibujo)
			#dibujar_linea_conexion(nodo_1.position, nodo_2.position)


# ================= PARSEADORES (TRADUCTORES) =================

func cargar_desde_resource(data: NivelData) -> void:
	# El Resource ya tiene el tipado fuerte, se lo pasamos directo al constructor
	construir_tablero(data.posiciones_nodos, data.conexiones, data.mapa_personajes, data.imagenes_personajes)

func cargar_desde_json(ruta: String) -> void:
	var archivo = FileAccess.open(ruta, FileAccess.READ)
	if not archivo: 
		push_error("No se pudo abrir el JSON")
		return
		
	var json = JSON.new()
	if json.parse(archivo.get_as_text()) == OK:
		var data = json.data
		
		# Variables temporales para traducir el texto a tipos nativos
		var posiciones: Array[Vector2] = []
		var conexiones: Array[Vector2] = []
		var mapa_pj: Dictionary = {}
		
		# 1. Extraemos las posiciones
		if data.has("nodos"):
			for nodo_data in data["nodos"]:
				# Suponiendo que el JSON los tiene ordenados desde el id 0 en adelante
				var vec = Vector2(float(nodo_data["posicion"]["x"]), float(nodo_data["posicion"]["y"]))
				posiciones.append(vec)
				
		# 2. Extraemos las conexiones
		if data.has("conexiones"):
			for c in data["conexiones"]:
				# El JSON guarda arreglos de números [0, 1]. Los convertimos a Vector2(0, 1) para estandarizar
				conexiones.append(Vector2(c[0], c[1]))
				
		# 3. Extraemos el mapa de personajes
		if data.has("personajes"):
			for p in data["personajes"]:
				mapa_pj[int(p["id_nodo"])] = p["tipo"]
				
		# Llamamos al constructor usando el diccionario de imágenes de emergencia
		construir_tablero(posiciones, conexiones, mapa_pj, imagenes_json_fallback)

# ================= CONSTRUCTOR ÚNICO =================

func construir_tablero(posiciones: Array[Vector2], conexiones: Array[Vector2], mapa_pj: Dictionary, imagenes_pj: Dictionary) -> void:
	
	# 1. y 2. Instanciar Nodos y Asignar Personajes
	for i in range(posiciones.size()):
		var nuevo_nodo = escena_nodo.instantiate()
		nuevo_nodo.id = i
		nuevo_nodo.position = posiciones[i] * TAM_CELDA
		
		# Revisamos si el diccionario de personajes tiene registrado este ID
		if mapa_pj.has(i):
			var tipo_personaje = mapa_pj[i]
			
			# Creamos la ficha de datos (suponiendo que usas el sistema ECS que hablamos)
			var datos = PersonajeDatos.new()
			datos.nombre = tipo_personaje
			
			# Si el diccionario de imágenes tiene la foto, se la aplicamos
			if imagenes_pj.has(tipo_personaje):
				datos.textura_visual = imagenes_pj[tipo_personaje]
				
			nuevo_nodo.personaje_actual = datos
			# Aquí el nodo debería asignar la textura a su Sprite2D interno
			nuevo_nodo.actualizar_visual() 
			
		add_child(nuevo_nodo)
		mapa_nodos[i] = nuevo_nodo

	# 3. Dibujar las líneas y unir el Grafo
	for con in conexiones:
		var id_1 = int(con.x)
		var id_2 = int(con.y)
		
		# Verificamos que ambos nodos existan antes de conectarlos
		if mapa_nodos.has(id_1) and mapa_nodos.has(id_2):
			var nodo_1 = mapa_nodos[id_1]
			var nodo_2 = mapa_nodos[id_2]
			
			# Enlace lógico (Matemático)
			nodo_1.vecinos.append(nodo_2)
			nodo_2.vecinos.append(nodo_1)
			
			# Enlace visual (Dibujo)
			dibujar_linea_conexion(nodo_1.position, nodo_2.position)

# Función de apoyo para no ensuciar el constructor
func dibujar_linea_conexion(pos1: Vector2, pos2: Vector2) -> void:
	var linea = Line2D.new()
	linea.add_point(pos1)
	linea.add_point(pos2)
	linea.width = 4.0
	linea.default_color = Color(0.6, 0.6, 0.6)
	linea.z_index = -1 # Para que la línea quede por detrás de los círculos
	add_child(linea)
