#include "input_helper.h"

namespace vx {

VX_CREATE_INSTANCE(InputHelper, INPUT_HELPER_INSTANCE);

void input_helper_init() {
    if (INPUT_HELPER_INSTANCE_VALID) {
        log(LogMessageLevel::WARN, "Double init of input helper.");

        return;
    }

    INPUT_HELPER_INSTANCE.keyboard.keys = hash_table_new_with_size<KeyState, KeyboardKey>((usize)(KeyboardKey::Count));
    hash_table_set_all_values(&INPUT_HELPER_INSTANCE.keyboard.keys, KeyState { 0 });

    INPUT_HELPER_INSTANCE_VALID = true;
}

void input_helper_free() {
    hash_table_free(&INPUT_HELPER_INSTANCE.keyboard.keys);
}

};