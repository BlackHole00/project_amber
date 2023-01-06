__kernel void colorify(write_only image2d_t out, const int width, const int height) {
    int x = get_global_id(0);
    int y = get_global_id(1);

    if (x < width && y < height) {
        write_imagef(out, (int2)(x, y), (float4)(
            1.0 - x / (float)(width),
            1.0 - y / (float)(height),
            1.0 - x * y / (float)(width * height),
            1.0
        ));
    }
}