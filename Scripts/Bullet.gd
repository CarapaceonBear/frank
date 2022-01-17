extends Area

var bullet_velocity = 30
var g = Vector3.DOWN * 5

var velocity = Vector3.ZERO

var bullet_damage = 50

func _ready():
	set_as_toplevel(true)
	yield(get_tree().create_timer(.8), "timeout")
	queue_free()

func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

func _on_Area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.health -= bullet_damage
		queue_free()
	else:
		queue_free()
