extends Button

var file_path = "user://TileMap_source.dat"

func _on_pressed():
	var object_name = $"../LineEdit".text
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			var sours_arr = line.split(";")
			print("sdas")
			if len(line) > 0 and sours_arr[0] == object_name:
				file.close()
				var s = sours_arr.size()-1
				var new_sours_arr = []
				new_sours_arr.append(sours_arr[0])
				new_sours_arr.append(reform(sours_arr[1]))
				while s>2:
					s-=1
					var sours_id = sours_arr[s][1]
					sours_arr[s] = sours_arr[s].erase(0,4)
					new_sours_arr.append([sours_id,reform(sours_arr[s])])
				
				var woll2: Array[Vector2i] = []
				var flor = []
				var woll1 = []
				for i in new_sours_arr.size() - 2:
					var j = i+2
					if new_sours_arr[j][0] == "2":
						woll2.append(new_sours_arr[j][1])
					elif new_sours_arr[j][0] == "0":
						flor.append(new_sours_arr[j][1])
					else:
						woll1.append(new_sours_arr[j][1])
				$"../../../../../../MainTileMap".clear()
				$"../../../../../../MainTileMap".set_cells_terrain_connect(0,woll2,0,2,false)
				$"../../../../../../MainTileMap".set_cells_terrain_connect(0,woll1,0,1,false)
				$"../../../../../../MainTileMap".set_cells_terrain_connect(0,flor,0,0,false)
				$"../../../../../Panel".visible = true
				$"../../../../../Panel/VBoxContainer/Label".text = "Загружен: " + object_name
				return
		$"../../../../../Panel".visible = true
		$"../../../../../Panel/VBoxContainer/Label".text = "Нет такого: " + object_name
		file.close()

func reform(re):
	return Vector2i (int(re.split(",")[0]), int(re.split(",")[1]))
