extends ImmediateGeometry

var start
var end


func draw_raycast(a, b, colour):
	start = a
	end = b
	
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	match(colour):
		"blue":
			set_color(Color.blue)
		"red":
			set_color(Color.red)

	add_vertex(start)
	add_vertex(end)
	
	end()

