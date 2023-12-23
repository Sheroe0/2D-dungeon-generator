extends TileMap

var file_path = "user://TileMap_source.dat"

#func _ready():
#	position = get_window().size/2

func check_valid_object_name(object_name):
	if !object_name:
		$"../Interfase/Panel".visible = true
		$"../Interfase/Panel/VBoxContainer/Label".text = "Не коректный ввод"
		return false
	if object_name.contains("\\") or object_name.contains("\'") or object_name.contains("\"") or object_name.contains(";"):
		$"../Interfase/Panel".visible = true
		$"../Interfase/Panel/VBoxContainer/Label".text = "Недопустимые знаки"
		return false
	return true
	self.queue_free()

func check_object_name_exists(object_name):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if len(line) > 0 and line.split(",")[0] == object_name:
				file.close()
				$"../Interfase/Panel".visible = true
				$"../Interfase/Panel/VBoxContainer/Label".text = "Такое имя присета уже существует"
				return true
		file.close()
	return false

func save(rectangle, object_name):
	if check_object_name_exists(object_name): return
	if !check_valid_object_name(object_name): return
	var x = abs( rectangle[1].x - rectangle[0].x )+1
	var y = abs( rectangle[1].y - rectangle[0].y )+1
	var tile_pos = Vector2.ZERO
	var tpy = rectangle[0].y
	var tpx = rectangle[0].x
	var source_arr = []
	
	if rectangle[0].x<rectangle[1].x: tile_pos.x = rectangle[0].x
	else: 
		tile_pos.x = rectangle[1].x
		tpx = rectangle[1].x
	if rectangle[0].y<rectangle[1].y: tile_pos.y = rectangle[0].y
	else: 
		tile_pos.y = rectangle[1].y
		tpy = rectangle[1].y
	
	for i in x:
		for j in y:
			var id = get_cell_source_id(0,tile_pos)
			if id !=-1:
				source_arr.append( [id,tile_pos - Vector2(tpx,tpy)] )
			tile_pos.y+=1
		tile_pos.y = tpy
		tile_pos.x+=1
	
	
	if source_arr.size() > 0:
		source_arr.append(Vector2i(x,y))
		source_arr.append(object_name)
		
		var file = FileAccess.open(file_path, FileAccess.READ_WRITE) # Открытие файла для записи, если он существует
		if !file:
			file = FileAccess.open(file_path, FileAccess.WRITE)
		file.seek_end()
		
		var s = source_arr.size()
		while s>0:
			s-=1
			file.store_string(str(source_arr[s])+";")
			source_arr.remove_at(s)
		file.store_string("\n")
		file.close() # Закрываем файл
		
		$"../Interfase/Panel".visible = true
		$"../Interfase/Panel/VBoxContainer/Label".text = "Сохранено :)"
	else:
		$"../Interfase/Panel".visible = true
		$"../Interfase/Panel/VBoxContainer/Label".text = "Нечего сохранять, лол :)"
