extends Node

# ==========================================
# IDENTIDAD DEL JUGADOR
# ==========================================

var personaje = ""
var sexo = ""
var region = ""


# ==========================================
# ACTIVIDAD PRODUCTIVA
# ==========================================

var actividad = ""
var cultivo = ""

var ciclo_actual = 0
var produccion = 0


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

	salud_financiera = 100
	productividad = 100
	resiliencia = 0

	evento_actual = ""

	minidesafios_completados = 0

	logros.clear()

	sellos = 0
