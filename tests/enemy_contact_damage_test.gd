extends SceneTree

var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _run() -> void:
	var fixture := Node2D.new()
	root.add_child(fixture)
	current_scene = fixture
	var player = load("res://zach.tscn").instantiate()
	fixture.add_child(player)
	player.set_physics_process(false)

	var weapon: Area2D = player.get_node("Hitbox")
	var weapon_up: Area2D = player.get_node("HitboxUp")
	var unrelated_area := Area2D.new()
	player.add_child(unrelated_area)
	var hurtbox: Area2D = player.get_node("Hurtbox")

	for scene_path in ["res://cobra.tscn", "res://mummy.tscn"]:
		var enemy = load(scene_path).instantiate()
		enemy.position = Vector2(1000, 500)
		fixture.add_child(enemy)
		enemy.set_physics_process(false)
		player.hp = player.max_hp
		player._contact_damage_cooldown = 0.0

		enemy._on_hitbox_area_entered(weapon)
		_check(player.hp == player.max_hp, scene_path + ": horizontal weapon must not hurt Zach")
		enemy._on_hitbox_area_entered(weapon_up)
		_check(player.hp == player.max_hp, scene_path + ": upward weapon must not hurt Zach")
		enemy._on_hitbox_area_entered(unrelated_area)
		_check(player.hp == player.max_hp, scene_path + ": unrelated player areas must not hurt Zach")
		enemy._on_hitbox_area_entered(hurtbox)
		_check(player.hp == player.max_hp - enemy.attack_damage, scene_path + ": body contact must still damage Zach")
		enemy._on_hitbox_area_entered(hurtbox)
		_check(player.hp == player.max_hp - enemy.attack_damage, scene_path + ": entry callbacks must respect cooldown")
		enemy.dead = true
		player._contact_damage_cooldown = 0.0
		enemy._on_hitbox_area_entered(hurtbox)
		_check(player.hp == player.max_hp - enemy.attack_damage, scene_path + ": dead enemies must not damage Zach")
		enemy.free()

	var cobra = load("res://cobra.tscn").instantiate()
	cobra.position = Vector2(1000, 500)
	fixture.add_child(cobra)
	cobra.set_physics_process(false)
	cobra.hp = 1000
	player.position = cobra.position + Vector2(-100, 0)
	player.hp = player.max_hp
	player._contact_damage_cooldown = 0.0
	weapon.get_node("CollisionShape2D").disabled = false
	await physics_frame
	await physics_frame
	await process_frame
	_check(weapon.overlaps_area(cobra.hitbox), "Weapon-only test must overlap the cobra hitbox")
	_check(not hurtbox.overlaps_area(cobra.hitbox), "Weapon-only test must not overlap Zach's body")
	player._update_contact_damage(0.016)
	_check(player.hp == player.max_hp, "Weapon-only physics overlap must not damage Zach")
	_check(cobra.hp < 1000, "Zach's weapon must still damage the cobra")

	weapon.get_node("CollisionShape2D").disabled = true
	player.position = cobra.position
	await physics_frame
	await physics_frame
	await process_frame
	_check(hurtbox.overlaps_area(cobra.hitbox), "Zach's body must overlap the cobra at Y = 500")
	_check(player.hp == player.max_hp - cobra.attack_damage, "Cobra body entry must deal damage at Y = 500")
	player._update_contact_damage(0.016)
	_check(player.hp == player.max_hp - cobra.attack_damage, "Polling must not double the entry damage")
	player._update_contact_damage(0.4)
	_check(player.hp == player.max_hp - cobra.attack_damage, "Contact damage must wait for the half-second interval")
	player._update_contact_damage(0.1)
	_check(player.hp == player.max_hp - 2 * cobra.attack_damage, "Continued cobra contact must damage again after cooldown")
	# Positions where the two CharacterBody2D shapes block each other side by side.
	for side_offset in [Vector2(81, -11), Vector2(-83, -11)]:
		player.position = cobra.position + side_offset
		await physics_frame
		await physics_frame
		await process_frame
		_check(hurtbox.overlaps_area(cobra.hitbox), "Zach's hurtbox must reach a body-blocked cobra at offset %s" % side_offset)
	cobra.queue_free()
	player._update_contact_damage(player.CONTACT_DAMAGE_INTERVAL)
	_check(player.hp == player.max_hp - 2 * cobra.attack_damage, "A dying cobra must not deal a final contact hit")

	fixture.queue_free()
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	print("Enemy contact damage: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
