extends "res://Enemies/Enemy.gd"

@export var speed: float = 180.0
@export var bat_hp: int = 50
@export var attack_damage: int = 10

var player: Node2D = null
var awake: bool = false

@onready var detection_zone: Area2D = $DetectionZone

func _ready() -> void:
	# Connect signals once
	var enter_callable := Callable(self, "_on_DetectionZone_body_entered")
	if not detection_zone.is_connected("body_entered", enter_callable):
		detection_zone.connect("body_entered", enter_callable)

func deal_damage() -> int:
	return attack_damage

func _on_DetectionZone_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		awake = true

func _physics_process(delta: float) -> void:
	# If the player was removed (scene change), stop chasing
	if player and not player.is_inside_tree():
		player = null
		awake = false

	if awake and player:
		var direction := (player.global_position - global_position).normalized()
		velocity = direction * speed
		
		if velocity.x >0:
			$AnimatedSprite2D.flip_h = true
		elif velocity.x <0:
			$AnimatedSprite2D.flip_h = false
			
		move_and_slide()

		if $AnimatedSprite2D and $AnimatedSprite2D.sprite_frames.has_animation("fly"):
			$AnimatedSprite2D.play("fly")
	else:
		velocity = Vector2.ZERO
		if $AnimatedSprite2D and $AnimatedSprite2D.sprite_frames.has_animation("idle"):
			$AnimatedSprite2D.play("idle")
			
			


func _on_visibility_notifier_screen_entered() -> void:
	$BatSound.play()


func _on_visibility_notifier_screen_exited() -> void:
	$BatSound.stop()
