cmake_minimum_required(VERSION 3.16)
project(dbg LANGUAGES NONE)

# Binaries land next to the checkout, as they do for the compiler.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")

# `build test` is `cmake --build build --target test`. That target builds
# the program first, then CTest runs the suite.
set(CMAKE_SKIP_TEST_ALL_DEPENDENCY FALSE)
enable_testing()

# `scpp` on PATH wins. The default install prefix is $HOME/opt/smallcpp.
set(SMALLCPP_DEFAULT_BIN "")
if(IS_ABSOLUTE "$ENV{HOME}")
    set(SMALLCPP_DEFAULT_BIN "$ENV{HOME}/opt/smallcpp/bin")
endif()
if(SCPP AND NOT EXISTS "${SCPP}")
    unset(SCPP CACHE)
endif()
find_program(SCPP NAMES scpp PATHS ${SMALLCPP_DEFAULT_BIN})
if(NOT SCPP)
    unset(SCPP CACHE)
    message(FATAL_ERROR
        "scpp was not found on PATH or in \$HOME/opt/smallcpp/bin. "
        "Install smallcpp and run scripts/setup again.")
endif()

set(SCPP_FLAGS "")
if(CMAKE_BUILD_TYPE STREQUAL "Debug"
        OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    list(APPEND SCPP_FLAGS "-g")
endif()

set(DBG_GTK_LIBS
    smallcpp_gtk
    gtk-4
    gio-2.0
    gobject-2.0
    glib-2.0
    pango-1.0
    pangocairo-1.0
    cairo)
set(DBG_LINK "")
if(IS_ABSOLUTE "$ENV{HOME}"
        AND EXISTS "$ENV{HOME}/opt/smallcpp/lib")
    list(APPEND DBG_LINK -L "$ENV{HOME}/opt/smallcpp/lib")
endif()
foreach(lib IN LISTS DBG_GTK_LIBS)
    list(APPEND DBG_LINK -l "${lib}")
endforeach()

set(DBG_SOURCES
    "${CMAKE_SOURCE_DIR}/src/dbg.scpp"
    "${CMAKE_SOURCE_DIR}/src/ui.scpp"
    "${CMAKE_SOURCE_DIR}/src/launch.scpp"
    "${CMAKE_SOURCE_DIR}/src/session.scpp"
    "${CMAKE_SOURCE_DIR}/src/compile.scpp"
    "${CMAKE_SOURCE_DIR}/src/source.scpp"
    "${CMAKE_SOURCE_DIR}/src/settings.scpp"
    "${CMAKE_SOURCE_DIR}/src/args.scpp"
    "${CMAKE_SOURCE_DIR}/src/mi.scpp"
    "${CMAKE_SOURCE_DIR}/src/util.scpp")

set(DBG_PROGRAM "${CMAKE_SOURCE_DIR}/bin/dbg")

add_custom_command(
    OUTPUT "${DBG_PROGRAM}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory
        "${CMAKE_SOURCE_DIR}/bin"
    COMMAND "${SCPP}" ${SCPP_FLAGS} ${DBG_LINK}
        -o "${DBG_PROGRAM}"
        "${CMAKE_SOURCE_DIR}/src/dbg.scpp"
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    DEPENDS ${DBG_SOURCES} "${SCPP}"
    COMMENT "Compiling src/dbg.scpp"
    VERBATIM)
add_custom_target(dbg ALL DEPENDS "${DBG_PROGRAM}")

function(add_scpp_test name source)
    set(program "${CMAKE_SOURCE_DIR}/bin/${name}")
    add_custom_command(
        OUTPUT "${program}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory
            "${CMAKE_SOURCE_DIR}/bin"
        COMMAND "${SCPP}" ${SCPP_FLAGS} ${ARGN}
            -o "${program}"
            "${CMAKE_SOURCE_DIR}/tests/${source}"
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
        DEPENDS
            "${CMAKE_SOURCE_DIR}/tests/${source}"
            ${DBG_SOURCES}
            "${SCPP}"
        COMMENT "Compiling tests/${source}"
        VERBATIM)
    add_custom_target(${name} ALL DEPENDS "${program}")
endfunction()

add_scpp_test(test_mi test_mi.scpp)
add_scpp_test(test_args test_args.scpp)
add_scpp_test(test_settings test_settings.scpp)
add_scpp_test(test_source test_source.scpp)
add_scpp_test(test_open test_open.scpp)
add_scpp_test(test_session test_session.scpp)
add_scpp_test(test_launch test_launch.scpp)
add_scpp_test(test_ui test_ui.scpp ${DBG_LINK})

add_subdirectory(tests)
