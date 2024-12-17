extends CharacterBody2D


const SPEED = 10.0
const JUMP_VELOCITY = 600.0

var custom_up = null
var custom_right = null
var degrees = null

@export var pulled_towards_center = false

func _ready() -> void:
	degrees = randf_range(0,360)
	custom_up = Vector2.UP.rotated(2.0*PI*degrees)
	custom_right = Vector2.RIGHT.rotated(2.0*PI*degrees)
	set_up_direction(custom_up)
	transform = transform.rotated(2.0*PI*degrees)



func _physics_process(delta: float) -> void:
	if pulled_towards_center:
		var _gravity_dir = (-position).normalized()
		var _degrees = rad_to_deg(atan2(_gravity_dir.y, _gravity_dir.x))
		degrees = _degrees # update class variable
		custom_up = Vector2.UP.rotated(2.0*PI*_degrees)
		custom_right = Vector2.RIGHT.rotated(2.0*PI*_degrees)
		set_up_direction(custom_up)
		print(custom_up)
		rotation = _gravity_dir.angle() - PI / 2





	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_custom_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity += custom_up * JUMP_VELOCITY
		print(custom_up)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity += custom_right * direction * SPEED
	else:
		var b11 = custom_up.x
		var b12 = custom_up.y
		var b21 = custom_right.x
		var b22 = custom_right.y
		var vx = velocity.x
		var vy = velocity.y
		var c_teiler = b11*b22 - b21*b12
		if c_teiler != 0:
			var up_velocity = (b22*vx - b21*vy)/c_teiler
			var right_velocity = (-b12*vx - b11*vy)/c_teiler
			print("up_velocity: ", str(up_velocity))
			print("right_velocity: ", str(right_velocity))
			velocity = up_velocity * custom_up
		#velocity.x = move_toward(velocity.x, 0, SPEED)
	#speed = move_toward(speed, input * MAX_SPEED, ACCELERATION * delta)

	move_and_slide()
	
func get_custom_gravity():
	var _degrees = 0


	_degrees = degrees
		


	return get_gravity().rotated(2.0*PI*_degrees)
