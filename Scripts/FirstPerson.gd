extends KinematicBody

# ----------------------- #
# TO DO LIST
# ----------------------- #
#
# REANIMATE RIFLE AT 70FOV
# RESET CAM FOV TO 70/50
# set up animation signals
# debug whatever is going on with muzzle position
#
# * assault rifle functionality
# * inaccuracy for hip fire
# * barricades
# * learn decal node
# * damage and health, damage indicators
# * buying weapons + opening doors, buying ammo at resupply
# * weapon upgrades
# * melee attack
# * research culling and LOD
# * block out level
# * look into multiplayer
#
# * plan progression and weapons / powerups in detail
# * establish art style
# * concept weapons, location and enemies
# * model assets
# * learn substance painter


# ----------------------- #
#        VARIABLES        #
# ----------------------- #

# variables for movement #
var speed = 1
export var run_speed = 10
var crouch_multiplier = 1
export var crouch_speed = 0.6
var crouch_drop_speed = 8
var sprint_multiplier = 1
export var sprint_speed = 1.8

var default_height = 1.5
var crouch_height = 0.3
var head_bonked = false

export var acceleration = 8
var air_acceleration = 1
var default_acceleration = 1

export var gravity = 20
export var jump = 10
var double_jump = true
export var double_jump_active = false
var full_contact = false
var cant_jump = false
var cant_sprint = false
var cant_reload = false

var direction = Vector3()
var velocity = Vector3()
var movement = Vector3()
var gravity_vector = Vector3()

export var mouse_sensitivity = 0.18
var mouse_mov_x
var mouse_mov_y
export var sway_threshold = 2
export var sway_lerp = 7
export var sway_left : Vector3
export var sway_right : Vector3
export var sway_up : Vector3
export var sway_down : Vector3
export var sway_default : Vector3
var aiming = false
var ads_lerp = 20
export var hand_default_position : Vector3
export var hand_ads_position : Vector3
var fov = {"default": 50, "ads": 40}

# (( variables referring to "gun" pertain to current weapon functionality )) #
# (( variables referring to "current, primary, secondary, sidearm" pertain to stored data for equipped slots )) #
# (( variables referring to "weapon, pistol" pertain to specific kinds of weapons )) #
# variables for current gun funtionality #
var gun_type
var gun_damage = 100
var gun_velocity = 10
var gun_fire_rate = 2
var gun_mag_size = 20
var gun_ammo_max = 100
var gun_reload_speed = 2
var gun_weight = 0
var gun_spread = 0

# variables specific to equipped/held weapons #
var current = 1
var current_mag = 0
var current_ammo = 0
var current_empty = false
var swap_out = 3
var ready_to_fire = true
var reloading = false
var pickup_weapon = 0
var primary = 0
var primary_model
var primary_stats
var primary_mag = 0
var primary_ammo = 0
var primary_empty = false
var secondary = 0
var secondary_model
var secondary_stats
var secondary_mag = 0
var secondary_ammo = 0
var secondary_empty = false
var sidearm = 10
var sidearm_model
var sidearm_stats
var sidearm_mag = 0
var sidearm_ammo = 0
var sidearm_empty = false

# variables for interacting with enemies
var current_location
signal update_location(current_location)
var player_health = 100
var currency = 0

# preloading player components #
onready var head = $Head
onready var camera = $Head/Camera
onready var ground_check = $GroundCheck
onready var player_collision = $CollisionShape
onready var head_bonker = $HeadBonker
onready var aimcast = $Head/Camera/AimCast
onready var shotgun_container = $Head/Camera/ShotgunContainer
onready var muzzle = $Head/Muzzle
onready var projectile = preload("res://scenes/Bullet.tscn")
onready var reach = $Head/Camera/Reach
onready var hand = $Head/Hand
onready var hand_location = $Head/HandLocation
onready var mag_counter = $Head/Camera/Control/MagCounter
onready var ammo_counter = $Head/Camera/Control/AmmoCounter

onready var tracer = $Head/Camera/AimCast/MeshInstance

# preloading weapon assets #
onready var pistol1 = preload("res://scenes/TestGun4.tscn")
onready var pistol1_pos = $Head/HandLocation/Gun4Pos
var pistol1_stats = {"starting_pos": Vector3(0.556, 0.296, -0.775), "ads_pos": Vector3(0.005, 0.635, -0.209), 
					 "type": 1, "damage": 10, "velocity": 0, "fire_rate": 0.4, "mag_size": 12, "ammo": 60, "reload_speed": 1, "weight": 0, "spread": 0}
onready var weapon1 = preload("res://scenes/TestGun1.tscn")
onready var weapon1_pos = $Head/HandLocation/Gun1Pos
var weapon1_stats = {"starting_pos": Vector3(0.471, 0.321, -0.514), "ads_pos": Vector3(0, 0.669, -0.699), 
					 "type": 1, "damage": 50, "velocity": 0, "fire_rate": 3, "mag_size": 6, "ammo": 60, "reload_speed": 1.5, "weight": 1, "spread": 0}
onready var weapon2 = preload("res://scenes/TestGun2.tscn")
onready var weapon2_pos = $Head/HandLocation/Gun2Pos
var weapon2_stats = {"starting_pos": Vector3(0.602, 0.069, -0.821), "ads_pos": Vector3(0, 0.122, -0.745), 
					 "type": 1, "damage": 5, "velocity": 0, "fire_rate": 0.6, "mag_size": 30, "ammo": 120, "reload_speed": 1.5, "weight": 0.5, "spread": 0}
onready var weapon3 = preload("res://scenes/TestGun3.tscn")
onready var weapon3_pos = $Head/HandLocation/Gun3Pos
var weapon3_stats = {"starting_pos": Vector3(0.594, 0.407, -0.91), "ads_pos": Vector3(0, 0.542, -0.952), 
					 "type": 2, "damage": 100, "velocity": 20, "fire_rate": 2, "mag_size": 4, "ammo": 20, "reload_speed": 2, "weight": 5, "spread": 0}
onready var weapon4 = preload("res://scenes/TestGun5.tscn")
onready var weapon4_pos = $Head/HandLocation/Gun5Pos
var weapon4_stats = {"starting_pos": Vector3(0.533, 0.351, -0.93), "ads_pos": Vector3(0.005, 0.635, -0.209), 
					 "type": 4, "damage": 20, "velocity": 0, "fire_rate": 1, "mag_size": 6, "ammo": 30, "reload_speed": 2, "weight": 2, "spread": 10}
onready var bullet_decal = preload("res://Scenes/BulletDecal.tscn")
onready var ads_pos = $Head/HandLocation/GunADSPos
var bolt_action_stats = {"starting_pos": Vector3(0.249, 0.591, -0.366), "ads_pos": Vector3(0, 0.685, -0.033), 
						 "type": 1, "damage": 80, "velocity": 0, "fire_rate": 1.4, "mag_size": 6, "ammo": 18, "reload_speed": 1.8, "weight": 1, "spread": 0}
onready var bolt_action = preload("res://scenes/bolt_action.tscn")
onready var bolt_action_pos = $Head/HandLocation/BoltActionPos





# ----------------------- #
#        STARTUP          #
# ----------------------- #

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_acceleration = acceleration
	weapon_pickup(sidearm)
	
	randomize()
	for r in shotgun_container.get_children():
		r.cast_to.x = rand_range(gun_spread, -gun_spread)
		r.cast_to.y = rand_range(gun_spread, -gun_spread)
	
	pathfinding_timer()




# ----------------------- #
#    PER FRAME PROCESS    #
# ----------------------- #

# mouse controls #
func _input(event):
	# aiming #
	if event is InputEventMouseMotion:
		mouse_mov_x = -event.relative.x
		mouse_mov_y = -event.relative.y
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
	# weapon scroll : including case where secondary weapon is yet to be filled #
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN: 
			if event.is_pressed() and primary != 0:
				if secondary != 0:
					if event.button_index == BUTTON_WHEEL_UP:
						if current < 3:
							current += 1
						else:
							current = 1
					if event.button_index == BUTTON_WHEEL_DOWN:
						if current > 1:
							current -= 1
						else:
							current = 3
				else:
					if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
						if current == 3:
							current = 1
						else:
							current = 3
				weapon_stats(current)
				weapon_visibility(current)
		# call shoot functions #
		if event.is_action_pressed("fire"):
			if ready_to_fire == true and current_empty == false and reloading == false:
				fire_weapon()
		# ADS #
		if event.is_action_pressed("ads"):
			aiming = true
			cant_jump = true
			cant_sprint = true
			muzzle.global_transform = ads_pos.global_transform
			#tracer.global_transform.origin = muzzle.global_transform.origin
		if event.is_action_released("ads"):
			aiming = false
			cant_jump = false
			cant_sprint = false
			muzzle_position(current)

func _process(delta):
	weapon_select()
	current_ammo(current)
	
	# weapon sway from mouse movement #
	if mouse_mov_x != null:
		if mouse_mov_x > sway_threshold and aiming == false:
			hand.rotation = hand.rotation.linear_interpolate(sway_left, sway_lerp * delta)
		elif mouse_mov_x < -sway_threshold and aiming == false:
			hand.rotation = hand.rotation.linear_interpolate(sway_right, sway_lerp * delta)
		else:
			hand.rotation = hand.rotation.linear_interpolate(sway_default, sway_lerp * delta)
	if mouse_mov_y != null:
		if mouse_mov_y > sway_threshold and aiming == false:
			hand.rotation = hand.rotation.linear_interpolate(sway_up, sway_lerp * delta)
		elif mouse_mov_y < -sway_threshold and aiming == false:
			hand.rotation = hand.rotation.linear_interpolate(sway_down, sway_lerp * delta)
		else:
			hand.rotation = hand.rotation.linear_interpolate(sway_default, sway_lerp * delta)
	# ADS gun placement + FOV
	if Input.is_action_pressed("ads"):
		hand.transform.origin = hand.transform.origin.linear_interpolate(hand_ads_position, ads_lerp * delta)
		camera.fov = lerp(camera.fov, fov["ads"], ads_lerp * delta)
	elif not Input.is_action_pressed("ads"):
		hand.transform.origin = hand.transform.origin.linear_interpolate(hand_default_position, ads_lerp * delta)
		camera.fov = lerp(camera.fov, fov["default"], ads_lerp * delta)

# player movement #
func _physics_process(delta):
	# gravity #
	if ground_check.is_colliding():
		full_contact = true
	else:
		full_contact = false
	if not is_on_floor():
		gravity_vector += Vector3.DOWN * gravity * delta
		acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vector = -get_floor_normal() * gravity
		acceleration = default_acceleration
	else:
		gravity_vector = -get_floor_normal()
		acceleration = default_acceleration
	# jumping #
	if is_on_floor():
		double_jump = false
	if Input.is_action_just_pressed("jump") and cant_jump == false:
		if is_on_floor() or ground_check.is_colliding():
			gravity_vector = Vector3.UP * jump
			double_jump = true
		elif double_jump == true and double_jump_active == true:
			gravity_vector = Vector3.UP * jump
			double_jump = false
	
	# head bonking, using raycast #
	if head_bonker.is_colliding():
		head_bonked = true
		cant_sprint = true
	else:
		head_bonked = false
	if head_bonked:
		gravity_vector.y = -2
	# crouch functionality #
	if Input.is_action_pressed("crouch"):
		player_collision.shape.height -= crouch_drop_speed * delta
		crouch_multiplier = crouch_speed
		cant_jump = true
		cant_sprint = true
	elif not head_bonked:
		player_collision.shape.height += crouch_drop_speed * delta
		cant_jump = false
		crouch_multiplier = 1
	player_collision.shape.height = clamp(player_collision.shape.height, crouch_height, default_height)
	if Input.is_action_just_released("crouch"):
		cant_sprint = false
	
	# sprint functionality #
	if Input.is_action_pressed("sprint") and is_on_floor() and cant_sprint == false:
		sprint_multiplier = sprint_speed
	else:
		sprint_multiplier = 1
	
	# TEMPORARY free mouse #
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	direction = Vector3()
	speed = run_speed - gun_weight
	# basic movement #
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed * sprint_multiplier * crouch_multiplier, acceleration * delta)
	movement.z = velocity.z + gravity_vector.z
	movement.x = velocity.x + gravity_vector.x
	movement.y = gravity_vector.y
	move_and_slide(movement, Vector3.UP)
	# falling movement #
	move_and_slide(gravity_vector, Vector3.UP)
	
	# reloading #
	if Input.is_action_just_pressed("reload"):
		reload(current)

	
	# weapon pickups, detect which weapon "reach" raycast is colliding with #
	if reach.is_colliding():
		if reach.get_collider().get_name() == "TestGun1_depot":
			pickup_weapon = 1
		elif reach.get_collider().get_name() == "TestGun2_depot":
			pickup_weapon = 2
		elif reach.get_collider().get_name() == "TestGun3_depot":
			pickup_weapon = 3
		elif reach.get_collider().get_name() == "TestGun5_depot":
			pickup_weapon = 4
		elif reach.get_collider().get_name() == "bolt_action_depot":
			pickup_weapon = 20
	else:
		pickup_weapon = 0
	# which slot the new weapon goes in, depending on empty slots or held weapon #
	if Input.is_action_just_pressed("use") and pickup_weapon != 0:
		if (current == 1 and secondary != 0) or primary == 0:
			primary = pickup_weapon
			current = 1
		elif current == 2 or secondary == 0:
			secondary = pickup_weapon
			current = 2
		weapon_pickup(current)
		weapon_visibility(current)
		weapon_stats(current)
		ready_to_fire = true


# ----------------------- #
#    CALLED PROCESSES     #
# ----------------------- #

# pathfinding timer#
func pathfinding_timer():
	var n = 1
	while n == 1:
		yield(get_tree().create_timer(.5), "timeout")
		current_location = head.global_transform.origin
		emit_signal("update_location", current_location)


# shooting #
 # drawing from stat dictionary of currently held weapon #
func fire_weapon():
	cant_reload = true
	match(gun_type):
		1:
			#var b = bullet_decal.instance()
			var bullet = get_world().direct_space_state
			var collision = bullet.intersect_ray(muzzle.transform.origin, aimcast.get_collision_point())
			if collision:
				var target = collision.collider
				if target.is_in_group("Enemy"):
					target.lose_health(gun_damage)
				#target.add_child(b)
				#b.global_transform.origin = aimcast.get_collision_point()
				#b.look_at(aimcast.get_collision_point() + aimcast.get_collision_normal(), Vector3.UP)
		# decals require significant rework, look into decal node #
		2:
			var p = projectile.instance()
			muzzle.add_child(p)
			p.bullet_damage = gun_damage
			p.scale = Vector3(2, 2, 2)
			p.transform = muzzle.global_transform
			p.velocity = -p.transform.basis.z * gun_velocity
		# 3 for assault rifles #
		4:
			for r in shotgun_container.get_children():
				var b = bullet_decal.instance()
				r.cast_to.x = rand_range(gun_spread, -gun_spread)
				r.cast_to.y = rand_range(gun_spread, -gun_spread)
				r.force_raycast_update()
				if r.is_colliding():
					if r.get_collider().is_in_group("Enemy"):
						r.get_collider().health -= gun_damage
					r.get_collider().add_child(b)
					b.global_transform.origin = r.get_collision_point()
					b.look_at(r.get_collision_point() + r.get_collision_normal(), Vector3.UP)
				r.enabled = false
	expend_bullet(current)
	
	# play animation
	weapon_animation(current, "fire")
	yield(get_tree().create_timer(.5), "timeout")
	cant_reload = false
	if gun_type == 1 and not reloading:
		weapon_animation(current, "bolt_action")
	
	ready_to_fire = false
	yield(get_tree().create_timer(gun_fire_rate), "timeout")
	ready_to_fire = true
	if current_mag < 1:
		ready_to_fire = false
	if current_ammo < 1:
		cant_reload = true
		if current_mag < 1:
			current_empty = true

func current_ammo(ID):
	match ID:
		1:
			current_mag = gun_mag_size - primary_mag
			current_ammo = gun_ammo_max - primary_ammo
		2:
			current_mag = gun_mag_size - secondary_mag
			current_ammo = gun_ammo_max - secondary_ammo
		3:
			current_mag = gun_mag_size - sidearm_mag
			current_ammo = gun_ammo_max - sidearm_ammo
	mag_counter.text = str(current_mag)
	ammo_counter.text = str(current_ammo)

func expend_bullet(ID):
	match ID:
		1:
			primary_mag += 1
		2:
			secondary_mag += 1
		3:
			sidearm_mag += 1

# weapon stats, established on pickup
# gun_mag_size = 20
# gun_ammo_max = 100

# primary_mag is incremented when expend_bullet() is called - gun mag emptiness
# primary_ammo is increased when reloading - gun total emptiness

# func current_ammo() called every frame
#  current_mag = gun_mag_size - primary_mag ## current mag (displayed) is mag stat - current emptiness
#  current_ammo = gun_ammo_max - primary_ammo ## ditto ammo

func reload(ID):
	if current_mag < gun_mag_size and not cant_reload:
		reloading = true
		weapon_animation(current, "reload")
		yield(get_tree().create_timer(gun_reload_speed), "timeout")
		if reloading == true:
			match ID:
				1:
					if (current_ammo < gun_mag_size):
						primary_ammo += current_ammo
						primary_mag -= current_ammo
					else:
						primary_ammo += primary_mag
						primary_mag = 0
				2:
					if (current_ammo < gun_mag_size):
						secondary_ammo += current_ammo
						secondary_mag -= current_ammo
					else:
						secondary_ammo += secondary_mag
						secondary_mag = 0
				3:
					if (current_ammo < gun_mag_size):
						sidearm_ammo += current_ammo
						sidearm_mag -= current_ammo
					else:
						sidearm_ammo += sidearm_mag
						sidearm_mag = 0
			reloading = false
			ready_to_fire = true


# swapping the instanced model of the chosen weapon #
 # also assigning stat dictionary to relevant slot #
func weapon_pickup(ID):
	match ID:
		1:
			if primary_model != null:
				primary_model.queue_free()
			if pickup_weapon == 1:
				primary_model = weapon1.instance()
				primary_stats = weapon1_stats
			elif pickup_weapon == 2:
				primary_model = weapon2.instance()
				primary_stats = weapon2_stats
			elif pickup_weapon == 3:
				primary_model = weapon3.instance()
				primary_stats = weapon3_stats
			elif pickup_weapon == 4:
				primary_model = weapon4.instance()
				primary_stats = weapon4_stats
			elif pickup_weapon == 20:
				primary_model = bolt_action.instance()
				primary_stats = bolt_action_stats
			hand.add_child(primary_model)
			primary_ammo = 0
			primary_mag = 0
		2:
			if secondary_model != null:
				secondary_model.queue_free()
			if pickup_weapon == 1:
				secondary_model = weapon1.instance()
				secondary_stats = weapon1_stats
			elif pickup_weapon == 2:
				secondary_model = weapon2.instance()
				secondary_stats = weapon2_stats
			elif pickup_weapon == 3:
				secondary_model = weapon3.instance()
				secondary_stats = weapon3_stats
			elif pickup_weapon == 4:
				secondary_model = weapon4.instance()
				secondary_stats = weapon4_stats
			elif pickup_weapon == 20:
				secondary_model = bolt_action.instance()
				secondary_stats = bolt_action_stats
			hand.add_child(secondary_model)
			secondary_ammo = 0
			secondary_mag = 0
		10:
			current = 3
			sidearm_model = pistol1.instance()
			sidearm_stats = pistol1_stats
			hand.add_child(sidearm_model)
			weapon_stats(current)
			weapon_visibility(current)
	current_empty = false

# dictating your currently held weapon #
 # TEMPORARY timing for restricing shooting while drawing weapon, should be a gun stat # 
func weapon_select():
	swap_out = current
	if Input.is_action_just_pressed("weapon1") and primary != 0 and primary_model != null:
		if current != 1:
			ready_to_fire = false
			current = 1
			weapon_visibility(current)
			yield(get_tree().create_timer(.5), "timeout")
			weapon_stats(current)
			ready_to_fire = true
			reloading = false
	elif Input.is_action_just_pressed("weapon2") and secondary != 0 and secondary_model != null:
		if current != 2:
			ready_to_fire = false
			current = 2
			weapon_visibility(current)
			yield(get_tree().create_timer(.5), "timeout")
			weapon_stats(current)
			ready_to_fire = true
			reloading = false
	elif Input.is_action_just_pressed("weapon3") and sidearm != 0 and sidearm_model != null:
		if current != 3:
			ready_to_fire = false
			current = 3
			weapon_visibility(current)
			yield(get_tree().create_timer(.5), "timeout")
			weapon_stats(current)
			ready_to_fire = true
			reloading = false


# switching weapon stats #
 # apply dictionary of stats to the var relating to the weapon slot #
func weapon_stats(ID):
	var temp
	match ID:
		1:
			hand_default_position = primary_stats["starting_pos"]
			hand_ads_position = primary_stats["ads_pos"]
			gun_type = primary_stats["type"]
			gun_damage = primary_stats["damage"]
			gun_velocity = primary_stats["velocity"]
			gun_fire_rate = primary_stats["fire_rate"]
			gun_mag_size = primary_stats["mag_size"]
			gun_ammo_max = primary_stats["ammo"]
			gun_reload_speed = primary_stats["reload_speed"]
			gun_weight = primary_stats["weight"]
			gun_spread = primary_stats["spread"]
		2:
			hand_default_position = secondary_stats["starting_pos"]
			hand_ads_position = secondary_stats["ads_pos"]
			gun_type = secondary_stats["type"]
			gun_damage = secondary_stats["damage"]
			gun_velocity = secondary_stats["velocity"]
			gun_fire_rate = secondary_stats["fire_rate"]
			gun_mag_size = secondary_stats["mag_size"]
			gun_ammo_max = secondary_stats["ammo"]
			gun_reload_speed = secondary_stats["reload_speed"]
			gun_weight = secondary_stats["weight"]
			gun_spread = secondary_stats["spread"]
		3:
			hand_default_position = sidearm_stats["starting_pos"]
			hand_ads_position = sidearm_stats["ads_pos"]
			gun_type = sidearm_stats["type"]
			gun_damage = sidearm_stats["damage"]
			gun_velocity = sidearm_stats["velocity"]
			gun_fire_rate = sidearm_stats["fire_rate"]
			gun_mag_size = sidearm_stats["mag_size"]
			gun_ammo_max = sidearm_stats["ammo"]
			gun_reload_speed = sidearm_stats["reload_speed"]
			gun_weight = sidearm_stats["weight"]
			gun_spread = sidearm_stats["spread"]

# swapping visibility of held weapons #
func weapon_visibility(ID):
	weapon_animation(swap_out, "unequip")
	yield(get_tree().create_timer(.3), "timeout")
	if primary_model != null:
		if ID == 1:
			primary_model.visible = true
			
			muzzle_position(primary)
		else:
			primary_model.visible = false
	if secondary_model != null:
		if ID == 2:
			secondary_model.visible = true
			muzzle_position(secondary)
		else:
			secondary_model.visible = false
	if sidearm_model != null:
		if ID == 3:
			sidearm_model.visible = true
			muzzle_position(sidearm)
		else:
			sidearm_model.visible = false
	weapon_animation(current, "equip")
func muzzle_position(ID):
	match ID:
		1:
			muzzle.global_transform = weapon1_pos.global_transform
		2:
			muzzle.global_transform = weapon2_pos.global_transform
		3:
			muzzle.global_transform = weapon3_pos.global_transform
		4:
			muzzle.global_transform = weapon4_pos.global_transform
		10:
			muzzle.global_transform = pistol1_pos.global_transform
		20:
			muzzle.global_transform = bolt_action_pos.global_transform
	#tracer.global_transform.origin = muzzle.global_transform.origin

func weapon_animation(ID, animation):
	var which_slot
	match ID:
		1:
			which_slot = primary_model
		2:
			which_slot = secondary_model
		3:
			which_slot = sidearm_model
	which_slot.get_node("AnimationPlayer").play(animation)


