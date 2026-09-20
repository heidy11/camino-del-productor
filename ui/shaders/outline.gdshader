shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 32.0) = 2.0;

// Contorno "relleno": revisa varios anillos de muestras entre el borde del
// dibujo y outline_width, no solo un anillo a una distancia fija. Así el
// borde queda pegado a la silueta (sin dejar huecos ni formar un halo/cuadro
// separado del personaje cuando outline_width es grande).
void fragment() {
	vec4 col = texture(TEXTURE, UV);

	if (col.a < 0.5) {
		vec2 texel = vec2(1.0) / vec2(textureSize(TEXTURE, 0));
		const int RINGS = 4;
		const int STEPS = 8;
		float encontrado = 0.0;

		for (int r = 1; r <= RINGS; r++) {
			float dist = outline_width * float(r) / float(RINGS);
			for (int i = 0; i < STEPS; i++) {
				float angulo = float(i) / float(STEPS) * TAU;
				vec2 offset = vec2(cos(angulo), sin(angulo)) * dist * texel;
				encontrado = max(encontrado, texture(TEXTURE, UV + offset).a);
			}
		}

		if (encontrado > 0.5) {
			col = vec4(outline_color.rgb, outline_color.a);
		}
	}

	COLOR = col;
}
