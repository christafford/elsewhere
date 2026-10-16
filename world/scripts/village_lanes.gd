## Authored P22-T11 streets joining the four original approaches. No new terrain.
extends RefCounted

const ROUTES := {
	"north_lane": [Vector2(3,-22), Vector2(2,-25), Vector2(-14,-24.5), Vector2(-20.4,-26)],
	"book_lane": [Vector2(5,-35), Vector2(5,-33), Vector2(2.3,-33)],
	"library_lane": [Vector2(5,-33), Vector2(7,-32), Vector2(10,-32)],
	"potters_lane": [Vector2(6,-28), Vector2(8,-26), Vector2(24.5,-26), Vector2(24.5,-19)],
	"bakery_lane": [Vector2(-24,-3), Vector2(-24.5,1)],
	"herb_lane": [Vector2(-24.5,1), Vector2(-24,7), Vector2(-24.5,17)],
	"store_lane": [Vector2(24,3), Vector2(25.5,0)],
	"hearth_lane": [Vector2(18,0), Vector2(18,8), Vector2(18,12.2)],
	"meadow_lane": [Vector2(-2,22), Vector2(1,25), Vector2(7,25)],
	"south_court": [Vector2(7,25), Vector2(11,25), Vector2(11,10.8), Vector2(18,10.8), Vector2(18,12.2)],
}
