extends "res://Enemies/Enemy.gd"
@export var speed: float = 80.0
@export var mummy_hp: int = 2
@export var attack_damage: int = 20
@export var patrol_tiles: int = 10
#@export var speed: float = 40.0
#@export var cobra_hp: int = 3
#@export var attack_damage: int = 5

const TILE_SIZE := 16.0

var direction := -1
var dead := false
var travelled := 0.0
var base_y := 0.0

@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox

func _ready():
	hitbox.add_to_group("enemy_hitbox")
	hurtbox.add_to_group("enemy_hurtbox")
	hurtbox.connect("area_entered", Callable(self, "_on_hurtbox_area_entered"))
	hitbox.connect("area_entered", Callable(self, "_on_hitbox_area_entered"))

	hp = mummy_hp
	base_y = global_position.y
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING


func deal_damage() -> int:
	return attack_damage

func _physics_process(_delta):
	if dead:
		return

	velocity.x = direction * speed
	var start_x := global_position.x
	move_and_slide()
	global_position.y = base_y
	travelled += abs(global_position.x - start_x)

	if _hit_wall() or travelled >= patrol_tiles * TILE_SIZE:
		travelled = 0.0
		direction *= -1

	$AnimatedSprite2D.flip_h = direction > 0
	$AnimatedSprite2D.play("move")

#	if is_on_wall():
#		direction *= -1

func _on_hitbox_area_entered(area):
	if dead or not area.is_in_group("player_hurtbox"):
		return
	var player = area.get_parent()
	if player.is_in_group("players"):
		if player.receive_enemy_contact(self):
			$mummysound.play()

func _on_hurtbox_area_entered(area):
	if not area.is_in_group("player_hitbox"):
		return
	var player = area.get_parent()
	if player.is_in_group("players"):
		if player.has_method("deal_damage"):
			take_damage(player.deal_damage())
		else:
			take_damage(1)

func take_damage(amount):
	if dead:
		return

	hp -= 1
	if hp <= 0:
		dead = true
		_drop_coin()
		queue_free()


func _hit_wall() -> bool:
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if abs(c.get_normal().x) > 0.9 and not c.get_collider().is_in_group("players"):
			return true
	return false

func _on_visibility_notifier_screen_entered() -> void:
		$mummysound.play()


func _on_visibility_notifier_screen_exited() -> void:
	$mummysound.stop()
