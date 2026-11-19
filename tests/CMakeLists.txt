add_test(NAME mi COMMAND "${CMAKE_SOURCE_DIR}/bin/test_mi")
add_test(NAME args COMMAND "${CMAKE_SOURCE_DIR}/bin/test_args")
add_test(NAME settings COMMAND "${CMAKE_SOURCE_DIR}/bin/test_settings")
add_test(NAME source COMMAND "${CMAKE_SOURCE_DIR}/bin/test_source")
add_test(NAME open COMMAND "${CMAKE_SOURCE_DIR}/bin/test_open")
add_test(
    NAME session
    COMMAND "${CMAKE_SOURCE_DIR}/bin/test_session"
        "${CMAKE_SOURCE_DIR}/tests/fixtures/walk.scpp"
        "${CMAKE_SOURCE_DIR}/tests/fixtures/spin.scpp"
        "${SCPP}")
add_test(NAME launch COMMAND "${CMAKE_SOURCE_DIR}/bin/test_launch")
add_test(
    NAME ui
    COMMAND "${CMAKE_SOURCE_DIR}/bin/test_ui"
        "${CMAKE_SOURCE_DIR}/tests/fixtures/walk.scpp")
set_tests_properties(ui PROPERTIES SKIP_RETURN_CODE 77)

add_test(
    NAME cli_help
    COMMAND ${CMAKE_COMMAND}
        -DPROGRAM=${DBG_PROGRAM}
        -DMODE=help
        -P ${CMAKE_CURRENT_SOURCE_DIR}/ExpectCli.cmake)
add_test(
    NAME cli_option
    COMMAND ${CMAKE_COMMAND}
        -DPROGRAM=${DBG_PROGRAM}
        -DMODE=option
        -P ${CMAKE_CURRENT_SOURCE_DIR}/ExpectCli.cmake)
add_test(
    NAME cli_missing
    COMMAND ${CMAKE_COMMAND}
        -DPROGRAM=${DBG_PROGRAM}
        -DMODE=missing
        -P ${CMAKE_CURRENT_SOURCE_DIR}/ExpectCli.cmake)
