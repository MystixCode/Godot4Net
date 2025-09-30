shader_type spatial;
render_mode cull_disabled;

uniform vec3 top_color : source_color = vec3(0.42, 0.69, 0.20);
uniform vec3 bottom_color : source_color = vec3(0.18, 0.35, 0.10);
uniform float mesh_height : hint_range(0.1, 10.0) = 1.0;

// Wind parameters
uniform sampler2D wind_noise : hint_default_white;
uniform float wind_speed : hint_range(0.0, 2.0) = 0.5; // Faster for natural sway
uniform float wind_strength : hint_range(0.0, 2.0) = 0.8;

varying float bottom_to_top;

void vertex() {
    // Get world position
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Y-position for bottom_to_top (base at y=0, tip at y=mesh_height)
    bottom_to_top = clamp(world_pos.y / mesh_height, 0.0, 1.0);

    // Wind sway (horizontal, zero at base)
    float wind = sin(TIME * wind_speed + world_pos.x + world_pos.z); // Sin fallback
    vec2 wind_uv = world_pos.xz * 0.05 + vec2(1.0, 0.5) * TIME * wind_speed * 0.1;
    wind = wind * texture(wind_noise, wind_uv).r; // Noise if set, else sin
    VERTEX += vec3(wind * wind_strength, 0.0, wind * wind_strength) * bottom_to_top;

    // Normals for consistent lighting
    NORMAL = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
    // Color gradient
    ALBEDO = mix(bottom_color, top_color, bottom_to_top);

    // Fix backface lighting
    if (!FRONT_FACING) {
        NORMAL = -NORMAL;
    }
}