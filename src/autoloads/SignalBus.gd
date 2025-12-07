extends Node

signal resource_changed(type, value)
signal wave_started(wave_number)
signal wave_ended
signal enemy_reached_core(damage)
signal unit_purchased(unit_data)
signal unit_sold(unit_data)
signal card_clicked(unit_data)
signal enemy_died(enemy)
signal core_health_changed(new_health)
