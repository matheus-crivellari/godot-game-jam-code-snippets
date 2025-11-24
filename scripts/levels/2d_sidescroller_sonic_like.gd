extends Node2D

@export var charater: CharacterSidescroller2DSonicLike

@onready var ground_speed_label := $CharacterBody2D/Camera2D/Control/GroundSpeed
@onready var axis_label := $CharacterBody2D/Camera2D/Control/Axis
@onready var last_dir_label := $CharacterBody2D/Camera2D/Control/LastDir

func _process(_delta):
  ground_speed_label.text = "Ground Speed: %s" % str(charater.ground_speed)
  axis_label.text = "Axis: %s" % str(Input.get_axis("left", "right"))
  last_dir_label.text = "Last Dir: %s" % str(charater._last_dir)
