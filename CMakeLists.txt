cmake_minimum_required(VERSION 3.16)
project(dbg LANGUAGES NONE)

# A fresh configuration installs to $HOME/opt/<project>. HOME is expanded
# here, so the cache holds an absolute path. scripts/install can pass
# another prefix for one run. On CMake 3.29 and newer, a new build
# directory also takes CMAKE_INSTALL_PREFIX from the environment. A later
# configure keeps the cached prefix.
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT
   AND (CMAKE_VERSION VERSION_LESS 3.29
        OR NOT DEFINED ENV{CMAKE_INSTALL_PREFIX}))
    if("$ENV{HOME}" STREQUAL "")
        message(FATAL_ERROR
            "Cannot select the default install prefix: HOME is not set. "
            "Set HOME to an absolute path.")
    endif()
    if(NOT IS_ABSOLUTE "$ENV{HOME}")
        message(FATAL_ERROR
            "Cannot select the default install prefix: HOME must be absolute "
            "(got '$ENV{HOME}').")
    endif()
    get_filename_component(install_home "$ENV{HOME}" ABSOLUTE)
    set(CMAKE_INSTALL_PREFIX "${install_home}/opt/${PROJECT_NAME}" CACHE PATH
        "Install path prefix, prepended onto install directories." FORCE)
    set(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT FALSE)
endif()

# Binaries land next to the checkout, as they do for the compiler.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")

# The test target is defined after the other targets. It builds the
# program and the test drivers, then runs CTest.
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

# <string> and <vector> define their methods in every translation
# unit that includes them. The copies match. scpp does not accept a
# linker flag, so this wrapper is the Clang scpp links with, plus
# --allow-multiple-definition, and the link keeps one copy.
find_program(DBG_CLANGXX NAMES clang++ HINTS /usr/lib/llvm-22/bin)
if(NOT DBG_CLANGXX)
    message(FATAL_ERROR "clang++ was not found")
endif()
set(DBG_LINK_CLANG "${CMAKE_BINARY_DIR}/link-clang")
file(WRITE "${DBG_LINK_CLANG}"
"#!/bin/sh
exec \"${DBG_CLANGXX}\" -Wl,--allow-multiple-definition \"$@\"
")
execute_process(COMMAND chmod +x "${DBG_LINK_CLANG}")

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

set(DBG_HEADERS
    src/util.shpp
    src/args.shpp
    src/mi.shpp
    src/settings.shpp
    src/source.shpp
    src/compile.shpp
    src/launch.shpp
    src/session.shpp
    src/ui.shpp)

# Each list is one link. A later list repeats an earlier one only
# by naming the whole group, so a .scpp is never passed twice.
set(DBG_UTIL src/util.scpp)
set(DBG_ARGS src/args.scpp ${DBG_UTIL})
set(DBG_MI src/mi.scpp ${DBG_UTIL})
set(DBG_SETTINGS src/settings.scpp ${DBG_ARGS})
set(DBG_SOURCE src/source.scpp ${DBG_UTIL})
set(DBG_COMPILE src/compile.scpp ${DBG_UTIL})
set(DBG_LAUNCH src/launch.scpp ${DBG_ARGS})
set(DBG_SESSION
    src/session.scpp
    src/mi.scpp
    src/settings.scpp
    src/args.scpp
    src/util.scpp)
set(DBG_APP
    src/ui.scpp
    src/launch.scpp
    src/session.scpp
    src/compile.scpp
    src/source.scpp
    src/settings.scpp
    src/args.scpp
    src/mi.scpp
    src/util.scpp)
set(DBG_PROGRAM_SOURCES src/dbg.scpp ${DBG_APP})

set(DBG_PROGRAM "${CMAKE_SOURCE_DIR}/bin/dbg")

# sources is one semicolon list. Extra arguments are scpp link flags.
# The dbg target is the only one in the default build.
function(add_scpp_program target output sources)
    set(inputs "")
    set(depends "${SCPP}" "${DBG_LINK_CLANG}")
    foreach(rel IN LISTS sources)
        if(NOT rel MATCHES "\\.")
            message(FATAL_ERROR "source path is not a file: '${rel}'")
        endif()
        if("${CMAKE_SOURCE_DIR}/${rel}" IN_LIST inputs)
            message(FATAL_ERROR "duplicate source: ${rel}")
        endif()
        list(APPEND inputs "${CMAKE_SOURCE_DIR}/${rel}")
        list(APPEND depends "${CMAKE_SOURCE_DIR}/${rel}")
    endforeach()
    foreach(rel IN LISTS DBG_HEADERS)
        list(APPEND depends "${CMAKE_SOURCE_DIR}/${rel}")
    endforeach()
    # scpp names each object from the source base name. Parallel
    # targets share sources, so each link uses its own directory.
    # Make creates that directory before the recipe, so it has to
    # exist at configure time.
    set(work "${CMAKE_BINARY_DIR}/work-${target}")
    file(MAKE_DIRECTORY "${work}")
    add_custom_command(
        OUTPUT "${output}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory
            "${CMAKE_SOURCE_DIR}/bin"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${work}"
        COMMAND "${CMAKE_COMMAND}" -E env
            "SMALLCPP_CLANGXX=${DBG_LINK_CLANG}"
            "${SCPP}" ${SCPP_FLAGS} ${ARGN}
            -o "${output}"
            ${inputs}
        WORKING_DIRECTORY "${work}"
        DEPENDS ${depends}
        COMMENT "Compiling ${target}"
        VERBATIM)
    if(target STREQUAL "dbg")
        add_custom_target(${target} ALL DEPENDS "${output}")
    else()
        add_custom_target(${target} DEPENDS "${output}")
    endif()
endfunction()

add_scpp_program(dbg "${DBG_PROGRAM}" "${DBG_PROGRAM_SOURCES}" ${DBG_LINK})

# Copy the built application. This checkout is not the compiler, so the
# install does not write a config file. LIBDIR is set first because this
# project enables no language, and GNUInstallDirs warns otherwise.
# Test programs are not installed.
if(NOT DEFINED CMAKE_INSTALL_LIBDIR)
    set(CMAKE_INSTALL_LIBDIR "lib" CACHE PATH "Object code libraries")
endif()
include(GNUInstallDirs)
install(PROGRAMS "${DBG_PROGRAM}"
    DESTINATION "${CMAKE_INSTALL_BINDIR}")

add_scpp_program(test_mi "${CMAKE_SOURCE_DIR}/bin/test_mi"
    "tests/test_mi.scpp;${DBG_MI}")
add_scpp_program(test_args "${CMAKE_SOURCE_DIR}/bin/test_args"
    "tests/test_args.scpp;${DBG_ARGS}")
add_scpp_program(test_settings "${CMAKE_SOURCE_DIR}/bin/test_settings"
    "tests/test_settings.scpp;${DBG_SETTINGS}")
add_scpp_program(test_source "${CMAKE_SOURCE_DIR}/bin/test_source"
    "tests/test_source.scpp;${DBG_SOURCE}")
add_scpp_program(test_open "${CMAKE_SOURCE_DIR}/bin/test_open"
    "tests/test_open.scpp;${DBG_SESSION}")
add_scpp_program(test_session "${CMAKE_SOURCE_DIR}/bin/test_session"
    "tests/test_session.scpp;${DBG_SESSION};src/compile.scpp")
add_scpp_program(test_launch "${CMAKE_SOURCE_DIR}/bin/test_launch"
    "tests/test_launch.scpp;${DBG_LAUNCH}")
add_scpp_program(test_ui "${CMAKE_SOURCE_DIR}/bin/test_ui"
    "tests/test_ui.scpp;${DBG_APP}"
    ${DBG_LINK})

add_subdirectory(tests)

# CMake reserves the target name "test" (CMP0037). The built-in
# target can depend only on all, so an excluded driver stays out of
# `build test`. OLD keeps this project target, and generation leaves
# it in place. It depends on the drivers and on every target the
# default build includes, then runs CTest.
function(attach_test_drivers)
    set(CMAKE_WARN_DEPRECATED OFF)
    cmake_policy(SET CMP0037 OLD)
    add_custom_target(test
        COMMAND ${CMAKE_CTEST_COMMAND} --force-new-ctest-process $(ARGS)
        USES_TERMINAL)

    set(pending "${CMAKE_SOURCE_DIR}")
    set(ordinary "")
    while(pending)
        list(POP_FRONT pending dir)
        get_property(targets DIRECTORY "${dir}"
            PROPERTY BUILDSYSTEM_TARGETS)
        get_property(subs DIRECTORY "${dir}" PROPERTY SUBDIRECTORIES)
        list(APPEND pending ${subs})
        list(APPEND ordinary ${targets})
    endwhile()

    foreach(name IN LISTS ordinary)
        if(name STREQUAL "test")
            continue()
        endif()
        get_target_property(excluded ${name} EXCLUDE_FROM_ALL)
        if(excluded)
            continue()
        endif()
        add_dependencies(test ${name})
    endforeach()
    foreach(name IN LISTS ARGN)
        if(NOT TARGET ${name})
            message(FATAL_ERROR
                "Test driver '${name}' is not a target")
        endif()
        add_dependencies(test ${name})
    endforeach()
endfunction()

attach_test_drivers(
    test_mi
    test_args
    test_settings
    test_source
    test_open
    test_session
    test_launch
    test_ui)
