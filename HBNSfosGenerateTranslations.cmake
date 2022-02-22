# SPDX-FileCopyrightText: (C) 2022 Matthias Fehring / www.huessenbergnetz.de
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
HBNSfosGenerateTranslations
------------------

This module provides the ``hbn_sfos_add_translation`` function to generate
compiled translation files (.qm).

::

  hbn_sfos_add_translation(<VAR> file1.ts [file2.ts] [OPTIONS ...])

Calls `lrelease` on each `.ts` file paswed as an argument, generating
`.qm` files. The paths of the generated files are added to <VAR>. Should
be used together with `add_custom_target`. Internally this used `qt5_add_translation`
or `qt6_add_translation` when the Qt version is newer than 5.11.0,
otherwise it uses a copied implementation of `qt5_add_translation` from
Qt 5.11.0.

``OPTIONS`` can be used to pass additional options when `lrelease` is
invoked. Yout can find possible options in the lrelease documentation.

Example usage

.. code-blocks:: cmake

  set(tsFiles
      helloworld_en.ts
      hellowordl_de.ts)

  hbn_sfos_add_translation(qmFiles ${tsFiles} OPTIONS -idbased)

  add_custom_target(tanslations ALL
                    DEPENDS ${qmFiles}
                    SOURCES ${tsFiles})

  install(FILES ${qmFiles}
          DESTINATION ${CMAKE_INSTALL_LOCALEDIR}
          COMPONENT runtime)

#]=======================================================================]

include(CMakeParseArguments)

function(_hbn_sfos_add_trans_func _qm_files)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs OPTIONS)

    cmake_parse_arguments(_LRELEASE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(_lrelease_files ${_LRELEASE_UNPARSED_ARGUMENTS})

    foreach(_current_FILE ${_lrelease_files})
        get_filename_component(_abs_FILE ${_current_FILE} ABSOLUTE)
        get_filename_component(qm ${_abs_FILE} NAME)
        # everything before the last dot has to be considered the file name (including other dots)
        string(REGEX REPLACE "\\.[^.]*$" "" FILE_NAME ${qm})
        get_source_file_property(output_location ${_abs_FILE} OUTPUT_LOCATION)
        if(output_location)
            file(MAKE_DIRECTORY "${output_location}")
            set(qm "${output_location}/${FILE_NAME}.qm")
        else()
            set(qm "${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.qm")
        endif()

        add_custom_command(OUTPUT ${qm}
            COMMAND ${Qt5_LRELEASE_EXECUTABLE}
            ARGS ${_LRELEASE_OPTIONS} ${_abs_FILE} -qm ${qm}
            DEPENDS ${_abs_FILE} VERBATIM
        )
        list(APPEND ${_qm_files} ${qm})
    endforeach()
    set(${_qm_files} ${${_qm_files}} PARENT_SCOPE)
endfunction()

function(hbn_sfos_add_translation _qm_files)
    if (QT_VERSION VERSION_LESS "5.11.0")
        _hbn_sfos_add_trans_func("${_qm_files}" ${ARGN})
    else()
        if(QT_DEFAULT_MAJOR_VERSION EQUAL 5)
            qt5_add_translation("${_qm_files}" ${ARGN})
        elseif(QT_DEFAULT_MAJOR_VERSION EQUAL 6)
            qt6_add_translation("${_qm_files}" ${ARGN})
        endif()
    endif()
    set("${_qm_files}" "${${_qm_files}}" PARENT_SCOPE)
endfunction()
