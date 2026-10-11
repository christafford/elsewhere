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
    float weather=noise(location.xz*.16)*.5+noise(location.xz*.63)*.3+noise(location.xz*2.1)*.2;
    float snow=smoothstep(57.0,69.0,location.y+noise(location.xz*.2)*11.0)*smoothstep(.48,.86,slope.y);
    vec3 rock=mix(vec3(.09,.125,.15),vec3(.18,.215,.23),weather);
    vec3 dust=mix(vec3(.28,.33,.35),vec3(.43,.46,.46),weather);
    ALBEDO=mix(rock,dust,snow);
    ROUGHNESS=1.0;
}
