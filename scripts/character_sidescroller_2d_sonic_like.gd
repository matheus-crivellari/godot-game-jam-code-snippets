class_name CharacterSidescroller2DSonicLike

extends CharacterBody2D

## 0.046875 (12 subpixels)
@export var acceleration_speed:float = 0.046875
## 0.5  (128 subpixels)
@export var deceleration_speed: float =	0.5
## 0.046875 (12 subpixels)
@export var friction_speed: float = 0.046875
## 6 (6 pixels)
@export var top_speed: float = 6
## 6.5 (6 pixels and 128 subpixels)
@export var jump_force: float = 6.5
## displays debug lines in viewport
@export var debug_lines: bool = true

@onready var animated_sprite := $AnimatedSprite2D

var _last_dir := 1.0
var _ground_speed: float = 0.0
var _is_breaking := false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
  _ground_speed = calculate_ground_speed()
  flip_sprite()
  animate()
  
  queue_redraw()


func _draw() -> void:
  if not debug_lines:
    return
    
  var from := Vector2(0.0, 26.0)
  var to := Vector2(_ground_speed, 26.0)
  
  draw_line(from, to, Color.RED, 1.0)


func flip_sprite() -> void:
  if _last_dir < 0.0:
    animated_sprite.flip_h = true
  else:
    animated_sprite.flip_h = false


func animate() -> void:
  var ground_spd = absf(_ground_speed)
  
  if _is_breaking:
    animated_sprite.animation = "break"
  elif ground_spd > 0.0:
    if ground_spd <= 2.0:
      animated_sprite.animation = "walk"
    elif ground_spd > 2.0 and ground_spd <= 4.0:
      animated_sprite.animation = "jog"
    else:
      animated_sprite.animation = "run"
  else:
    animated_sprite.animation = "idle"


## Handles acceleration and breaking by player 
## input and deaceleration by friction
func calculate_ground_speed() -> float:
  var calculated_ground_speed: float = absf(_ground_speed)
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
