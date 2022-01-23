# SPDX-FileCopyrightText: (C) 2022 Matthias Fehring / www.huessenbergnetz.de
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
HBNSfosGenerateIcons
------------------

This module provides the ``hbn_sfos_gen_icons`` function for generating
SailfishOS specific icons for different sizes and pixel ratios / scales.
It can be used to generate and install theme icons as well as application
launcher icons.

::

  hbn_sfos_gen_icons(<target_name>
      INPUT_FILE <input_file>
      [SCALES <scale> [<scale2> […]]]
      [SIZES <size> [<size2> […]]]
      [INSTALL_DESTINATION <install_destination>]
      [APPICON]
  )

This function adds a target called <target_name> for the generation of
icons from SVG input files. It requires the following external programs:
rsvg-convert, printf and bc.

It has two operational modes. One for creating theme icons of different
sizes and scales/pixel ratios and one to create application launcher icons.
By default it will create theme icons, to use application launcher icon
mode, set the ``APPICON`` option.

Theme icons are named after a specific scheme. If your input file for example
is named feed.svg, the generated icons are named icon-xs-feed.png,
icon-s-feed.png and so on. Application launcher icons are not renamed.

``INPUT_FILE`` specifies the input file. Has to be a SVG file.

``SCALES`` specifies a list of scales/pixel ratios to generate theme icons
for. By default, if no ``SCALES`` have been set, icons will be created for
the folowing pixel ratios: 1.0, 1.25, 1.5, 1.75 and 2.0.

``SIZES`` specifies a list of icon sizes to generate. For theme icons, if
not ``APPICON`` has been set, this accepts the following icon size indicators:
xs, s, splus, m, l and xl. If ``SIZES`` has not been set, this list is also
the default for theme icons. If ``APPICON`` is set to generate application
launcher icons, this accepts a list of integer values specifying the icon
size to generate. By default, if ``SIZES`` is not set, these are 86, 108,
128, 150 and 172.

``INSTALL_DESTINATION`` specifies the install destination for theme icons.
Application launcher icons are installed to a fixed destination. By default,
if ``INSTALL_DESTINATION`` has not been set, theme icons are installed into
``${CMAKE_INSTALL_DATADIR}/harbour-${PROJECT_NAME}/icons``. The target
directory will contain subdirectories for every scale.

``APPICON`` tells the function to operate in application launcher icon mode.
This will change default values for some arguments and how arguments are
handled.

Example usage (to generate theme icons with default values):

.. code-block:: cmake

  hbn_sfos_gen_icons(genicons
      INPUT_FILE icon.svg
  )

Example usage (to generate theme icons with custom settings):

.. code-block:: cmake

  hbn_sfos_gen_icons(genicons
      INPUT_FILE icon.svg
      SCALES 1.0 1.5 2.0
      SIZES s m l
      INSTALL_DESTINATION share/harbour-myapp/assets/icons
  )

Example usage (to generate applicaion launcher icons):

.. code-block:: cmake

  hbn_sfos_gen_icons(genicons
      INPUT_FILE habour-myapp.svg
      APPICON
  )

#]=======================================================================]

include(CMakeParseArguments)
include(GNUInstallDirs)

function(hbn_sfos_gen_icons target_name)
    set(options APPICON)
    set(oneValueArgs INPUT_FILE INSTALL_DESTINATION)
    set(multiValueArgs SCALES SIZES)
    cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # check required args
    list(APPEND _req_args INPUT_FILE)
    foreach(_arg_name ${_req_args})
        if(NOT DEFINED ARGS_${_arg_name})
            message(FATAL_ERROR "${_arg_name} needs to be defined when calling hbn_sfos_gen_icons")
        endif()
    endforeach()

    find_program(RSVGCONV rsvg-convert)
    if (NOT RSVGCONV)
        message(FATAL_ERROR "Can not find rsvg-convert executable.")
    endif (NOT RSVGCONV)

    find_program(PRINTFEXE printf)
    if(NOT PRINTFEXE)
        message(FATAL_ERROR "Can not find printf executable.")
    endif(NOT PRINTFEXE)

    find_program(BCEXE bc)
    if (NOT BCEXE)
        message(FATAL_ERROR "Can not find bc executable.")
    endif(NOT BCEXE)

    if (DEFINED ARGS_SCALES)
        set(_scales ${ARGS_SCALES})
    else()
        if (ARGS_APPICON)
            set(_scales 1.0)
        else()
            set(_scales 1.0 1.25 1.5 1.75 2.0)
        endif()
    endif()

    if (DEFINED ARGS_SIZES)
        set(_sizes ${ARGS_SIZES})
    else()
        if (ARGS_APPICON)
            set(_sizes 86 108 128 150 172)
        else()
            set(_sizes xs s splus m l xl)
        endif()
    endif()

    if (DEFINED INSTALL_DESTINATION)
        set(_installDest ${ARGS_INSTALL_DESTINATION})
    else()
        set(_installDest ${CMAKE_INSTALL_DATADIR}/harbour-${PROJECT_NAME}/icons)
    endif()

    set(_inputFile ${ARGS_INPUT_FILE})

    if (NOT TARGET ${target_name})
        add_custom_target(${target_name} ALL COMMENT "Generating icons")
    endif()

    set_property(TARGET ${target_name} APPEND PROPERTY SOURCES ${_inputFile})

    get_filename_component(_fileBaseName ${_inputFile} NAME_WE)

    if (ARGS_APPICON)

        foreach(_size ${_sizes})
            file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/apps/${_size}x${_size})
            if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/apps/${_size}x${_size}/${_fileBaseName}.png)
                add_custom_command(TARGET ${target_name} POST_BUILD
                    COMMAND ${RSVGCONV} --width=${_size} --height=${_size} --keep-aspect-ratio --output=${CMAKE_CURRENT_BINARY_DIR}/apps/${_size}x${_size}/${_fileBaseName}.png ${CMAKE_CURRENT_SOURCE_DIR}/${_inputFile}
                    COMMENT "Generating application icon ${_fileBaseName}.png for size ${_size}x${_size}")
            endif()
            install(FILES ${CMAKE_CURRENT_BINARY_DIR}/apps/${_size}x${_size}/${_fileBaseName}.png DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/${_size}x${_size}/apps)
        endforeach(_size)

    else()

        foreach(_scale ${_scales})
            file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/icons/z${_scale})

            foreach(_size ${_sizes})

                set(_iconName "icon-${_size}-${_fileBaseName}.png")

                if (${_size} STREQUAL "xs")
                    set(_iconSize 24)
                elseif(${_size} STREQUAL "s")
                    set(_iconSize 32)
                elseif(${_size} STREQUAL "splus")
                    set(_iconSize 48)
                elseif(${_size} STREQUAL "m")
                    set(_iconSize 64)
                elseif(${_size} STREQUAL "l")
                    set(_iconSize 96)
                elseif(${_size} STREQUAL "xl")
                    set(_iconSize 128)
                else()
                    message(WARNING "${_size} is not a supported icon size. Currently supported icon sizes are xs, s, splus, m, l and xl.")
                    set(_iconSize 0)
                endif()

                if (${_iconSize} GREATER 0)
                    if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/icons/z${_scale}/${_iconName})
                        execute_process(COMMAND bash "-c" "${PRINTFEXE} %.0f $(echo '${_scale} * ${_iconSize}' | ${BCEXE})" OUTPUT_VARIABLE _scaledSize)
                        add_custom_command(TARGET ${target_name} POST_BUILD
                            COMMAND ${RSVGCONV} --width=${_scaledSize} --height=${_scaledSize} --keep-aspect-ratio --output=${CMAKE_CURRENT_BINARY_DIR}/icons/z${_scale}/${_iconName} ${CMAKE_CURRENT_SOURCE_DIR}/${_inputFile}
                            COMMENT "Generating theme icon ${_iconName} for scale ${_scale}")
                    endif ()
                    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/icons/z${_scale}/${_iconName} DESTINATION ${_installDest}/z${_scale})
                endif()
            endforeach(_size)
        endforeach(_scale)

    endif()

endfunction(hbn_sfos_gen_icons)
