shader_type canvas_item;

uniform sampler2D xShift;
uniform sampler2D yShift;

vec2 rotateUV(vec2 uv, float rotation) {
    float sine = sin(rotation);
    float cosine = cos(rotation);

    uv.x = uv.x * cosine - uv.y * sine;
    uv.y = uv.x * sine + uv.y * cosine;

    return uv;
}

void fragment() {
	vec2 shift;
	shift.x = (texture(xShift, UV).r - 0.5);
	shift.y = (texture(yShift, UV).r - 0.5);
//	shift = normalize(shift);
	shift *= 0.3;
	shift = rotateUV(shift, TIME);
	COLOR = texture(TEXTURE, UV + shift);
}