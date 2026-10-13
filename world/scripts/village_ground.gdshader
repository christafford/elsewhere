shader_type spatial;
// Worn, irregular cobble courses on the unchanged walking surface.
uniform float path_half_width = 2.0;
uniform sampler2D cobble_diff : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D cobble_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D cobble_rough : filter_linear_mipmap_anisotropic, repeat_enable;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
void fragment() {
    vec2 border=abs(UV-vec2(0,-1))-vec2(14,12);
    float square=1.0-smoothstep(-.06,.06,max(border.x,border.y));
    float paving=max(square,1.0-smoothstep(path_half_width-.08,path_half_width+.08,COLOR.r*8.0));
    // The scanned patch covers 2m: stones stay roughly 20–30cm across.
    vec2 uv=UV*.5;
    vec3 stone=texture(cobble_diff,uv).rgb;
    stone*=vec3(.58,.56,.49)*(.90+.10*noise(UV*.19));
    vec3 grass=mix(vec3(.115,.175,.038),vec3(.19,.26,.058),noise(UV*2.0));
    ALBEDO=mix(grass,stone,paving);
    ROUGHNESS=mix(.98,clamp(texture(cobble_rough,uv).r,.85,1.0),paving);
    NORMAL_MAP=mix(vec3(.5,.5,1),texture(cobble_normal,uv).rgb,paving);
    NORMAL_MAP_DEPTH=.65;
}
