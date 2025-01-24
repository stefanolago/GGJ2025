shader_type canvas_item;

/**
Color to use for the shock.
*/
// uniform vec3 shock_color : source_color = vec3(1.0, 0.0, 0.0);
/**
Initial amplitude of the shock. This will start at this amplitude and
gradually attenuate.
*/
uniform float amplitude = 10.0;
/**
How fast shold it move side to side, more frequency means it'll move more quickly
side to side.
*/
uniform float frequency = 10.0;

void vertex() {
	float exponent = mod(TIME, 0.1);
	VERTEX.x += amplitude * sin(frequency*exponent);
}

/* void fragment() {
	float exponent = mod(TIME, 3.0);
	// vec3 normal_color = texture(TEXTURE, UV).rgb;
	COLOR.rgb = normal_color + shock_color * exp(-3.0*exponent);
} */


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
