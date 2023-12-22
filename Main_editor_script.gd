extends TileMap


func save(rectangle, object_name):
	var x = abs( rectangle[1].x - rectangle[0].x )
	var y = abs( rectangle[1].y - rectangle[0].y )
	var tile_pos = Vector2.ZERO
	var tpy = rectangle[0].y
	var source_arr = [object_name,Vector2i(x,y)]
	
	if rectangle[0].x<rectangle[1].x: tile_pos.x = rectangle[0].x
	else: tile_pos.x = rectangle[1].x
	if rectangle[0].y<rectangle[1].y: tile_pos.y = rectangle[0].y
	else: 
		tile_pos.y = rectangle[1].y
		tpy = rectangle[1].y
	
	if x<1:x=1
	if y<1:y=1
	for i in x:
		for j in y:
			source_arr.append( [get_cell_source_id(0,tile_pos),tile_pos] )
			tile_pos.y+=1
		tile_pos.y = tpy
		tile_pos.x+=1
	print(rectangle)
	for i in source_arr.size():
		print(source_arr[i])
	
	var file_path = "user://TileMap_source.dat"
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE) # Открытие файла для записи, если он существует
	if !file:
		file = FileAccess.open(file_path, FileAccess.WRITE)
	file.seek_end()
	file.store_string(str(source_arr)+"\n")
	file.close() # Закрываем файл
