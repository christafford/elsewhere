shader_type spatial;
varying vec3 location;
varying vec3 slope;
#include "res://scripts/village_noise.gdshaderinc"
void vertex() { location=VERTEX; slope=NORMAL; }
void fragment() {
    float patch=noise(location.xz*.16)*.6+noise(location.xz*.65)*.4;
    vec3 meadow=mix(vec3(.13,.235,.065),vec3(.30,.38,.12),patch);
    vec3 rock=mix(vec3(.25,.27,.22),vec3(.40,.39,.30),patch);
    vec3 ground=mix(rock,meadow,smoothstep(.65,.90,slope.y));
    float north=abs(location.x-(10.0+10.0*sin((location.z+50.0)*.06)));
    float south=abs(location.x-(-15.0+8.0*sin((location.z-50.0)*.07)));
    float track=(1.0-smoothstep(.65,1.15,north))*smoothstep(51.0,57.0,-location.z)*(1.0-smoothstep(87.0,100.0,-location.z));
    track=max(track,(1.0-smoothstep(.65,1.15,south))*smoothstep(51.0,57.0,location.z)*(1.0-smoothstep(85.0,98.0,location.z)));
    // Match the walking terrain exactly at the seam, then broaden the meadow
    // variation with distance. No material stripe replaces the removed wall.
    vec3 near_grass=mix(vec3(.115,.175,.038),vec3(.19,.26,.058),noise(location.xz*2.0));
    float beyond=max(abs(location.x),abs(location.z))-48.0;
    ALBEDO=mix(near_grass,mix(ground,vec3(.41,.37,.26),track*.8),smoothstep(0.0,18.0,beyond));
    ROUGHNESS=mix(.98,1.0,smoothstep(0.0,18.0,beyond));
}
