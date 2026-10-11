shader_type spatial;
// Original meter-scale surface detail; no pixels from the owner's reference.
uniform vec4 base_color : source_color = vec4(0.5,0.45,0.35,1.0);
uniform int surface_kind = 0; // plaster, timber, masonry, slate, foliage, metal/water, modeled tiles
uniform float surface_roughness = 0.9;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
float detail(vec2 p) {
    if (surface_kind==1) {
        float grain=noise(p*vec2(36.0,1.1));
        return .55*grain+.3*noise(p*vec2(110.0,4.0))+.15*noise(p*3.0);
    }
    if (surface_kind==2) {
        vec2 c=p/vec2(.52,.29); c.x+=mod(floor(c.y),2.0)*.5;
        vec2 edge=min(fract(c),1.0-fract(c));
        float mortar=smoothstep(.012,.055,min(edge.x,edge.y));
        return mortar*(.6+.25*hash(floor(c))+.15*noise(p*18.0));
    }
    if (surface_kind==3) {
        vec2 c=p/vec2(.32,.24); c.x+=mod(floor(c.y),2.0)*.5;
        vec2 edge=min(fract(c),1.0-fract(c));
        float joint=smoothstep(.008,.035,min(edge.x,edge.y));
        return joint*(.5+.3*hash(floor(c))+.2*noise(p*30.0));
    }
    return .6*noise(p*4.0)+.3*noise(p*28.0)+.1*noise(p*97.0);
}
void fragment() {
    float h=detail(UV);
    float contrast=surface_kind==1 ? .43 : (surface_kind==2 || surface_kind==3 ? .35 : .19);
    ALBEDO=base_color.rgb*(1.0-contrast+contrast*h);
    if (surface_kind==4) { ALBEDO=base_color.rgb; BACKLIGHT=base_color.rgb*.15; }
    ROUGHNESS=surface_roughness;
    if (surface_kind<4 || surface_kind==6) {
        float e=.004;
        float dx=detail(UV+vec2(e,0))-h;
        float dy=detail(UV+vec2(0,e))-h;
        float strength=surface_kind==2 ? .9 : .4;
        NORMAL_MAP=normalize(vec3(-dx*strength,-dy*strength,1.0))*.5+.5;
    }
}
