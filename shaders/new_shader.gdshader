shader_type canvas_item;

// color to be removed
uniform vec4 target_color : source_color = vec4(1.0, 0.0, 1.0, 1.0);
// color difference tolerance
uniform float tolerance : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // distance between pixel color and target color
    float diff = distance(tex.rgb, target_color.rgb);

    if (diff <= tolerance) {
        // makes it transparent
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        COLOR = tex;
    }
}
