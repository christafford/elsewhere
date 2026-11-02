shader_type sky;
// Fixed high cloud layer: art direction only, no weather/time-of-day system.
uniform vec4 horizon_color : source_color = vec4(.51,.72,.80,1.0);
uniform vec4 zenith_color : source_color = vec4(.12,.42,.61,1.0);
uniform vec4 cloud_color : source_color = vec4(.96,.95,.89,1.0);
#include "res://scripts/village_noise.gdshaderinc"
void sky() {
    float up=max(EYEDIR.y,0.0);
    vec3 blue=mix(horizon_color.rgb,zenith_color.rgb,pow(up,.5));
    highp vec2 p=EYEDIR.xz/(up+.22)*2.4;
    float cloud=noise(p)*.55+noise(p*2.1)*.25+noise(p*4.3)*.13+noise(p*8.7)*.07;
    float coverage=smoothstep(.48,.68,cloud)*smoothstep(.02,.18,up);
    COLOR=mix(blue,cloud_color.rgb,coverage);
}
