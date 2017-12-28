// VERTEX SHADER

static const char* ShaderV = STRINGIFY
(

// OBJ Data
attribute vec4 aVertex;
attribute vec3 aNormal;
attribute vec2 aTexture;
attribute vec3 aDelta;
 
// View Matrices
uniform mat4 uProjectionMatrix;
uniform mat4 uModelViewMatrix;
uniform mat3 uNormalMatrix;
 
// Output to Fragment Shader
varying vec3 vNormal;
varying vec2 vTexture;
 
void main(void)
{ 
    vNormal     = uNormalMatrix * aNormal;
    vTexture    = aTexture;
    
    gl_Position = uProjectionMatrix * uModelViewMatrix * (aVertex + 0.2 * vec4(aDelta, 1.0));
}
 
);



