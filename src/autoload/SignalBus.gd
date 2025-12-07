extends Node

signal resource_changed(type, value)
signal wave_started(wave_num)
signal wave_ended(wave_num)
signal unit_placed(unit, tile_pos)
signal enemy_spawned(enemy)
signal enemy_died(enemy)
signal core_damaged(current_hp)
signal game_over(final_wave)
signal projectile_fired(projectile_data)
