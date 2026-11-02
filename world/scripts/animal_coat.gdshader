shader_type spatial;
uniform vec4 coat : source_color = vec4(1.0);
uniform float roughness_value = .86;
instance uniform float char_amount = 0.0;
varying vec3 local_point;
void vertex() { local_point = VERTEX; }
float hash(vec3 p) { return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453); }
void fragment() {
    // Original fine coat variation. No downloaded fur map or animated lighting.
    float grain = hash(floor(local_point*vec3(180.0,90.0,180.0)));
    ALBEDO = coat.rgb * mix(.985,1.015,grain);
    ALBEDO = mix(ALBEDO, vec3(.028,.022,.018) * mix(.7,1.3,grain), char_amount);
    ROUGHNESS = roughness_value;
}
