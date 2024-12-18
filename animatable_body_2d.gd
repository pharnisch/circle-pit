extends AnimatableBody2D

@export var speed = 0.5

func _enter_tree():
	set_multiplayer_authority(1) # only server allowed to manipulate this object

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		rotation += delta * speed
