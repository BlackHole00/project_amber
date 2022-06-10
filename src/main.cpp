#include <stdio.h>
#include <vx_utils/utils.h>
#include <vx_utils/loggers/stream_logger.h>

#include <math.h>


typedef struct {
    float position[3] = { 1.0, 0.0, 0.0};
    float uv[2] = { 1.0, 0.0 };
} Vertex;
VX_CREATE_TO_STRING(Vertex,
    snprintf(BUFFER, len(BUFFER), "Vertex { { %f, %f, %f }, { %f, %f } }", PTR->position[0], PTR->position[1], PTR->position[2], PTR->uv[0], PTR->uv[1]);
)

const char* NAMES[5] = {
    "Nick",
    "Test",
    "Something",
    "Ahahahaha",
    "IdkMan!!!"
};

int main() {
    vx::stream_logger_init(stdout, vx::LogMessageLevel::DEBUG);
    vx::allocator_stack_init();

    VX_DEFER(vx::stream_logger_free());
    VX_DEFER(vx::allocator_stack_free());

    vx::Slice<const char*> slice = vx::slice_new(NAMES, 5);
    slice[4] = "Hellow!";

    printf("%d\n", vx::default_value<int>());
    Vertex vertex = vx::default_value<Vertex>();

    char buffer[100];
    vx::to_string(&vertex, vx::slice_new(buffer, 100));
    printf("%s\n", buffer);

    vx::Vector<f32> vec = vx::vector_new<f32>();
    vx::Vector<f32> vec2 = vx::vector_new<f32>();
    VX_DEFER(vx::vector_free<f32>(&vec));
    VX_DEFER(vx::vector_free<f32>(&vec2));

    vx::vector_push<f32>(&vec, 10);
    vx::vector_push<f32>(&vec, 20);
    vx::vector_push<f32>(&vec, 30);
    vx::vector_push<f32>(&vec, 40);

    vx::clone(&vec, &vec2);

    printf("vector len: %lld\n", vx::len(&vec));
    for (usize i = 0; i < vec.length; i++) {
        printf("%f %f\n", vec[i], vec2[i]);
    }
    printf("vector as slice\n");
    vx::Slice<f32> vec2_slice = vx::as_slice(&vec2);
    for (usize i = 0; i < len(vec2_slice); i++) {
        printf("%f %f\n", vec2_slice[i], vec2_slice[i]);
    }

    for (usize i = 0; i < VX_ARRAY_ELEMENT_COUNT(NAMES); i++) {
        printf("%s: %llu\n", NAMES[i], vx::hash(NAMES[i]));
    }

    vx::HashTable<int, const char*> hash_table = vx::hash_table_new<int, const char*>();
    VX_DEFER(vx::hash_table_free(&hash_table));
    vx::hash_table_set(&hash_table, "Hi!", 1);
    vx::hash_table_set(&hash_table, "Ho!", 2);
    vx::hash_table_set(&hash_table, "Hi!", 3);
    vx::hash_table_set(&hash_table, "Ho!", 4);
    vx::hash_table_set(&hash_table, "Hi!", 5);

    printf("table len: %lld\n", vx::len(&hash_table));
    printf("%d\n", *vx::hash_table_get(&hash_table, "Hi!"));
    printf("%d\n", *vx::hash_table_get(&hash_table, "Ho!"));

    vx::hash_table_remove(&hash_table, "Hi!");

    vx::HashTable<int, const char*> hash_table2 = vx::hash_table_new<int, const char*>();
    VX_DEFER(vx::hash_table_free(&hash_table2));
    vx::clone(&hash_table, &hash_table2);

    vx::_hash_table_dbg(&hash_table2);
}

