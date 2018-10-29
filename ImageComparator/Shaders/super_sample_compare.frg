#version 300 core
precision highp float;

out vec4 FragColor;
in vec2 TexCoords;

uniform float width;
uniform float height;
uniform sampler2D img1;
uniform sampler2D img2;

void main()
{
    vec3 diff = vec3(0, 0, 0);

    for(float i = 0.0; i < width; i += 2.0)
    {
        for(float j = 0.0; j < height; j+= 2.0)
        {
            float x = i + 0.5;
            float y = j + 0.5;
            vec2 coords = vec2(x / width, y / height);
            vec4 sample1 = texture(img1, coords);
            vec4 sample2 = texture(img2, coords);
            diff += abs(sample1.rgb - sample2.rgb);
        }
    }

    FragColor = vec4(diff, 1.0);
}
