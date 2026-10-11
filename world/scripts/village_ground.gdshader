shader_type spatial;
// Pale irregular paving and a radial fountain surround on the existing ground.
uniform float path_half_width = 2.0;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
void fragment() {
    vec2 border=abs(UV-vec2(0,-1))-vec2(14,12);
    float square=1.0-smoothstep(-.06,.06,max(border.x,border.y));
    float paving=max(square,1.0-smoothstep(path_half_width-.08,path_half_width+.08,COLOR.r*8.0));
    vec2 course=UV/vec2(.47,.32);
    vec2 fountain=UV-vec2(-5,-4);
    float radius=length(fountain);
    if(radius<4.8) {
        float ring=floor(radius/.34);
        float stones=max(8.0,floor(6.283185*(ring+.5)*.34/.46));
        course=vec2((atan(fountain.y,fountain.x)/6.283185+.5)*stones,radius/.34);
    }
    course.x+=mod(floor(course.y),2.0)*.5;
    vec2 cell=floor(course);
    vec2 edge=min(fract(course),1.0-fract(course));
    float aa=max(fwidth(course.x),fwidth(course.y));
    float joint=smoothstep(.02-aa,.05+aa,min(edge.x,edge.y));
    float stone_variation=hash(cell);
    float grain=noise(UV*19.0)*.045+noise(UV*2.0)*.055;
    vec3 stone=mix(vec3(.31,.29,.25),vec3(.44,.41,.35),stone_variation)+grain;
    stone*=mix(.69,1.0,joint);
    vec3 grass=mix(vec3(.095,.16,.048),vec3(.18,.25,.075),noise(UV*1.8));
    grass*=.88+.12*noise(UV*30.0);
    ALBEDO=mix(grass,stone,paving);
    ROUGHNESS=.93;
}
