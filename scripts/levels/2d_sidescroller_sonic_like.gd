extends Node2D

@export var charater: CharacterSidescroller2DSonicLike

@onready var ground_speed_label := $Control/GroundSpeed
@onready var axis_label := $Control/Axis
@onready var last_dir_label := $Control/LastDir

func _process(_delta):
  ground_speed_label.text = "Ground Speed: %s" % str(charater._ground_speed)
  axis_label.text = "Axis: %s" % str(Input.get_axis("left", "right"))
  last_dir_label.text = "Last Dir: %s" % str(charater._last_dir)
