shader_type spatial;
// Original weathered surfaces for reference 2, in projected meter UVs.
uniform vec4 base_color : source_color = vec4(.4,.4,.35,1);
uniform int surface_kind = 0; // plaster, wood, stone, slate, leaf, metal, tiles, water, carved stone
uniform float surface_roughness = .9;
uniform bool use_photo = false;
uniform float photo_scale = 1.0;
uniform sampler2D diff_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D nor_gl_texture : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rough_texture : filter_linear_mipmap_anisotropic, repeat_enable;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
float detail(vec2 p) {
    if(surface_kind==1) {
        vec2 planks=vec2(p.x/.23,p.y/2.4);
        float seam=smoothstep(.015,.08,min(fract(planks.x),1.0-fract(planks.x)));
        return seam*(.32+.27*noise(p*vec2(75,2))+.2*noise(p*vec2(180,6))+.21*hash(floor(planks)));
    }
    if(surface_kind==2 || surface_kind==3) {
        vec2 c=p/(surface_kind==2 ? vec2(.48,.25) : vec2(.27,.2));
        c.x+=mod(floor(c.y),2.0)*.5;
        c+=vec2(noise(p*8.0),noise(p*7.0+3.0))*.07;
        vec2 edge=min(fract(c),1.0-fract(c));
        float joint=smoothstep(.015,.09,min(edge.x,edge.y));
        return joint*(.35+.3*hash(floor(c))+.35*noise(p*36.0));
    }
    return .45*noise(p*3.0)+.3*noise(p*19.0)+.25*noise(p*85.0);
}
void fragment() {
    float h=detail(UV);
    float contrast=surface_kind==1 ? .55 : .4;
    ALBEDO=base_color.rgb*(1.0-contrast+contrast*h);
    // Broad damp stains sit below the fine pores/grain.
    if(surface_kind<4) ALBEDO*=.72+.28*noise(UV*vec2(.65,1.2));
    ROUGHNESS=surface_roughness;
    if(surface_kind==4) {
        ALBEDO=base_color.rgb*(.86+.14*noise(UV*18.0));
        BACKLIGHT=base_color.rgb*.35;
        ROUGHNESS=.9;
    }
    // Carved fountain bowls/caps are solid stone, without wall-sized mortar lines.
    if(surface_kind==8) {
        ALBEDO=base_color.rgb*(.78+.16*noise(UV*3.0)+.06*noise(UV*65.0));
    }
    if(surface_kind<4 || surface_kind==6 || surface_kind==8) {
        float e=.004;
        vec2 d=vec2(detail(UV+vec2(e,0)),detail(UV+vec2(0,e)))-h;
        NORMAL_MAP=normalize(vec3(-d*.85,1))*.5+.5;
    }
    if(use_photo) {
        vec2 uv=UV*photo_scale;
        vec3 photo=texture(diff_texture,uv).rgb;
        // Preserve the selected gray/warm finish while keeping the scan's wear.
        float luminance=dot(photo,vec3(.2126,.7152,.0722));
        ALBEDO=base_color.rgb*clamp(luminance*(surface_kind==1 ? 1.9 : 1.45),.3,.95);
        NORMAL_MAP=texture(nor_gl_texture,uv).rgb;
        NORMAL_MAP_DEPTH=surface_kind==1 ? .55 : .35;
        ROUGHNESS=clamp(texture(rough_texture,uv).r,.65,1.0);
    }
    if(surface_kind==7) {
        float wave=sin(UV.x*31.0+TIME*2.5)*cos(UV.y*24.0-TIME*1.7);
        ALBEDO=base_color.rgb*(.85+.15*wave);
        NORMAL_MAP=normalize(vec3(.12*cos(UV.x*31.0+TIME*2.5),.12*sin(UV.y*24.0-TIME*1.7),1))*.5+.5;
        ROUGHNESS=.24;
        SPECULAR=.65;
    }
}
