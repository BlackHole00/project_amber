package vx_lib_platform

import "core:log"

@(private)
extension_depends_on_any :: proc(extension: Platform_Extension, others: []Platform_Extension_Identifier) -> bool {
    for extension_dependency in extension.dependencies {
        for ext in others {
            if extension_dependency == ext do return true
        }
    }

    return false
}

@(private)
extension_is_dependant_of_any :: proc(extension: Platform_Extension, others: []Platform_Extension_Identifier) -> bool {
    for extension_dependency in extension.dependants {
        for ext in others {
            if extension_dependency == ext do return true
        }
    }

    return false
}

@(private)
extension_depends_on_itself :: proc(extension: Platform_Extension) -> bool {
    return extension_depends_on_any(extension, []Platform_Extension_Identifier { extension.name })
}

@(private)
extension_is_dependant_of_itself :: proc(extension: Platform_Extension) -> bool {
    return extension_is_dependant_of_any(extension, []Platform_Extension_Identifier { extension.name })
}

@(private)
check_for_preliminary_validity :: proc() -> bool {
    for ex in PLATFORM_INSTANCE.extensions {
        for dependency in ex.dependencies {
            if !platform_extension_exists(dependency) {
                log.fatal("Extension", ex.name, "references dependency", dependency, "which does not exists. Aborting!")

                return false
            }
        }

        for dependant in ex.dependants {
            if !platform_extension_exists(dependant) {
                log.fatal("Extension", ex.name, "references dependant", dependant, "which does not exists. Aborting!")

                return false
            }
        }
    }

    return true
}

@(private)
platform_resolve_update_list :: proc() -> bool {
    resolved := make(map[Platform_Extension_Identifier]bool)
    defer delete(resolved)

    PLATFORM_INSTANCE.extensions_update_list = make([]uint, len(PLATFORM_INSTANCE.extensions))
    resolved_count := 0

    if !check_for_preliminary_validity() do return false

    for resolved_count < len(PLATFORM_INSTANCE.extensions) {
        resolved_dependency_in_cycle := false

        for ex, i in PLATFORM_INSTANCE.extensions {
            if ex.name in resolved {
                continue
            }

            // Check for self-dependencies
            if extension_depends_on_itself(ex) {
                log.fatal("Platform Extension", ex.name, "depends on itself. Aborting.")

                return false
            }
            if (extension_is_dependant_of_itself(ex)) {
                log.fatal("Platform Extension", ex.name, "is dependant of itself. Aborting.")

                return false
            }

            // Check for dependants
            for dependant in ex.dependants {
                if dependant in resolved {
                    log.fatal("Dependant", dependant, "of", ex.name, "is already in the resolved list. This should not be possible and it's a bug. You should not see this message. Aborting!")

                    return false
                }
            }

            dependants_ok := true
            for possible_dependant in PLATFORM_INSTANCE.extensions {
                if extension_is_dependant_of_any(possible_dependant, { ex.name }) && possible_dependant.name not_in resolved {
                    dependants_ok = false
                }
            }

            // Check for dependencies
            dependencies_ok := true
            for dependency in ex.dependencies {
                if dependency not_in resolved do dependencies_ok = false
            }

            if dependencies_ok && dependants_ok {
                PLATFORM_INSTANCE.extensions_update_list[resolved_count] = (uint)(i)
                resolved_count += 1
                resolved[ex.name] = true

                resolved_dependency_in_cycle = true
            }
        }

        // If none of the extensions have been resolved in this cycle, then a cycle is present.
        if !resolved_dependency_in_cycle {
            log.fatal("Dependency cycle detected. Aborting!")

            return false
        }
    }

    return true
}