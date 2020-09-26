extends Spatial

func _process(delta):
	$Area.global_transform.origin.x += delta
	for body in $Area.get_overlapping_bodies():
		print(body)

func _on_Area_area_entered(area):
	print("something")


func _on_Area_area_exited(area):
	print("something")

func _on_Area_area_shape_entered(area_id, area, area_shape, self_shape):
	print("something")

func _on_Area_area_shape_exited(area_id, area, area_shape, self_shape):
	print("something")

func _on_Area_body_entered(body):
	print("something")

func _on_Area_body_exited(body):
	print("something")

func _on_Area_body_shape_entered(body_id, body, body_shape, area_shape):
	print("something")

func _on_Area_body_shape_exited(body_id, body, body_shape, area_shape):
	print("something")
