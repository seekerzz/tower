class_name GameData

const TILE_SIZE = 60

const UNIT_TYPES = {
	"mouse": { "name": "加特林鼠", "icon": "🐭", "cost": 15, "size": Vector2i(1,1), "damage": 3, "range": 250, "atkSpeed": 0.15, "foodCost": 1.5, "manaCost": 0, "attackType": "ranged", "proj": "dot" },
	"turtle": { "name": "狙击龟", "icon": "🐢", "cost": 25, "size": Vector2i(1,1), "damage": 45, "range": 500, "atkSpeed": 1.8, "foodCost": 8, "manaCost": 0, "attackType": "ranged", "proj": "rocket" },
	"ranger": { "name": "游侠", "icon": "🤠", "cost": 60, "size": Vector2i(1,1), "damage": 12, "range": 180, "atkSpeed": 1.5, "foodCost": 3, "manaCost": 0, "attackType": "ranged", "proj": "pellet", "projCount": 5, "spread": 0.5 },
	"ninja": { "name": "忍者", "icon": "🥷", "cost": 80, "size": Vector2i(1,1), "damage": 25, "range": 250, "atkSpeed": 0.8, "foodCost": 4, "manaCost": 0, "attackType": "ranged", "proj": "shuriken", "pierce": 3 },
	"tesla": { "name": "磁暴线圈", "icon": "⚡", "cost": 70, "size": Vector2i(1,1), "damage": 35, "range": 200, "atkSpeed": 1.2, "foodCost": 5, "manaCost": 5, "attackType": "ranged", "proj": "lightning", "chain": 4 },
	"cannon": { "name": "震荡炮", "icon": "💣", "cost": 90, "size": Vector2i(1,1), "damage": 40, "range": 200, "atkSpeed": 2.0, "foodCost": 8, "manaCost": 0, "attackType": "ranged", "proj": "swarm_wave" },
	"void": { "name": "奇点", "icon": "🌌", "cost": 200, "size": Vector2i(1,1), "damage": 5, "range": 300, "atkSpeed": 3.0, "foodCost": 15, "manaCost": 20, "attackType": "ranged", "proj": "blackhole" },
	"knight": { "name": "狂战士", "icon": "🗡️", "cost": 30, "size": Vector2i(1,1), "damage": 20, "range": 100, "atkSpeed": 0.8, "foodCost": 4, "manaCost": 0, "attackType": "melee", "splash": 60, "skill": "rage", "skillCd": 10 },
	"bear":   { "name": "暴怒熊", "icon": "🐻", "cost": 65, "size": Vector2i(1,1), "damage": 35, "range": 80, "atkSpeed": 1.2, "foodCost": 5, "manaCost": 0, "attackType": "melee", "skill": "stun", "skillCd": 15 },
	"treant": { "name": "树人守卫", "icon": "🌳", "cost": 40, "size": Vector2i(1,1), "damage": 10, "range": 80, "atkSpeed": 1.5, "foodCost": 2, "manaCost": 0, "attackType": "melee" },
	"wizard": { "name": "大法师", "icon": "🧙‍♂️", "cost": 50, "size": Vector2i(1,1), "damage": 60, "range": 350, "atkSpeed": 1.2, "foodCost": 1, "manaCost": 5, "attackType": "ranged", "proj": "orb", "splash": 30, "skill": "nova", "skillCd": 12 },
	"phoenix":{ "name": "凤凰", "icon": "🦅", "cost": 150, "size": Vector2i(1,1), "damage": 25, "range": 300, "atkSpeed": 0.6, "foodCost": 10, "manaCost": 0, "attackType": "ranged", "proj": "fire", "splash": 40, "skill": "firestorm", "skillCd": 20 },
	"hydra":  { "name": "三头犬", "icon": "🐕", "cost": 120, "size": Vector2i(2,2), "damage": 40, "range": 120, "atkSpeed": 0.8, "foodCost": 20, "manaCost": 0, "attackType": "melee", "skill": "devour_aura" },
	"plant":  { "name": "向日葵", "icon": "🌻", "cost": 20, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 1.0, "foodCost": -6, "manaCost": 0, "attackType": "none", "produce": "food", "produceAmt": 6 },
	"crystal":{ "name": "法力水晶", "icon": "💎", "cost": 30, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 1.0, "foodCost": 0, "manaCost": -3, "attackType": "none", "produce": "mana", "produceAmt": 3 },
	"torch":  { "name": "红莲火炬", "icon": "🔥", "cost": 35, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 0, "foodCost": 0, "manaCost": 0, "attackType": "none", "buffProvider": "fire" },
	"cauldron":{ "name": "剧毒大锅", "icon": "🧪", "cost": 35, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 0, "foodCost": 0, "manaCost": 0, "attackType": "none", "buffProvider": "poison" },
	"prism":  { "name": "光之棱镜", "icon": "🧊", "cost": 40, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 0, "foodCost": 0, "manaCost": 0, "attackType": "none", "buffProvider": "range" },
	"drum":   { "name": "战鼓", "icon": "🥁", "cost": 40, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 0, "foodCost": 0, "manaCost": 0, "attackType": "none", "buffProvider": "speed" },
	"lens":   { "name": "聚光透镜", "icon": "🔍", "cost": 45, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 0, "foodCost": 0, "manaCost": 0, "attackType": "none", "buffProvider": "crit" },
	"mirror": { "name": "反射魔镜", "icon": "🪞", "cost": 50, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 0, "foodCost": 0, "manaCost": 0, "attackType": "none", "buffProvider": "bounce" },
	"splitter":{ "name": "多重棱镜", "icon": "💠", "cost": 55, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 0, "foodCost": 0, "manaCost": 0, "attackType": "none", "buffProvider": "split" },
	"meat":   { "name": "五花肉", "icon": "🥓", "cost": 10, "size": Vector2i(1,1), "damage": 0, "range": 0, "atkSpeed": 0, "foodCost": 0, "manaCost": 0, "isFood": true, "xp": 50, "attackType": "none" }
}

const ENEMY_VARIANTS = {
	"slime": { "name": "史莱姆", "icon": "💧", "color": Color("#00cec9"), "radius": 10, "hpMod": 0.8, "spdMod": 0.7, "attackType": "melee", "range": 30, "dmg": 5, "atkSpeed": 1.0, "drop": "mucus", "dropRate": 0.5 },
	"poison":{ "name": "毒怪", "icon": "🤢", "color": Color("#2ecc71"), "radius": 12, "hpMod": 1.2, "spdMod": 0.8, "attackType": "melee", "range": 30, "dmg": 8, "atkSpeed": 1.0, "drop": "poison", "dropRate": 0.4 },
	"wolf":  { "name": "狼群", "icon": "🐺", "color": Color("#e74c3c"), "radius": 14, "hpMod": 1.0, "spdMod": 1.5, "attackType": "melee", "range": 30, "dmg": 12, "atkSpeed": 0.8, "drop": "fang", "dropRate": 0.3 },
	"treant":{ "name": "树人", "icon": "🌳", "color": Color("#d35400"), "radius": 18, "hpMod": 2.5, "spdMod": 0.5, "attackType": "melee", "range": 30, "dmg": 20, "atkSpeed": 2.0, "drop": "wood", "dropRate": 0.6 },
	"yeti":  { "name": "雪怪", "icon": "❄️", "color": Color("#74b9ff"), "radius": 20, "hpMod": 3.0, "spdMod": 0.6, "attackType": "melee", "range": 40, "dmg": 25, "atkSpeed": 2.0, "drop": "snow", "dropRate": 0.5 },
	"golem": { "name": "石头人", "icon": "🗿", "color": Color("#95a5a6"), "radius": 22, "hpMod": 4.0, "spdMod": 0.4, "attackType": "melee", "range": 40, "dmg": 30, "atkSpeed": 2.5, "drop": "stone", "dropRate": 0.5 },
	"shooter":{ "name": "投矛手", "icon": "🏹", "color": Color("#16a085"), "radius": 14, "hpMod": 0.8, "spdMod": 0.8, "attackType": "ranged", "range": 200, "dmg": 8, "atkSpeed": 2.0, "projectileSpeed": 150, "drop": "wood", "dropRate": 0.3 },
	"boss":   { "name": "虚空领主", "icon": "👹", "color": Color("#2c3e50"), "radius": 32, "hpMod": 15.0, "spdMod": 0.4, "attackType": "melee", "range": 50, "dmg": 50, "atkSpeed": 3.0, "drop": "stone", "dropRate": 1.0 }
}

const BARRICADE_TYPES = {
	"mucus": { "hp": 50, "type": "slow", "strength": 0.3, "color": Color(0, 0.8, 0.79, 0.5), "width": 8, "name": "粘液网" },
	"poison":{ "hp": 1, "type": "poison", "strength": 20, "color": Color(0.18, 0.8, 0.44, 0.4), "width": 20, "name": "毒雾", "immune": true },
	"fang":  { "hp": 80, "type": "reflect", "strength": 10, "color": Color(0.9, 0.3, 0.23, 0.8), "width": 6, "name": "荆棘" },
	"wood":  { "hp": 200, "type": "block", "strength": 0, "color": Color("#d35400"), "width": 6, "name": "木栏" },
	"snow":  { "hp": 150, "type": "freeze", "strength": 1.5, "color": Color("#74b9ff"), "width": 8, "name": "冰墙" },
	"stone": { "hp": 600, "type": "block", "strength": 0, "color": Color("#7f8c8d"), "width": 10, "name": "石墙" }
}

const MATERIAL_TYPES = {
	"mucus": { "name": "粘液", "icon": "💧", "color": Color("#00cec9"), "desc": "减速陷阱" },
	"poison":{ "name": "毒药", "icon": "🧪", "color": Color("#2ecc71"), "desc": "毒雾屏障" },
	"fang":  { "name": "尖牙", "icon": "🦷", "color": Color("#e74c3c"), "desc": "尖刺陷阱" },
	"wood":  { "name": "木头", "icon": "🪵", "color": Color("#d35400"), "desc": "木栅栏" },
	"snow":  { "name": "雪团", "icon": "❄️", "color": Color("#74b9ff"), "desc": "冰墙" },
	"stone": { "name": "石头", "icon": "🪨", "color": Color("#95a5a6"), "desc": "石墙" }
}
