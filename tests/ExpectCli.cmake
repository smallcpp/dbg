if(NOT DEFINED PROGRAM OR NOT DEFINED MODE)
    message(FATAL_ERROR "cli check is missing a mode")
endif()

if(MODE STREQUAL "help")
    execute_process(
        COMMAND "${PROGRAM}" --help extra
        RESULT_VARIABLE run_status
        OUTPUT_VARIABLE program_output
        ERROR_VARIABLE program_error)
    if(NOT run_status EQUAL 0)
        message(FATAL_ERROR "help exited ${run_status}")
    endif()
    if(NOT program_output MATCHES "^Usage:")
        message(FATAL_ERROR "help wrote '${program_output}'")
    endif()
elseif(MODE STREQUAL "option")
    execute_process(
        COMMAND "${PROGRAM}" --bogus
        RESULT_VARIABLE run_status
        OUTPUT_VARIABLE program_output
        ERROR_VARIABLE program_error)
    if(NOT run_status EQUAL 2)
        message(FATAL_ERROR "option exited ${run_status}")
    endif()
    if(NOT program_error MATCHES "DBG0001")
        message(FATAL_ERROR "option wrote '${program_error}'")
    endif()
elseif(MODE STREQUAL "missing")
    execute_process(
        COMMAND "${PROGRAM}" /no/such/dbg-target
        RESULT_VARIABLE run_status
        OUTPUT_VARIABLE program_output
        ERROR_VARIABLE program_error)
    if(NOT run_status EQUAL 1)
        message(FATAL_ERROR "missing exited ${run_status}")
    endif()
    if(NOT program_error MATCHES "DBG1001")
        message(FATAL_ERROR "missing wrote '${program_error}'")
    endif()
else()
    message(FATAL_ERROR "unknown cli mode")
endif()
