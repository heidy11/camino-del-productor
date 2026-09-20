extends Node

# ==========================================
# IDENTIDAD DEL JUGADOR
# ==========================================

var personaje = ""
var sexo = ""
var region = ""
var personaje_sprite = ""


# ==========================================
# ACTIVIDAD PRODUCTIVA
# ==========================================

var actividad = ""
var cultivo = ""

var ciclo_actual = 0
var produccion = 0
const MAX_CICLOS = 2


# ==========================================
# ECONOMÍA
# ==========================================

var monedas = 50

var monedas_obtenidas = 0
var monedas_ahorradas = 0
var monedas_invertidas = 0
var monedas_gastadas = 0


# ==========================================
# FONDO DE EMERGENCIA
# ==========================================

var fondo_emergencia = 0


# ==========================================
# META FINANCIERA
# ==========================================

var meta_ahorro = 100
var proteccion_activa = false


# ==========================================
# INDICADORES DEL JUGADOR
# ==========================================

var salud_financiera = 100
var productividad = 100
var resiliencia = 0


# ==========================================
# EVENTOS
# ==========================================

var evento_actual = ""
var historial_clima = []
var veces_carpa_comprada = 0


# ==========================================
# MINI DESAFÍOS
# ==========================================

var minidesafios_completados = 0


# ==========================================
# LOGROS
# ==========================================

var logros = []

var sellos = 0


# ==========================================
# PUNTOS EXTRA (DECISIONES FINANCIERAS)
# ==========================================

var puntos_ahorro = 0
var puntos_invertir = 0
var puntos_gastar = 0

var veces_herramientas = 0
var veces_semillas = 0
var veces_dulces = 0
var veces_videojuegos = 0


# ==========================================
# NUEVA PARTIDA
# ==========================================

func nueva_partida():
	personaje = ""
	sexo = ""
	region = ""
	personaje_sprite = ""

	actividad = ""
	cultivo = ""

	ciclo_actual = 0
	produccion = 0

	monedas = 50

	monedas_obtenidas = 0
	monedas_ahorradas = 0
	monedas_invertidas = 0
	monedas_gastadas = 0

	fondo_emergencia = 0

	meta_ahorro = 100
	proteccion_activa = false

	salud_financiera = 100
	productividad = 100
	resiliencia = 0

	evento_actual = ""
	historial_clima.clear()
	veces_carpa_comprada = 0

	minidesafios_completados = 0

	logros.clear()

	sellos = 0

	puntos_ahorro = 0
	puntos_invertir = 0
	puntos_gastar = 0

	veces_herramientas = 0
	veces_semillas = 0
	veces_dulces = 0
	veces_videojuegos = 0


# ==========================================
# CAMINO DEL GUARDIÁN
# ==========================================

func otorgar_sello(motivo: String) -> void:
	sellos += 1
	logros.append(motivo)


# ==========================================
# PERFIL FINANCIERO
# ==========================================

func calcular_perfil_financiero() -> String:
	if monedas_ahorradas <= 0 and monedas_invertidas <= 0 and monedas_gastadas <= 0:
		return "Sin definir"

	if monedas_ahorradas >= monedas_invertidas and monedas_ahorradas >= monedas_gastadas:
		return "Ahorrador Responsable"

	if monedas_invertidas >= monedas_ahorradas and monedas_invertidas >= monedas_gastadas:
		return "Inversionista Inteligente"

	if monedas_gastadas > monedas_ahorradas and monedas_gastadas > monedas_invertidas:
		return "Comprador Impulsivo"

	return "Productor Equilibrado"


func meta_alcanzada() -> bool:
	return monedas_ahorradas >= meta_ahorro


func ciclo_final_completado() -> bool:
	return ciclo_actual >= MAX_CICLOS or meta_alcanzada()


# ==========================================
# RESULTADO FINAL (REACCION DEL CONDOR)
# ==========================================

func puntos_extra_total() -> int:
	return puntos_ahorro + puntos_invertir + puntos_gastar


func resultado_final() -> String:
	var ganancia = productividad + puntos_extra_total()

	if ganancia >= 130:
		return "feliz"
	elif ganancia >= 100:
		return "dudoso"
	else:
		return "triste"
