shader_type spatial;
varying vec3 location;
varying vec3 slope;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
void vertex() { location=VERTEX; slope=NORMAL; }
void fragment() {
    float patch=noise(location.xz*.16)*.6+noise(location.xz*.65)*.4;
    vec3 meadow=mix(vec3(.17,.215,.095),vec3(.30,.32,.17),patch);
    vec3 rock=mix(vec3(.23,.25,.23),vec3(.36,.37,.30),patch);
    vec3 ground=mix(rock,meadow,smoothstep(.65,.90,slope.y));
    float north=abs(location.x-(10.0+10.0*sin((location.z+50.0)*.06)));
    float south=abs(location.x-(-15.0+8.0*sin((location.z-50.0)*.07)));
    float track=(1.0-smoothstep(.65,1.15,north))*smoothstep(51.0,57.0,-location.z)*(1.0-smoothstep(87.0,100.0,-location.z));
    track=max(track,(1.0-smoothstep(.65,1.15,south))*smoothstep(51.0,57.0,location.z)*(1.0-smoothstep(85.0,98.0,location.z)));
    ALBEDO=mix(ground,vec3(.41,.37,.26),track*.8);
    ROUGHNESS=1.0;
}
