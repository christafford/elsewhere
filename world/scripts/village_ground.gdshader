shader_type spatial;
// Original circulation surface, in meter UVs. Final material curation is P22-T05.
uniform float path_half_width = 2.0;
uniform vec4 turf_color : source_color = vec4(0.28, 0.35, 0.22, 1.0);
uniform vec4 square_color : source_color = vec4(0.42, 0.41, 0.37, 1.0);
uniform vec4 path_color : source_color = vec4(0.27, 0.29, 0.26, 1.0);
void fragment() {
    vec2 square_distance = abs(UV) - vec2(12.0, 10.0);
    float square = 1.0 - smoothstep(-0.015, 0.015, max(square_distance.x, square_distance.y));
    float apron = 1.0 - smoothstep(-0.015, 0.015, max(square_distance.x + 0.55, square_distance.y + 0.55));
    float paving = max(square, 1.0 - smoothstep(path_half_width - 0.06, path_half_width + 0.06, COLOR.r * 8.0));
    vec2 course = UV / vec2(0.75, 0.50);
    course.x += mod(floor(course.y), 2.0) * 0.5;
    vec2 edge = abs(fract(course) - 0.5);
    float footprint = max(fwidth(course.x), fwidth(course.y));
    float joint = smoothstep(0.48 - footprint, 0.50 + footprint, max(edge.x, edge.y));
    vec3 stone = mix(path_color.rgb, square_color.rgb, apron);
    stone *= 1.0 - 0.23 * joint;
    ALBEDO = mix(turf_color.rgb, stone, paving);
    ROUGHNESS = 0.92;
}
