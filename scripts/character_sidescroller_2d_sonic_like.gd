class_name CharacterSidescroller2DSonicLike

extends CharacterBody2D

const CONSTANT_MULTIPLIER = 60.0

## 0.046875 (12 subpixels)
@export var acceleration_speed: float = 0.046875 * CONSTANT_MULTIPLIER
## 0.5  (128 subpixels)
@export var deceleration_speed: float =	0.5 * CONSTANT_MULTIPLIER
## 0.046875 (12 subpixels)
@export var friction_speed: float = 0.046875 * CONSTANT_MULTIPLIER
## 6 (6 pixels)
@export var top_speed: float = 6 * CONSTANT_MULTIPLIER
## 6.5 (6 pixels and 128 subpixels)
@export var jump_force: float = 6.5 * CONSTANT_MULTIPLIER
## displays debug lines in viewport
@export var debug_lines: bool = true

@onready var animated_sprite := $AnimatedSprite2D
@onready var sensor_a := $SensorA
@onready var sensor_b := $SensorB

var ground_speed: float = 0.0

var _last_dir := 1.0
var _is_breaking := false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta) -> void:
  ground_speed = calculate_ground_speed()
  velocity.x = ground_speed
  
  move_and_slide()
  
  flip_sprite()
  animate()
  
  queue_redraw()


func _draw() -> void:
  if not debug_lines:
    return
    
  var from := Vector2(0.0, 26.0)
  var to := Vector2(ground_speed / CONSTANT_MULTIPLIER, 26.0)
  
  draw_line(from, to, Color.RED, 1.0)
  
  if sensor_a.is_colliding() and sensor_b.is_colliding():
    var point_a: Vector2 = to_local(sensor_a.get_collision_point())
    var point_b: Vector2 = to_local(sensor_b.get_collision_point())
    var ground_vector: Vector2 = point_b - point_a
    
    draw_line(point_a, point_a + ground_vector, Color.YELLOW, 1.0)
    
    var normal_vector  = ground_vector.rotated(deg_to_rad(-90))
    var offset = ground_vector / 2
    
    draw_line(point_a + offset, point_a + offset + normal_vector, Color.MAGENTA, 1.0)


func flip_sprite() -> void:
  if _last_dir < 0.0:
    animated_sprite.flip_h = true
  else:
    animated_sprite.flip_h = false


func animate() -> void:
  var ground_spd = absf(ground_speed)
  
  if _is_breaking:
    animated_sprite.animation = "break"
  elif ground_spd > 0.0 * CONSTANT_MULTIPLIER:
    if ground_spd <= 2.0 * CONSTANT_MULTIPLIER:
      animated_sprite.animation = "walk"
    elif ground_spd > 2.0 * CONSTANT_MULTIPLIER and ground_spd <= 4.0 * CONSTANT_MULTIPLIER:
      animated_sprite.animation = "jog"
    else:
      animated_sprite.animation = "run"
  else:
    animated_sprite.animation = "idle"


## Handles acceleration and breaking by player 
## input and deaceleration by friction
func calculate_ground_speed() -> float:
  var calculated_ground_speed: float = absf(ground_speed)
  var axis := Input.get_axis("left", "right")
  
  # input
  if abs(axis):
    # break
    if calculated_ground_speed > 0.0 && signf(axis) != signf(_last_dir):
      calculated_ground_speed = clampf(calculated_ground_speed - deceleration_speed, 0.0, calculated_ground_speed)
      _is_breaking = true
    # accelerate
    elif calculated_ground_speed < top_speed:
      calculated_ground_speed = clampf(calculated_ground_speed + acceleration_speed, 0.0, top_speed)
      _is_breaking = false
    
  # no input deacelerate by friction
  else:
    calculated_ground_speed -= minf(calculated_ground_speed, friction_speed) * signf(calculated_ground_speed)
    
  # we only invert last direction when speed reaches 0
  if abs(axis) and calculated_ground_speed == 0.0:
    _last_dir = axis
  
  return calculated_ground_speed * _last_dir
