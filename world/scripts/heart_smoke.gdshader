shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
instance uniform float opacity = 1.0;
instance uniform float smoke_age = 0.0;
void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
    MODELVIEW_MATRIX[0].xyz *= length(MODEL_MATRIX[0].xyz);
    MODELVIEW_MATRIX[1].xyz *= length(MODEL_MATRIX[1].xyz);
}
void fragment() {
    vec2 p = (UV - .5) * 2.8;
    p.y = -p.y + .22;
    // Rounded twin lobes above a tapered tip; soft density makes a smoke heart.
    float x = abs(p.x);
    float lobes = length(vec2(x-.38,p.y-.27))-.48;
    float tip = max(x*.83-p.y*.55-.45,p.y-.3);
    float heart = min(lobes,tip);
    float edge = sin(p.x*19.0+TIME*2.0)*sin(p.y*17.0-TIME)*.018;
    float density = 1.0-smoothstep(-.16,.09+smoke_age*.1,heart+edge);
    ALBEDO = mix(vec3(1.0,.23,.52),vec3(1.0,.8,.88),density*.65);
    ALPHA = density*opacity;
}
