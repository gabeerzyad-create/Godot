extends Node2D
## KILN HALLOWEEN demo.
## Paints an ASCII map with terrain autotiling (hedges / walls, path or rug, liquid, graves), then lets you
## walk around as a trick-or-treater.
## Arrow keys: move.  Space: attack.

const BIOMES := ["graveyard"]
const MAP := [
	"##########################",
	"##########################",
	"#...........::...........#",
	"#...........::...........#",
	"#...........::.....__....#",
	"#.....::::::::::::.__....#",
	"#.....:.....::....:......#",
	"#.....:.....::....:......#",
	"#.~~~.:.....::....::::...#",
	"#.~~~~:.....::.......:...#",
	"#..~~.......::.......:...#",
	"#...........::...........#",
	"#...........::...........#",
	"############::############"
]

@onready var layer: TileMapLayer = $TileMapLayer
@onready var hero: AnimatedSprite2D = $Hero
var attacking := false


func _ready() -> void:
	build(BIOMES[0])
	hero.animation_finished.connect(func(): attacking = false)


func build(biome: String) -> void:
	layer.tile_set = load("res://kiln_halloween/Tilesets/%s/kiln_halloween_%s.tres" % [biome, biome])
	layer.clear()
	var all_cells: Array[Vector2i] = []
	var walls: Array[Vector2i] = []
	var liquid: Array[Vector2i] = []
	var pit: Array[Vector2i] = []
	var path: Array[Vector2i] = []
	for y in MAP.size():
		for x in MAP[y].length():
			var c: String = MAP[y][x]
			var v := Vector2i(x, y)
			all_cells.append(v)
			match c:
				"#": walls.append(v)
				"~": liquid.append(v)
				"_": pit.append(v)
				":": path.append(v)
	# terrain set 0: 0 floor, 1 wall, 2 liquid, 3 pit, 4 path
	layer.set_cells_terrain_connect(all_cells, 0, 0, false)
	layer.set_cells_terrain_connect(walls, 0, 1, false)
	layer.set_cells_terrain_connect(liquid, 0, 2, false)
	layer.set_cells_terrain_connect(pit, 0, 3, false)
	layer.set_cells_terrain_connect(path, 0, 4, false)


func is_free(p: Vector2) -> bool:
	var cell := Vector2i(floor(p.x / 16.0), floor((p.y - 2.0) / 16.0))
	if cell.y < 0 or cell.y >= MAP.size() or cell.x < 0 or cell.x >= MAP[cell.y].length():
		return false
	return MAP[cell.y][cell.x] in [".", ":"]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var i: int = event.keycode - KEY_1
		if i >= 0 and i < BIOMES.size():
			build(BIOMES[i])
		if event.keycode == KEY_SPACE and not attacking:
			attacking = true
			hero.play("attack")


func _process(delta: float) -> void:
	if attacking:
		return
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir == Vector2.ZERO:
		hero.play("idle")
		return
	hero.play("run")
	if dir.x != 0.0:
		hero.flip_h = dir.x < 0.0
	var next := hero.position + dir * 60.0 * delta
	if is_free(next + Vector2(0, 7)):
		hero.position = next
