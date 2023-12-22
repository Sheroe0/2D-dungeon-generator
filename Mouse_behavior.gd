extends Control

var mouse_pos
const pixels_in_tile = 32
const half_pixels_in_tile = Vector2i (16,16)
var selected_cell
var sc_buf
var rectangle_buf = []
var grab = false
var highlighting = false

func _process(delta):
	queue_redraw()
	if Input.is_action_pressed("ui_cancel"):
		highlighting = false
		rectangle_buf.clear()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if !highlighting:
			if !grab:
				rectangle_buf.clear()
				sc_buf = selected_cell
			grab = true
			highlighting = true
	else:
		if grab:
			rectangle_buf = [sc_buf,selected_cell]
		grab = false
	
	mouse_pos = get_global_mouse_position()
	selected_cell = Vector2i(mouse_pos / pixels_in_tile)

	if !grab:
		$red.global_position = selected_cell * 32 + half_pixels_in_tile


func _draw():
	var start
	var end
	var size
	if grab:
		start = Vector2(min(sc_buf.x, selected_cell.x), min(sc_buf.y, selected_cell.y)) * pixels_in_tile
		end = Vector2(max(sc_buf.x, selected_cell.x), max(sc_buf.y, selected_cell.y)) * pixels_in_tile
		size = end - start + Vector2(pixels_in_tile, pixels_in_tile)
		draw_rect(Rect2(start, size), Color(1, 0, 0, 0.5))
	else:
		if rectangle_buf.size() == 2:
			var sc_buf = rectangle_buf[0]
			var selected_cell = rectangle_buf[1]
			start = Vector2(min(sc_buf.x, selected_cell.x), min(sc_buf.y, selected_cell.y)) * pixels_in_tile
			end = Vector2(max(sc_buf.x, selected_cell.x), max(sc_buf.y, selected_cell.y)) * pixels_in_tile
			size = end - start + Vector2(pixels_in_tile, pixels_in_tile)
			draw_rect(Rect2(start, size), Color(1, 0, 0, 0.5))

