# SPDX-FileCopyrightText: (C) 2022 Matthias Fehring / www.huessenbergnetz.de
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
HBNSfosGenerateIcons
------------------

This module provides the ``hbn_sfos_add_appicon`` and ``hbn_sfos_add_icon``
functions for generating and installing SailfishOS specific icons for different
sizes and pixel ratios / scales.

::

  hbn_sfos_add_appicon(<VAR> file.svg [SIZES <size> [<size2> […]]])

This function generates and installs application launcher icons from a
input SVG file. The paths of the generated png files are stored to `VAR`.

``SIZES`` optionally specifies a list of icon sizes to generatre. This
accepts a list of integer values specifying the cions size to generate.
By Default, if ``SIZES`` is not set, these are 86, 108, 128, 150 and 172.

The generated icons will be installed to
``${CMAKE_INSTALL_DATADIR}/icons/hicolor/${_size}x${_size}/apps``.

Example:

.. code-block:: cmake

  hbn_sfos_add_appicon(appIcons harbour-myapp.svg)

  add_custom_target(generateAppIcons ALL
                    DEPENDA ${appIcons}
                    COMMENT "Generate application launcher icons"
                    SOURCES harbour-myapp.svg)

::

  hbn_sfos_add_icon(<VAR> file1.svg [file2.svg]
      [SCALES <scale> [<scale2> […]]]
      [SIZES <size> [<size2> […]]]
      [INSTALL_DESTINATION <install_destination>]
  )

This function generates and install theme icons from input SVG files.
The paths of the generated icons are stored to `VAR`.

Theme icons are named after a specific scheme. If your input file for example
is named feed.svg, the generated icons are named icon-xs-feed.png,
icon-s-feed.png and so on.

``SCALES`` specifies a list of scales/pixel ratios to generate theme icons
for. By default, if no ``SCALES`` have been set, icons will be created for
the folowing pixel ratios: 1.0, 1.25, 1.5, 1.75 and 2.0.

``SIZES`` specifies a list of icon sizes to generate. This accepts the
following icon size indicators: xs, s, splus, m, l, xl, lock, and cover.
If ``SIZES`` has not been set, xs, s, splus, m, l, and xl will be created

``INSTALL_DESTINATION`` specifies the install destination for theme icons.
By default, if ``INSTALL_DESTINATION`` has not been set, theme icons are
installed into ``${CMAKE_INSTALL_DATADIR}/harbour-${PROJECT_NAME}/icons``.
The target directory will contain subdirectories for every scale.

Example usage (to generate theme icons with default values):

.. code-block:: cmake

  set(ICON_SIZES s m l)

  set(ICONS icon1.svg icon2.svg icon4.svg)

  hbn_sfos_add_icon(pngFiles ${ICONS} SIZES ${ICON_SIZES})

  add_custom_target(myIcons ALL
                    DEPENDS ${pngFiles}
                    COMMENT "Generating icons"
                    SOURCES ${ICONS})

#]=======================================================================]

include(CMakeParseArguments)
include(GNUInstallDirs)

function(hbn_sfos_add_appicon _png_files)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs SIZES)

    cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(_svg_files ${ARGS_UNPARSED_ARGUMENTS})

    find_program(RSVGCONV rsvg-convert)
    if (NOT RSVGCONV)
        message(FATAL_ERROR "Can not find rsvg-convert executable.")
    endif (NOT RSVGCONV)

    if (DEFINED ARGS_SIZES)
        set(_sizes ${ARGS_SIZES})
    else()
        set(_sizes 86 108 128 150 172)
    endif()

    foreach(_current_FILE ${_svg_files})
        get_filename_component(_abs_FILE ${_current_FILE} ABSOLUTE)
        get_filename_component(png ${_abs_FILE} NAME_WE)
        foreach(_size ${_sizes})
            file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/apps/${_size}x${_size}")
            set(_outputFile ${CMAKE_CURRENT_BINARY_DIR}/apps/${_size}x${_size}/${png}.png)
            add_custom_command(OUTPUT ${_outputFile}
                COMMAND ${RSVGCONV}
                ARGS --width=${_size} --height=${_size} --keep-aspect-ratio --output=${_outputFile} ${_abs_FILE}
                DEPENDS ${_abs_FILE}
            )
        install(FILES ${_outputFile} DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/${_size}x${_size}/apps)
        list(APPEND ${_png_files} ${_outputFile})
        endforeach()
    endforeach()
    set(${_png_files} ${${_png_files}} PARENT_SCOPE)
endfunction()

function(hbn_sfos_add_icon _png_files)
    set(options)
    set(oneValueArgs INSTALL_DESTINATION)
    set(multiValueArgs SCALES SIZES)

    cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(_svg_files ${ARGS_UNPARSED_ARGUMENTS})

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
        set(_scales 1.0 1.25 1.5 1.75 2.0)
    endif()

    if (DEFINED ARGS_SIZES)
        set(_sizes ${ARGS_SIZES})
    else()
        set(_sizes xs s splus m l xl)
    endif()

    if (DEFINED ARGS_INSTALL_DESTINATION)
        set(_installDest ${ARGS_INSTALL_DESTINATION})
    else()
        set(_installDest ${CMAKE_INSTALL_DATADIR}/harbour-${PROJECT_NAME}/icons)
    endif()

    foreach(_current_FILE ${_svg_files})
        get_filename_component(_abs_FILE ${_current_FILE} ABSOLUTE)
        get_filename_component(png ${_abs_FILE} NAME_WE)

        foreach(_scale ${_scales})
            file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/icons/z${_scale})

            foreach(_size ${_sizes})

                set(_iconName "icon-${_size}-${png}.png")

                if (${_size} STREQUAL "xs")
                    set(_iconSize 24)
                elseif(${_size} STREQUAL "s" OR ${_size} STREQUAL "lock" OR ${_size} STREQUAL "cover")
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
                    execute_process(COMMAND bash "-c" "${PRINTFEXE} %.0f $(echo '${_scale} * ${_iconSize}' | ${BCEXE})" OUTPUT_VARIABLE _scaledSize)
                    set(_outputFile ${CMAKE_CURRENT_BINARY_DIR}/icons/z${_scale}/${_iconName})
                    add_custom_command(OUTPUT ${_outputFile}
                        COMMAND ${RSVGCONV}
                        ARGS --width=${_scaledSize} --height=${_scaledSize} --keep-aspect-ratio --output=${_outputFile} ${_abs_FILE}
                        COMMENT "Generating theme icon ${_iconName} for scale ${_scale}")
                    install(FILES ${_outputFile} DESTINATION ${_installDest}/z${_scale})
                    list(APPEND ${_png_files} ${_outputFile})
                endif()
            endforeach(_size)
        endforeach(_scale)
    endforeach()
    set(${_png_files} ${${_png_files}} PARENT_SCOPE)
endfunction()
