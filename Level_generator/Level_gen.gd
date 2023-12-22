extends Node

#избавиться от MAIN

#переменные которые вы можете настроить под себя:
#ВАЖНО! RSC должно быть нечётным для чёткого определения центра комнаты
const RSC = 21 #количество клеток в комнате room_size_cell
const SIZE = 32 #пикселей в тайле
const ENEMY_SPAWN_CHANCE = 2 #процентов
const PRES_DILD_SPAWN_CHANCE = 100 # шанс спавна объекта в центре
const PASSAGE_SIZE = 7 # размер прохода между чанками
var room_count = 20 #этот параметр не отражает финальное колличество комнат.
#трейнсеты
const WALL1_ID = 2 #основные стены в тайлмапе
const WALL2_ID = 1 #хз как описать. ну допустим дополнительные тайлы стены
const FLOR_ID = 0 #тайлы пола
const TRAIN_SET_ROOM = 0

###################################
## шансы появления редких комнат ##
###################################

var chance_no_common = 50        #шанс появления не комон румы

#сумма всех шансов ниже не должна привышать 100
var chance_spavn_event_room = 0  #шанс появления ивентовой румы
var chance_random_room = 0       #шанс появления рандомно составленной румы
								#шанс появления большой румы 100 минус шансы выше

############################
## шансы типов big комнат ##
############################

#сумма всех шансов ниже не должна привышать 100
var chance_double_room = 40       #шанс появления двойной комнаты
var chance_g_room = 40           #шанс появления Г комнаты
								#шанс появления квадратной румы 100 минус шансы выше

#переменные заложенные в основу. трогать не стоит
var double_room_pattern = [[Vector2(0,0),Vector2(0,1)],[Vector2(0,0),Vector2(0,-1)],
						[Vector2(0,0),Vector2(1,0)],[Vector2(0,0),Vector2(-1,0)]]
var g_room_pattern = [[Vector2(0,0),Vector2(0,1),Vector2(1,1)],
					[Vector2(0,0),Vector2(0,1),Vector2(-1,1)],
					[Vector2(0,0),Vector2(0,-1),Vector2(-1,-1)],
					[Vector2(0,0),Vector2(0,-1),Vector2(1,-1)],
					[Vector2(0,0),Vector2(1,0),Vector2(1,1)],
					[Vector2(0,0),Vector2(1,0),Vector2(1,-1)],
					[Vector2(0,0),Vector2(-1,0),Vector2(-1,-1)],
					[Vector2(0,0),Vector2(-1,0),Vector2(-1,1)],
					[Vector2(0,0),Vector2(1,0),Vector2(0,1)],
					[Vector2(0,0),Vector2(-1,0),Vector2(0,-1)],
					[Vector2(0,0),Vector2(1,0),Vector2(0,-1)],
					[Vector2(0,0),Vector2(-1,0),Vector2(0,-1)]]
var square_room_pattern = [[Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)],
						[Vector2(0,0),Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1)],
						[Vector2(0,0),Vector2(1,0),Vector2(1,-1),Vector2(0,-1)],
						[Vector2(0,0),Vector2(-1,0),Vector2(-1,1),Vector2(0,1)],]
var centr:int = int(floor(RSC/2.0))
#var enemy = preload("res://scens/Enemys/Slime/TestBrain.tscn")
var enemy_count = 0
var enemy_name
var one_shot = true
var rng = RandomNumberGenerator.new()
var VARIANT
var t_map = TileMap.new()


var dict_r = {}
var cells_terrains = {}
var room_pos : Array[Vector2] =  []


func _ready():
	t_map.tile_set = load("res://Level_generator/Main_tile_set.tres")
	generate_level()
	#отладочные принты
	for i in dict_r:
		var child = Label.new()  # создание нового узла метки
		add_child(child)  # добавление узла в текущий узел
		child.position = dict_r[i]["Pos"] * RSC * SIZE
		child.text = str(i) +"  "+ str(dict_r[i]["Type"]) # установка текста метки
		print(i,": Pos: ",dict_r[i]["Pos"],"\n")
		print("    Type: ",dict_r[i]["Type"],"\n")
		print("    Chunks: ",dict_r[i]["Chunks"],"\n")
		print("    Blocked: ",dict_r[i]["Blocked"],"\n")
		print("    Enter: ",dict_r[i]["Enter"],"\n")
		print("    Corners: ",dict_r[i]["Corners"],"\n")

################################################################################################
# Главная функция вызывающая поочерёдно функции генерирующие уровень 
################################################################################################
func generate_level():
	#рандомный шагатель создаюший уровень
	random_step(room_count)
	#начальное заполнение информации о комнате dict_r
	for i in room_count:
		initial_filling(i)
	#выбор типа комнаты если не заблокирована
	for i in room_count:
		if !dict_r[i]["Blocked"] and chance_no_common > rng.randi_range(0,100):
			choosing_type_room(i)
	#добавление параметра Enter в словарь информации о комнате
	for i in room_count:
		dict_r[i]["Enter"] = [0,0,0,0]
	#объединяем комнаты в дерево
	arrange_outputs_and_inputs( build_tree() )
	#собираем чанки из тайлов
	for i in dict_r:
		create_chunk(i)
		t_map.set_cells_terrain_connect(0,dict_r[i]["Flor_tile"],0,0,false)
		t_map.set_cells_terrain_connect(0,dict_r[i]["Wall1_tile"],0,1,false)
		t_map.set_cells_terrain_connect(0,dict_r[i]["Wall2_tile"],0,2,false)
	#делаем проходы между чанками
	for i in dict_r:
		add_passages_between_chunks(i)
	#делаем проходы между комнатами
	for i in dict_r:
		add_passages_between_rooms(i)
		for element in dict_r[i]["Passages"]:
			if dict_r[i]["Passages_wall1"].has(element):
				dict_r[i]["Passages_wall1"].erase(element)
		t_map.set_cells_terrain_connect(0,dict_r[i]["Passages_wall1"],0,1,false)
		t_map.set_cells_terrain_connect(0,dict_r[i]["Passages"],0,0,false)

	
	
	add_child(t_map)

################################################################################################
#рандомный шагатель создаюший уровень                                                          
#получает на вход колличестко комнат для генерации и заполняет глобальный вектор позиций комнат
################################################################################################
func random_step(rc):
	var y :int = 0
	var x :int = 0
	while room_pos.size()<rc:
		y += rng.randi_range(-1,1)
		if !room_pos.has(Vector2(x,y)):
			room_pos.append(Vector2(x,y))
		else:
			x += rng.randi_range(-1,1)
			if !room_pos.has(Vector2(x,y)):
				room_pos.append(Vector2(x,y))

################################################################################################
# стартовое заполнение глобального словаря комнаты, содержащего 100% информации о ней
# принимет на вход id комнаты и заблокирована ли она для изменений
################################################################################################
func initial_filling(i,blocked = false):
	dict_r[i] = {
		"Pos" = room_pos[i],
		"Type" = "Common",
		"Chunks" = [Vector2(0,0)],
		"Blocked" = blocked,
	}
#	dict_r[i]["Enter"] = [0,0,0,0],
################################################################################################
# определение типа комнаты на основе глобальных шансов. принимает на вход id румы
################################################################################################
func choosing_type_room(i):
	var chance = rng.randi_range(0,100)
	var pos = dict_r[i]["Pos"]
	#это эвент румы
	if chance < chance_spavn_event_room:                       
		pass
	#это рандомные румы
	elif chance < chance_random_room + chance_spavn_event_room:
		pass
	#это биг румы
	else:
		big_room_creator(i)

################################################################################################
# функция для генерации комнат состоящих из нескольких чанков. создаётся по заданому пресету.
# возможно расширение функционала пользователем. например вы можете добавить Т румы
################################################################################################
func big_room_creator(i):
	var pos = dict_r[i]["Pos"]
	var chance = rng.randi_range(0,100)
	#это даблрумы
	if chance < chance_double_room and check_validity_placement(double_room_pattern,pos):
		for v in VARIANT:
			create_auxiliary_room(v+pos)
		dict_r[i]["Type"] = "double"
		dict_r[i]["Chunks"] = VARIANT
	#это г румы
	elif chance < chance_double_room + chance_g_room and check_validity_placement(g_room_pattern,pos):
		for v in VARIANT:
			create_auxiliary_room(v+pos)
		dict_r[i]["Type"] = "G room"
		dict_r[i]["Chunks"] = VARIANT
	#это квадрат
	elif check_validity_placement(square_room_pattern,pos):
		for v in VARIANT:
			create_auxiliary_room(v+pos)
		dict_r[i]["Type"] = "Sqare"
		dict_r[i]["Chunks"] = VARIANT
	else:
		dict_r[i]["Blocked"] = true
		dict_r[i]["Chunks"] = [Vector2(0,0)]

################################################################################################
# функция определяющая какой из пресетов подходит для создания комнаты.
# возвращает тру если есть пресет подходящий под окружение комнаты.
# так же задаёт глобальную переменную VARIANT в которой содержится подходящий пресет румы.
################################################################################################
func check_validity_placement(pattern,pos):
	pattern.shuffle()
	var found = true # флаг
	for variant in pattern:
		for i in variant:
			if room_pos.has(pos + i):
				if dict_r[room_pos.find(pos + i)]["Blocked"]:
					found = false  # установка флага в true
					break  # выход из внутреннего цикла
		if found:  # проверка флага
			VARIANT = variant
			return true
		found = true
		# если флаг не установлен, цикл продолжается
	return false

################################################################################################
# создаёт новый чанк, если его нет в масиве позиций чанков или редактирует существующий.
# задаёт значение чанка -1, обозначая принадлежность к большой комнате и блокирует его.
# на вход принимает позицию чанка
################################################################################################
func create_auxiliary_room(p):
	if !room_pos.has(p):
		room_pos.append(p)
		room_count += 1
		initial_filling(room_pos.size()-1, true)
	var j = room_pos.find(p)
	if dict_r[j]["Type"]!="-1" and dict_r[j]["Type"]!="Common":
		print("ЗАМЕНА СУЩЕСТВЕННОГО ТИПА КОМНАТЫ",p)
	dict_r[j]["Type"] = "-1"
	dict_r[j]["Blocked"] = true

################################################################################################
# Функция для проверки, является ли путь между двумя точками диагональным
# принимает на вход две точки
# возвращает тру если не диагональные
################################################################################################
func is_diagonal(p1, p2):
	return abs(p1.x - p2.x) == 1 and abs(p1.y - p2.y) == 1

################################################################################################
# Функция для поиска соседей точки
# принимает на вход точку и список всех точек
################################################################################################
func get_neighbors(point,rp):
	var neighbors = []
	for p in rp:
		if p != point and not is_diagonal(p, point) and abs(p.x - point.x) <= 1 and abs(p.y - point.y) <= 1:
			neighbors.append(p)
	return neighbors

################################################################################################
# Функция для построения дерева с помощью алгоритма поиска в ширину (BFS)
################################################################################################
func build_tree():
	var rp = room_pos.duplicate()
	var tree = {}
	var queue = []
	var visited = []
	
	# Добавляем первую точку в очередь
	queue.append(rp[0])
	visited.append(rp[0])

	# Пока очередь не пуста
	while queue.size() > 0:
		# Извлекаем первую точку из очереди
		var current = queue.pop_front()

		# Получаем соседей текущей точки
		var neighbors = get_neighbors(current,rp)

		# Добавляем соседей в дерево и в очередь
		for neighbor in neighbors:
			if not visited.has(neighbor):
				tree[neighbor] = current
				queue.append(neighbor)
				visited.append(neighbor)

	return tree

################################################################################################
# функция интерпритирующая дерево построенное BFS в удобный для использования масив данных
# принимает на вход дерево чанков
################################################################################################
func arrange_outputs_and_inputs(tree):
	var keys = tree.keys()
	var values = tree.values()
	
	for i in tree.size():
		var key = keys[i]
		var value = values[i]
		var i_buf = room_pos.find(key)
		var j_buf = room_pos.find(value)
		#важно помнить что первое значение это проход направо, второе проход вниз и тд
		if key.y > value.y:
			dict_r[i_buf]["Enter"][3] = 1
			dict_r[j_buf]["Enter"][1] = 1
		elif key.y < value.y:
			dict_r[i_buf]["Enter"][1] = 1
			dict_r[j_buf]["Enter"][3] = 1
		elif key.x > value.x:
			dict_r[i_buf]["Enter"][2] = 1
			dict_r[j_buf]["Enter"][0] = 1
		else:
			dict_r[i_buf]["Enter"][0] = 1
			dict_r[j_buf]["Enter"][2] = 1

################################################################################################
# генерация тайлов чанка
# принимает на вход индекс чанка
################################################################################################
func create_chunk(index):
	var pos = Vector2i(dict_r[index]["Pos"].x,dict_r[index]["Pos"].y) * Vector2i(RSC,RSC)
	var array_Wall1_pos: Array[Vector2i] = []
	var array_Wall2_pos: Array[Vector2i] = []
	var array_flor_pos: Array[Vector2i] = []
	var lu = Vector2i.ZERO #лево верх
	var ld = Vector2i.ZERO #лево низ
	var ru = Vector2i.ZERO #право верх
	var rd = Vector2i.ZERO #право низ
	lu.x = rng.randi_range(3, centr -3) 
	ld.x = rng.randi_range(3, centr -3) 
	ru.x = rng.randi_range(centr + 3, RSC -3) 
	rd.x = rng.randi_range(centr + 3, RSC -3) 
	lu.y = rng.randi_range(3, centr - 3)
	ld.y = rng.randi_range(centr + 3, RSC - 3)
	ru.y = rng.randi_range(3, centr - 3)
	rd.y = rng.randi_range(centr + 3, RSC - 3)
	var corners = [lu,ld,ru,rd]
	for i in RSC:
		for j in RSC:
			var tilePos = Vector2i(i,j) + pos
			if (i>=lu.x and j>=lu.y) and (i<centr and j<centr):
				array_flor_pos.append(tilePos)
			elif (i<=ru.x and j>=ru.y) and (i>=centr and j<=centr):
				array_flor_pos.append(tilePos)
			elif (i>=ld.x and j<=ld.y) and (i<=centr and j>=centr):
				array_flor_pos.append(tilePos)
			elif (i<=rd.x and j<=rd.y) and (i>centr and j>centr):
				array_flor_pos.append(tilePos)
			else:
				array_Wall1_pos.append(tilePos)
	#вторичная генерация стен
	var point = lu.x
	while point < centr:
		array_Wall1_pos.erase(Vector2i(point,lu.y-1) + pos)
		array_Wall2_pos.append(Vector2i(point,lu.y-1) + pos)
		point += 1
	point = ru.x
	while point >= centr:
		array_Wall1_pos.erase(Vector2i(point,ru.y-1) + pos)
		array_Wall2_pos.append(Vector2i(point,ru.y-1) + pos)
		point -= 1
	point = ld.x
	while array_Wall1_pos.has(Vector2i(point,centr-1)+ pos):
		array_Wall1_pos.erase(Vector2i(point,centr) + pos)
		array_Wall2_pos.append(Vector2i(point,centr) + pos)
		point += 1
	point = rd.x
	while array_Wall1_pos.has(Vector2i(point,centr-1)+ pos):
		array_Wall1_pos.erase(Vector2i(point,centr) + pos)
		array_Wall2_pos.append(Vector2i(point,centr) + pos)
		point -= 1
	
	dict_r[index]["Flor_tile"]=array_flor_pos
	dict_r[index]["Wall1_tile"]=array_Wall2_pos
	dict_r[index]["Wall2_tile"] =array_Wall1_pos
	dict_r[index]["Corners"]=corners

################################################################################################
# создание проходов между чанками одной комнаты
# принимает на вход индекс чанка
################################################################################################
func add_passages_between_chunks(i):
	dict_r[i]["Passages"] = []
	dict_r[i]["Passages_wall1"] = []
	for ch in dict_r[i]["Chunks"]:
		if dict_r[i]["Chunks"].has(ch+Vector2(1,0)):
			var index = room_pos.find(dict_r[i]["Pos"]+ch)
			dict_r[index]["Enter"][0]=0
			index = room_pos.find(dict_r[i]["Pos"]+ch+Vector2(1,0))
			dict_r[index]["Enter"][2]=0
			var pos:Vector2i = (dict_r[i]["Pos"] + ch)*RSC
			var variable = centr-int(PASSAGE_SIZE/2+1)
			for ord_x in RSC:
				if t_map.get_cell_source_id(0,Vector2i(centr+ord_x,variable-1)+pos)==2:
					dict_r[i]["Passages_wall1"].append(Vector2i(centr+ord_x,variable-1)+pos)
				for ord_y in PASSAGE_SIZE:
					dict_r[i]["Passages"].append(Vector2i(centr+ord_x,ord_y+variable)+pos)
		if dict_r[i]["Chunks"].has(ch+Vector2(0,1)):
			var index = room_pos.find(dict_r[i]["Pos"]+ch)
			dict_r[index]["Enter"][1]=0
			index = room_pos.find(dict_r[i]["Pos"]+ch+Vector2(0,1))
			dict_r[index]["Enter"][3]=0
			var pos:Vector2i = (dict_r[i]["Pos"] + ch)*RSC
			var variable = centr-int(PASSAGE_SIZE/2)
			for ord_x in PASSAGE_SIZE:
				for ord_y in RSC:
					dict_r[i]["Passages"].append(Vector2i(ord_x+variable,centr+ord_y)+pos)

################################################################################################
# создание проходов между комнатами
# принимает на вход индекс чанка
################################################################################################
func add_passages_between_rooms(i):
	if dict_r[i]["Enter"][0] == 1:
		var pos: Vector2i = dict_r[i]["Pos"] * RSC + Vector2(centr,centr)
		for j in RSC:
			pos.x += 1
			dict_r[i]["Passages"].append(pos)
			if t_map.get_cell_source_id(0,Vector2i(pos.x,pos.y-1))==2:
				dict_r[i]["Passages_wall1"].append(Vector2i(pos.x,pos.y-1))
	if dict_r[i]["Enter"][1] == 1:
		var pos: Vector2i = dict_r[i]["Pos"] * RSC + Vector2(centr,centr)
		for j in RSC:
			pos.y += 1
			dict_r[i]["Passages"].append(pos)
