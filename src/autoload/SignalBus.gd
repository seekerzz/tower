extends Node

signal unit_purchased(unit_data)
signal enemy_spawned(enemy_data)
signal enemy_reached_core(damage)
signal game_over(final_wave)

# Optional but useful
signal resource_changed(resource_name, new_value)
signal wave_started(wave_number)
signal wave_ended(wave_number)
