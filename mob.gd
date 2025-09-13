extends CharacterBody3D

@export var min_speed = 10
@export var max_speed = 18
@export var death_sfx: AudioStream 
signal squashed

func _physics_process(_delta):
	move_and_slide()

func initialize(start_position: Vector3, player_position: Vector3) -> void:
	# ให้หันเฉพาะแกน Y: ใช้ Y ของมอนสเตอร์เอง (start_position.y)
	var flat_target := Vector3(player_position.x, start_position.y, player_position.z)
	look_at_from_position(start_position, flat_target, Vector3.UP)

	# กันพิตช์/โรลด์เผื่อไว้ (ปลดเอียง X/Z)
	rotation.x = 0.0
	rotation.z = 0.0

	# สุ่มเบี่ยงมุมเล็กน้อย
	rotate_y(randf_range(-PI / 4, PI / 4))

	# เดินไปข้างหน้าในทิศที่กำลังหัน (เฉพาะ Y-rotation)
	var random_speed := randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)

	$AnimationPlayer.speed_scale = float(random_speed) / float(min_speed)

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()

func squash() -> void:
	if death_sfx:
		var sfx := AudioStreamPlayer3D.new()
		sfx.stream = death_sfx
		sfx.global_transform = global_transform
		get_tree().current_scene.add_child(sfx)
		sfx.finished.connect(sfx.queue_free)
		sfx.play()

	squashed.emit()
	queue_free()
