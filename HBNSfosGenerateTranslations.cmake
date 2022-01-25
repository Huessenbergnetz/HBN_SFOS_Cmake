# SPDX-FileCopyrightText: (C) 2022 Matthias Fehring / www.huessenbergnetz.de
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
HBNSfosGenerateTranslations
------------------

This module provides the ``hbn_sfos_gen_translation`` function to generate
compiled translation files (.qm).

::

  hbn_sfos_gen_translation(<target_name>
      INPUT_FILE <input_file>
      [INSTALL_DESTINATION <install_destination>]
      [MARK_UNTRANSLATED <prefix>]
      [IDBASED]
      [COMPRESS]
      [NOUNFINISHED]
      [REMOVEIDENTICAL]
  )

This function adds a traget called <target_name> for the generation of
compiled translation files. It requires Qt’s lrelease program to perform
the compilation.

``INPUT_FILE`` specifies the input file. Has to be a ts file.

``INSTALL_DESTINATION`` specifies the install destination for the QM files.
By default, if ``INSTALL_DESTINATION`` has not been set, translations are
installed into ``${CMAKE_INSTALL_DATADIR}/harbour-${PROJECT_NAME}/translations``.

``MARK_UNTRANSLATED`` specifies a prefix for messages with no real translation.
Will use the source text prefixed with the given string instead.

``IDBASED`` specifies to use IDs instead of source strings for message keying.

``COMRESS`` the QM files.

``NOUNFINISHED`` is used to not include unfinished translations.

``REMOVEIDENTICAL`` omits messages where the translated text is the same
as the source text.

#]=======================================================================]

include(CMakeParseArguments)

function(hbn_sfos_gen_translation target_name)
    set(options IDBASED COMPRESS NOUNFINISHED REMOVEIDENTICAL )
    set(oneValueArgs INPUT_FILE INSTALL_DESTINATION MARK_UNTRANSLATED)
    set(multiValueArgs )
    cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # check required args
    list(APPEND _req_args INPUT_FILE)
    foreach(_arg_name ${_req_args})
        if(NOT DEFINED ARGS_${_arg_name})
            message(FATAL_ERROR "${_arg_name} needs to be defined when calling hbn_sfos_gen_icons")
        endif()
    endforeach()

    find_program(LRELEASE NAMES lrelease-qt6 lrelease6 lrelease-qt5 lrelease5 lrelease)
    if (NOT LRELEASE)
        message(FATAL_ERROR "Can not find lrelease executable")
    endif()

    get_filename_component(_inputFile ${ARGS_INPUT_FILE} ABSOLUTE)

    if (NOT EXISTS ${_inputFile})
        message(FATAL_ERROR "Can not find translation source file ${_inputFile}")
    endif()

    if (DEFINED ARGS_INSTALL_DESTINATION)
            set(_installDest ${ARGS_INSTALL_DESTINATION})
        else()
            set(_installDest ${CMAKE_INSTALL_DATADIR}/harbour-${PROJECT_NAME}/translations)
        endif()

    if (NOT TARGET ${target_name})
        add_custom_target(${target_name} ALL COMMENT "Generating translations")
    endif()

    set_property(TARGET ${target_name} APPEND PROPERTY SOURCES ${_inputFile})

    get_filename_component(_fileBaseName ${_inputFile} NAME_WE)

    set(_lreleaseArgs )

    set(_optionArgs IDBASED COMPRESS NOUNFINISHED REMOVEIDENTICAL)
    foreach(_optionArg ${_optionArgs})
        if(ARGS_${_optionArg})
            string(TOLOWER ${_optionArg} _argLow)
            list(APPEND _lreleaseArgs -${_argLow})
        endif()
    endforeach()

    set(_qmFile ${CMAKE_CURRENT_BINARY_DIR}/${_fileBaseName}.qm)

    set(_lreleaseArgs ${_lreleaseArgs} ${_inputFile} -qm ${_qmFile})

    add_custom_command(TARGET ${target_name} POST_BUILD
        COMMAND ${LRELEASE} ARGS ${_lreleaseArgs}
        COMMENT "Generating translation ${_fileBaseName}.qm"
        VERBATIM
    )

    install(FILES ${_qmFile} DESTINATION ${_installDest})

endfunction(hbn_sfos_gen_translation)
