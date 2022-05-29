struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>,
};

@stage(vertex)
fn vs_main(@location(0) position: vec3<f32>, @location(1) uv: vec2<f32>) -> VertexOutput {
    var output: VertexOutput;

    output.position = vec4<f32>(position.xyz, 1.0);
    output.uv = uv;

    return output;
}

@group(0) @binding(0)
var t_diffuse: texture_2d<f32>;

@group(0) @binding(1)
var s_diffuse: sampler;

@stage(fragment)
fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
    return textureSample(t_diffuse, s_diffuse, input.uv);
}


//struct VertexOutput {
//    @builtin(position) position: vec4<f32>,
//    @location(0) color: vec3<f32>,
//};
//
//@stage(vertex)
//fn vs_main(@location(0) position: vec3<f32>, @location(1) color: vec3<f32>) -> VertexOutput {
//    var output: VertexOutput;
//
//    output.position = vec4<f32>(position.xyz, 1.0);
//    output.color = color;
//
//    return output;
//}
//
//@stage(fragment)
//fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
//    return vec4<f32>(input.color.xyz, 1.0);
//}
