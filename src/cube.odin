package main

CUBE_VERTICES := []f32 {
    // FRONT FACE
    -0.5, -0.5, 0.5,
     0.5, -0.5, 0.5,
     0.5,  0.5, 0.5,
    -0.5,  0.5, 0.5,

    // REAR FACE
    -0.5, -0.5, -0.5,
    -0.5,  0.5, -0.5,
     0.5,  0.5, -0.5,
     0.5, -0.5, -0.5,

    // LEFT FACE
    -0.5, -0.5, -0.5,
    -0.5, -0.5,  0.5,
    -0.5,  0.5,  0.5,
    -0.5,  0.5, -0.5,

    // RIGHT FACE
    0.5, -0.5, -0.5,
    0.5,  0.5, -0.5,
    0.5,  0.5,  0.5,
    0.5, -0.5,  0.5,

    // TOP FACE
    -0.5,  0.5, -0.5,
    -0.5,  0.5,  0.5,
     0.5,  0.5,  0.5,
     0.5,  0.5, -0.5,

    // BOTTOM FACE
    -0.5, -0.5, -0.5,
     0.5, -0.5, -0.5,
     0.5, -0.5,  0.5,
    -0.5, -0.5,  0.5,
}

CUBE_INDICES := []u32 {
    // FRONT FACE
    0, 1, 2, 2, 3, 0,

    // REAR FACE
    4, 5, 6, 6, 7, 4,

    // LEFT FACE
    8, 9, 10, 10, 11, 8,

    // RIGHT FACE
    12, 13, 14, 14, 15, 12,

    // TOP FACE
    16, 17, 18, 18, 19, 16,

    // BOTTOM FACE
    20, 21, 22, 22, 23, 20,
}