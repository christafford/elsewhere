shader_type spatial;
render_mode unshaded, fog_disabled;
// Input is already client sRGB. No source_color conversion before this lookup.
uniform sampler2D client_pixels : filter_linear, repeat_disable;
uniform sampler2D inverse_tonemap : filter_linear, repeat_disable;
void fragment() {
    vec4 pixel = texture(client_pixels, UV);
    vec3 color = pixel.rgb * pixel.a; // Transparent client margins over black.
    ALBEDO = vec3(
        texture(inverse_tonemap, vec2((color.r * 255.0 + 0.5) / 256.0, 0.5)).r,
        texture(inverse_tonemap, vec2((color.g * 255.0 + 0.5) / 256.0, 0.5)).r,
        texture(inverse_tonemap, vec2((color.b * 255.0 + 0.5) / 256.0, 0.5)).r);
    // The LUT stores Compatibility's pre-tonemap sRGB albedo. Forward+ works
    // in linear light; apply the same conversion before its Filmic tonemapper.
    if (!OUTPUT_IS_SRGB) {
        ALBEDO = ALBEDO * (ALBEDO * (ALBEDO * 0.305306011 + 0.682171111) + 0.012522878);
    }
}
