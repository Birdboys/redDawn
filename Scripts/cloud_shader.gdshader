shader_type spatial;
render_mode vertex_lighting;
uniform sampler2D noise1;
uniform sampler2D noise2;
uniform sampler2D noise3;
const float noise_speed = 0.002;
uniform float noise_strength = 40.0;

float get_noise(vec2 uv) {
	float offset = 0.0;
	offset = offset + texture(noise1, uv).r;
	offset = offset + texture(noise1, uv).r*0.5;
	offset = offset + texture(noise1, uv).r*0.25;
	return offset;
}
vec3 getNormal(vec2 uv, float texelSize) {
	float t = get_noise(uv + vec2(texelSize * vec2(0.0, -1.0))) * noise_strength;
	float r = get_noise(uv + vec2(texelSize * vec2(1.0, 0.0))) * noise_strength;
	float l = get_noise(uv + vec2(texelSize * vec2(-1.0, 0.0))) * noise_strength;
	float b = get_noise(uv + vec2(texelSize * vec2(0.0, 1.0))) * noise_strength;
	//float t = texture(height_map, uv + vec2(texelSize * vec2(0.0, -1.0))).r * height_scale;
	//float r = texture(height_map, uv + vec2(texelSize * vec2(1.0, 0.0))).r * height_scale;
	//float l = texture(height_map, uv + vec2(texelSize * vec2(-1.0, 0.0))).r * height_scale;
	//float b = texture(height_map, uv + vec2(texelSize * vec2(0.0, 1.0))).r * height_scale;
	return -normalize(vec3(2.0 * (r - l), 2.0 * (b - t), -4.0));
}
void vertex() {
  vec2 noise_cord = vec2(UV.x+(TIME*noise_speed), UV.y+(TIME*noise_speed));
  float height = get_noise(noise_cord);
  VERTEX.y = noise_strength * height;
  COLOR.xyz = vec3(height);
  //NORMAL = getNormal(noise_cord,  1.0 / float(textureSize(noise1, 0).x));
}
void fragment() {
  ALBEDO = COLOR.xyz;
}


