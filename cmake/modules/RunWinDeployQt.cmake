file(
	LOCK "${LOCK_FILE}"
	GUARD PROCESS
	RESULT_VARIABLE LOCK_RESULT
)

if(NOT LOCK_RESULT EQUAL 0)
	message(FATAL_ERROR
		"Failed to acquire lock for windeployqt (${LOCK_RESULT})"
	)
endif()

execute_process(
	COMMAND "${WINDEPLOYQT}" "${TARGET_FILE}"
	RESULT_VARIABLE WINDEPLOYQT_RESULT
)

if(NOT WINDEPLOYQT_RESULT EQUAL 0)
	message(FATAL_ERROR
		"windeployqt failed with code ${WINDEPLOYQT_RESULT}"
	)
endif()
