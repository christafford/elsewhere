shader_type spatial;
// Worn, irregular cobble courses on the unchanged walking surface.
uniform float path_half_width = 2.0;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
float cobble(vec2 p) {
    vec2 c=p/vec2(.32,.25);
    c.x+=mod(floor(c.y),2.0)*.5;
    c+=vec2(noise(p*5.7),noise(p*6.4+4.0))*.24;
    vec2 f=abs(fract(c)-.5);
    float edge=pow(pow(f.x*2.0,5.0)+pow(f.y*2.0,5.0),.2);
    float aa=max(fwidth(c.x),fwidth(c.y));
    float cap=1.0-smoothstep(.74-aa,1.0+aa,edge);
    return cap*(.52+.26*hash(floor(c))+.22*noise(p*36.0));
}
void fragment() {
    vec2 border=abs(UV-vec2(0,-1))-vec2(14,12);
    float square=1.0-smoothstep(-.06,.06,max(border.x,border.y));
    float paving=max(square,1.0-smoothstep(path_half_width-.08,path_half_width+.08,COLOR.r*8.0));
    float h=cobble(UV);
    vec3 stone=mix(vec3(.12,.135,.13),vec3(.29,.295,.275),h);
    stone*=.72+.28*noise(UV*.9);
    vec3 grass=mix(vec3(.07,.10,.044),vec3(.135,.175,.075),noise(UV*2.0));
    ALBEDO=mix(grass,stone,paving);
    ROUGHNESS=.94;
    vec2 d=vec2(cobble(UV+vec2(.008,0)),cobble(UV+vec2(0,.008)))-h;
    NORMAL_MAP=normalize(vec3(-d*1.4*paving,1.0))*.5+.5;
}
