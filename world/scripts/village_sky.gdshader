shader_type sky;
// Fixed high cloud layer: art direction only, no weather/time-of-day system.
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
void sky() {
    float up=max(EYEDIR.y,0.0);
    vec3 blue=mix(vec3(.51,.72,.80),vec3(.12,.42,.61),pow(up,.5));
    vec2 p=EYEDIR.xz/(up+.22)*2.4;
    float cloud=noise(p)*.55+noise(p*2.1)*.25+noise(p*4.3)*.13+noise(p*8.7)*.07;
    float coverage=smoothstep(.48,.68,cloud)*smoothstep(.02,.18,up);
    COLOR=mix(blue,vec3(.96,.95,.89),coverage);
}
