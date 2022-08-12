#version 330 core

uniform sampler2D uTexture;

in vec2 vUv;
in float vDist;

out vec4 FragColor;

const bool INVERT = true;
const bool KERNEL = true;

const float offset = 1.0 / 300.0;  

void main() {
    if (INVERT) {
        FragColor = (1.0 - texture(uTexture, vUv)) * vec4(vDist, vDist, vDist, 1.0);
    } else {
        FragColor = (texture(uTexture, vUv)) * vec4(vDist, vDist, vDist, 1.0);
    }

    vec2 offsets[9] = vec2[](
        vec2(-offset,  offset), // top-left
        vec2( 0.0f,    offset), // top-center
        vec2( offset,  offset), // top-right
        vec2(-offset,  0.0f),   // center-left
        vec2( 0.0f,    0.0f),   // center-center
        vec2( offset,  0.0f),   // center-right
        vec2(-offset, -offset), // bottom-left
        vec2( 0.0f,   -offset), // bottom-center
        vec2( offset, -offset)  // bottom-right    
    );

    if (KERNEL) {
        float kernel[9] = float[](
            2.0 / 16, 4.0 / 16, 2.0 / 16,
            4.0 / 16, 2.0 / 16, 4.0 / 16,
            2.0 / 16, 4.0 / 16, 2.0 / 16 
        );
        
        vec3 sampleTex[9];
        for(int i = 0; i < 9; i++)
        {
            if (INVERT) {
                sampleTex[i] = vec3((1.0 - texture(uTexture, vUv.st + offsets[i])) * vec4(vDist, vDist, vDist, 1.0));
            } else {
                sampleTex[i] = vec3((texture(uTexture, vUv.st + offsets[i])) * vec4(vDist, vDist, vDist, 1.0));
            }
        }
        vec3 col = vec3(0.0);
        for(int i = 0; i < 9; i++)
            col += sampleTex[i] * kernel[i];
        
        FragColor = vec4(col, 1.0);
    }
}