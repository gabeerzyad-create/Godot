extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
 


@onready var healthbar: Control = $health
var maxhealth=150
var health=50

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta



	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
func _ready():
		healthbar.set_health_bar(health, maxhealth)
func take_damage(damage:int):
	health -= damage
	if health <0 :health=0
	healthbar.change_health(-damage)
	
	func take_heal(heal:int):
		health += heal
		healthbar.change_health(heal)
	
	
