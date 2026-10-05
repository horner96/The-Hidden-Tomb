extends CharacterBody2D
const BloodSplatter = preload("res://BloodSplatter.gd")

@onready var health_bar = $Healthbar
@onready var money_label = $MoneyLabel

var max_hp := 100
var hp := max_hp

var money :=0
var _contact_damage_cooldown := 0.0

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const CONTACT_DAMAGE_INTERVAL := 0.5

func _ready():
	$Hitbox/CollisionShape2D.disabled = true
	$HitboxUp/CollisionShape2D.disabled = true
	$HitboxUp.area_entered.connect(_on_hitbox_area_entered)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.8, 0.1, 0.1, 0.5)
	health_bar.add_theme_stylebox_override("fill", fill)
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0, 0, 0, 0.35)
	health_bar.add_theme_stylebox_override("background", back)
	health_bar.add_theme_color_override("font_color", Color.WHITE)
	$MoneyLabel.add_theme_color_override("font_color", Color.WHITE)
	health_bar.value = hp
	_update_money_display()
	add_to_group("players")
	$Hitbox.add_to_group("player_hitbox")
	$HitboxUp.add_to_group("player_hitbox")
	$Hurtbox.add_to_group("player_hurtbox")

	# signals
	$Hitbox.connect("area_entered", Callable(self, "_on_hitbox_area_entered"))

func heal(amount):
	hp = min(hp + amount, max_hp)
	health_bar.value = hp

func take_damage(amount):
	hp -= amount
	health_bar.value = hp
	print("Player HP:", hp)
	var splatter = BloodSplatter.new()
	get_tree().current_scene.add_child(splatter)
	splatter.global_position = global_position + Vector2(0, -12)
	if hp <= 0:
		die()

var dead := false

func die():
	if dead:
		return
	dead = true
	hide()
	set_physics_process(false)
	print("player dead")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://GameOver.tscn")
func add_money(amount):
	money += amount
	_update_money_display()
	
func _update_money_display():
	money_label.text = "Money: " + str(money)

var is_attacking := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	_update_contact_damage(delta)

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("ui_left", "ui_right")



	# Attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		sprite.play("attack")
		$AttackSound.play()
		_pulse_hitbox()

	# Horizontal movement (planted while attacking on the ground)
	if is_attacking and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()

	# Facing
	if direction != 0 and not is_attacking:
		sprite.flip_h = direction < 0
		
	if sprite.flip_h:
		$Hitbox.position.x = -110
	else:
		$Hitbox.position.x = 10

	_step_up(delta)
	move_and_slide()

	# Animation: attack > jump > walk > idle
	if is_attacking:
		return
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")


func _pulse_hitbox() -> void:
	$Hitbox/CollisionShape2D.disabled = false
	$HitboxUp/CollisionShape2D.disabled = false
	await get_tree().create_timer(0.12).timeout
	$Hitbox/CollisionShape2D.disabled = true
	$HitboxUp/CollisionShape2D.disabled = true


func _on_AnimatedSprite2D_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false


func _on_hitbox_area_entered(area):
	if area.name == "DetectionZone":
		return
	var enemy = area.get_parent()
	if enemy.is_in_group("enemies"):
		if enemy.has_method("take_damage"):
			enemy.take_damage(5)

func _update_contact_damage(delta: float) -> void:
	_contact_damage_cooldown = maxf(0.0, _contact_damage_cooldown - delta)
	var contact_hitbox: Area2D
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("enemy_hitbox") and not area.get_parent().is_queued_for_deletion():
			contact_hitbox = area
			break

	if contact_hitbox == null:
		return

	receive_enemy_contact(contact_hitbox.get_parent())

func receive_enemy_contact(enemy: Node) -> bool:
	if dead or enemy.is_queued_for_deletion() or _contact_damage_cooldown > 0.0:
		return false

	_contact_damage_cooldown = CONTACT_DAMAGE_INTERVAL
	if enemy.has_method("deal_damage"):
		take_damage(enemy.deal_damage())
	else:
		take_damage(5)
	return true

const STEP_HEIGHT := 20

# Lifts Zach over small ledges so stairs don't stop him
func _step_up(delta: float) -> void:
	if not is_on_floor() or velocity.x == 0.0 or velocity.y < 0.0:
		return
	var motion := Vector2(velocity.x * delta, 0.0)
	if motion.x == 0.0 or not test_move(global_transform, motion):
		return
	for h in range(1, STEP_HEIGHT + 1):
		var lift := Vector2(0, -h)
		if test_move(global_transform, lift):
			return
		if not test_move(global_transform.translated(lift), motion):
			global_position.y -= h
			return
