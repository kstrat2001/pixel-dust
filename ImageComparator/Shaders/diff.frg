#version 300 core
precision highp float;

out vec4 FragColor;
in vec2 TexCoords;

uniform sampler2D img1;
uniform sampler2D img2;

void main()
{
    vec4 sample1 = texture(img1, TexCoords);
    vec4 sample2 = texture(img2, TexCoords);
    vec3 diff = abs(vec3(sample1.rgb - sample2.rgb));

    FragColor = vec4(diff, 1.0);
}
