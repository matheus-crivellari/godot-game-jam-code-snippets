class_name CharacterSidescroller2D

extends CharacterBody2D


const FIXED_FRAME_RATE = 60.0

## Walk speed
@export var speed := 150.0
## Jump strength
@export var jump_velocity := -300.0
## How many in-air frames to allow jumping
@export var coyote_frames := 6
## How many frames to buffer a jump action
@export var jump_buffer_frames := 12

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## Track whether we're in coyote time or not
var _coyote := false
## Last frame's on-floor state
var _last_floor := false

## Track whether a jump is buffered or not
var _is_jump_buffered := false
## Tells if player is jumping or not
var _is_jumping := false


func jump() -> void:
  velocity.y = jump_velocity
  _is_jumping = true


func cancel_jump() -> void:
  end_jump_buffer()
  
  if not _is_jumping:
    return

  # if is it going up
  if velocity.y < 0.0:
    velocity.y = 0.0

  _is_jumping = false


func start_coyote() -> void:
  print('start')
  _coyote = true
  get_tree().create_timer(coyote_frames / FIXED_FRAME_RATE).timeout.connect(end_coyote)
  

func end_coyote() -> void:
  print('end')
  _coyote = false


func start_jump_buffer() -> void:
  _is_jump_buffered = true
  get_tree().create_timer(jump_buffer_frames * FIXED_FRAME_RATE).timeout.connect(end_jump_buffer)


func end_jump_buffer() -> void:
  _is_jump_buffered = false


func _physics_process(delta) -> void:
  # if not on floor adds the gravity
  if not is_on_floor():
    velocity += get_gravity() * delta
  # otherwise handles jump buffer
  elif _is_jump_buffered:
    jump()
    end_jump_buffer()


  var can_jump = is_on_floor() or _coyote

  # Handle jump cancelation
  if Input.is_action_just_released("jump") and not is_on_floor():
    cancel_jump()
    
  # Handle jump.
  if Input.is_action_just_pressed("jump"):
    if can_jump:
      jump()
    else:
      start_jump_buffer()

  # Get the input direction and handle the movement/deceleration.
  # As good practice, you should replace UI actions with custom gameplay actions.
  var direction = Input.get_axis("left", "right")
  
  if direction:
    if direction > 0.0:
      animated_sprite.flip_h = true
    elif direction < 0.0:
      animated_sprite.flip_h = false
      
    animated_sprite.animation = "walk"
    velocity.x = direction * speed
  else:
    animated_sprite.animation = "idle"
    velocity.x = move_toward(velocity.x, 0, speed)

  move_and_slide()
  
  if is_on_floor() and _is_jumping:
    _is_jumping = false
  
  if not is_on_floor() and _last_floor and not _is_jumping:
    start_coyote()

  _last_floor = is_on_floor()
