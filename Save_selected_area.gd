extends Button

func _on_pressed():
	var rb = $"../../../../../../Mouse_behavior".rectangle_buf.duplicate()
	if rb.size()>0 and abs(rb[1].x-rb[0].x)>1 and abs(rb[1].y-rb[0].y)>1:
		rb[0]+=Vector2i(1,1)
		rb[1]-=Vector2i(1,1)
		var object_name = $"../LineEdit".text
		$"../../../../../../MainTileMap".save(rb,object_name)
	else:
		$"../../../../../Panel".visible = true
		$"../../../../../Panel/VBoxContainer/Label".text = "Область не выбрана или мала"
