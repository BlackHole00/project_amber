#include <metal_stdlib>
using namespace metal;

struct v2f {
	float4 position [[position]];
	half3 color;
};

v2f vertex vertex_main(uint vertex_id                        [[vertex_id]],
					   device const float4x4& 	   u_model	 [[buffer(0)]],
					   device const float4x4& 	   u_view	 [[buffer(1)]],
					   device const float4x4& 	   u_proj	 [[buffer(2)]],
					   device const packed_float3* positions [[buffer(3)]]) {
	v2f o;
	o.position = u_proj * u_view * float4(positions[vertex_id], 1.0);
	//o.position = float4(positions[vertex_id] + u_position, 1.0);
	o.color = half3(1.0, 0.0, 0.0);
	return o;
}

half4 fragment fragment_main(v2f in [[stage_in]]) {
	return half4(in.color, 1.0);
}