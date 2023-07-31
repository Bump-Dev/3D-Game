extends StaticBody3D

var open := false
var tweening := false

func interact():
	var tween := create_tween()
	tween.finished.connect(_tween_all_completed)
	if !tweening:
		if !open:
			tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y-90, 0.5).from_current().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			tweening = true
		else:
			tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y+90, 0.5).from_current().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			tweening = true

func _tween_all_completed():
	open = !open
	tweening = false
