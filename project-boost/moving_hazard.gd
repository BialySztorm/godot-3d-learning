extends AnimatableBody3D

## Destination point for the hazard to move to
@export var destination: Vector3 = Vector3.ZERO
## Duration of the movement animation in seconds
@export var duration: float = 2.0

func _ready() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", global_position + destination, duration)
	tween.tween_property(self, "global_position", global_position, duration)
