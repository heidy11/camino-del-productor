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
const MAX_CICLOS = 3


# ==========================================
# ECONOMÍA
# ==========================================

var monedas = 0

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

	monedas = 0

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

	minidesafios_completados = 0

	logros.clear()

	sellos = 0


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
