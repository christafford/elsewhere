shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
void fragment() {
    ALBEDO = COLOR.rgb;
    ALPHA = COLOR.a * smoothstep(0.0,.32,UV.x) * smoothstep(0.0,.32,1.0-UV.x);
}
