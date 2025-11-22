class_name CharacterSidescroller2DSonicLike

extends CharacterSidescroller2D

@export var floor_snap_distance: float = 128.0
@export var max_slope_deg: float = 60.0


func align_with_floor() -> void:
  if is_on_floor():
    # here we need to increase the normal angle by 90 because
    # CharacterBody's normal points forward at 0 deg Vec2(1,0) and
    # floor's normal points up at 0 deg Vec2(0,1), so we need to adjust it
    rotation = get_floor_normal().angle() + deg_to_rad(90.0)
    up_direction = get_floor_normal()
  else:
    rotation = 0.0
    up_direction = Vector2.UP


func reset_rotation() -> void:
  get_tree().create_timer(15 / FIXED_FRAME_RATE).timeout.connect(reset_rotation_timeout)


func reset_rotation_timeout() -> void:
  up_direction = Vector2.UP
  rotation = 0.0
  print('reset rotation')


func _physics_process(delta):
  #align_with_floor()
  #
  ## if not on floor adds the gravity
  #if not is_on_floor():
    #velocity += get_gravity() * delta
  ## otherwise handles jump buffer
#
  #var can_jump = is_on_floor()
#
  ## Handle jump cancelation
  #if Input.is_action_just_released("jump") and not is_on_floor():
    #cancel_jump()
    #
  ## Handle jump.
  #if Input.is_action_just_pressed("jump"):
    #if can_jump:
      #jump()
#
  ## Get the input direction and handle the movement/deceleration.
  #var direction = Input.get_axis("left", "right")
#
  #if direction:
    #if direction > 0.0:
      #flip_sprite(true)
    #elif direction < 0.0:
      #flip_sprite(false)
      #
    #animated_sprite.animation = "walk"
    #velocity.x = direction * speed
  #else:
    #animated_sprite.animation = "idle"
    #velocity.x = move_toward(velocity.x, 0, speed)
#
  #floor_max_angle = deg_to_rad(max_slope_deg)
#
  #if is_on_floor():
    #floor_snap_length = floor_snap_distance
    #velocity = velocity.rotated(rotation)
  #else:
    #floor_snap_length = 1.0
#
  #move_and_slide()
  #
  #velocity = velocity.rotated(-rotation)
  
  # Add the gravity.
  if is_on_floor():
    floor_snap_length = floor_snap_distance
    floor_max_angle = deg_to_rad(max_slope_deg)
  else:
    velocity += get_gravity() * delta
    floor_snap_length = 1.0
    floor_max_angle = deg_to_rad(45)

  # Handle jump.
  if Input.is_action_just_pressed("jump") and is_on_floor():
    floor_snap_length = 1.0
    floor_max_angle = deg_to_rad(45)
    velocity.y = jump_velocity

  # Get the input direction and handle the movement/deceleration.
  # As good practice, you should replace UI actions with custom gameplay actions.
  var direction = Input.get_axis("left", "right")
  
  if direction:
    velocity.x = direction * speed
  else:
    velocity.x = move_toward(velocity.x, 0, speed)

  velocity = velocity.rotated(rotation)
  
  move_and_slide()
  
  velocity = velocity.rotated(-rotation)
  
  if is_on_floor():
    up_direction = get_floor_normal()
    rotation = get_floor_normal().angle() + deg_to_rad(90)
  else:
    if not _last_floor:
      reset_rotation()

  _last_floor = is_on_floor()


func _unhandled_key_input(event: InputEvent):
  if event is InputEventKey:
    if event.keycode == KEY_R and event.is_released():
      get_tree().reload_current_scene()
