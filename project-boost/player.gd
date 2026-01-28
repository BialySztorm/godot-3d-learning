extends RigidBody3D

## How much thrust to apply when boosting
@export var thrust: float = 1000.0
## How much torque to apply when rotating
@export var torque: float = 100.0

@onready var explosion_sound: AudioStreamPlayer = $ExplosionAudio
@onready var success_sound: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles

var is_transitioning: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if not rocket_audio.playing:
			rocket_audio.play()
	else:
		booster_particles.emitting = false
		rocket_audio.stop()
	var direction: Vector3 = Vector3(0, 0, -Input.get_axis("rotate_left", "rotate_right"))
	if direction != Vector3.ZERO:
		apply_torque(direction * delta * torque)
		if direction.z > 0:
			left_booster_particles.emitting = false
			right_booster_particles.emitting = true
		else:
			right_booster_particles.emitting = false
			left_booster_particles.emitting = true
	else:
		left_booster_particles.emitting = false
		right_booster_particles.emitting = false

func _on_body_entered(body: Node) -> void:
	if is_transitioning:
		return
	if body.is_in_group("Goal"):
		complete_level(body.file_path)
	elif body.is_in_group("Hazard"):
		crash_sequence()

func crash_sequence() -> void:
	print("Crash sequence initiated!")
	explosion_particles.emitting = true
	explosion_sound.play()
	set_process(false)
	is_transitioning = true
	var tween: Tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().reload_current_scene)


func complete_level(next_level_file) -> void:
	print("Level complete!")
	success_particles.emitting = true
	success_sound.play()
	is_transitioning = true
	var tween: Tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
