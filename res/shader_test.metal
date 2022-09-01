#include <metal_stdlib>
using namespace metal;

struct v2f {
	float4 position [[position]];
	half3 color;
};

v2f vertex vertex_main(uint vertex_id                        [[vertex_id]],
					   device const packed_float3& u_position[[buffer(0)]],
					   device const packed_float3* positions [[buffer(1)]],
					   device const packed_float3* colors    [[buffer(2)]]) {
	v2f o;
	o.position = float4(positions[vertex_id] + u_position, 1.0);
	o.color = half3(colors[vertex_id]);
	return o;
}

half4 fragment fragment_main(v2f in [[stage_in]]) {
	return half4(in.color, 1.0);
}