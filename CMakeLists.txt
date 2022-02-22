list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

find_package(QT NAMES Qt6 Qt5 COMPONENTS LinguistTools REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS LinguistTools)

add_custom_target(HBNSfosCmake
    SOURCES
        HBNSfosGenerateIcons.cmake
        HBNSfosGenerateTranslations.cmake
)
