shader_type spatial;

uniform float grid_size = 1.0;
uniform float line_thickness = 0.04;

uniform vec4 line_color : source_color = vec4(0.62, 0.62, 0.62, 1.0);
uniform vec4 fill_color : source_color = vec4(0.31, 0.52, 1.0, 1.0);

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Center grid on 0,0,0 for X and Z only
    vec3 offset_pos = world_pos - vec3(grid_size * 0.5, 0.0, grid_size * 0.5);

    // Use only X and Z for grid coordinates
    vec2 grid_coords = offset_pos.xz / grid_size;

    float line_x = smoothstep(0.0, line_thickness, abs(fract(grid_coords.x) - 0.5));
    float line_z = smoothstep(0.0, line_thickness, abs(fract(grid_coords.y) - 0.5));

    float grid = min(line_x, line_z);

    vec4 color = mix(line_color, fill_color, grid);
    ALBEDO = color.rgb;
}
