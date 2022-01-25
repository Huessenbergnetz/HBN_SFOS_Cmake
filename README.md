# HBN SFOS Cmake
Extra cmake modules used to build software for SailfishOS with CMake.

## Integrate into your Sailfish OS application
The easiest way is to simple download the latest release tarball. You can than copy the files you want to use into your source tree.

A better, and on the long run more comfortable solution, is to clone this repository and checkout the current stable branch/tag to work with. Or integrate it as a submodule into your project git tree.

### Cloning and branching
    git clone https://github.com/Huessenbergnetz/HBN_SFOS_Cmake.git

### Integrate into your project
You can copy the files or, the better way, include the configuration into your project.

    list(APPEND CMAKE_MODULE_PATH path/to/HBN_SFOS_Cmake)

## Modules provided by HBN_SFOS_Cmake

### HBNSfosGenerateIcons

This module provides the ``hbn_sfos_gen_icons`` function for generating SailfishOS specific icons for different sizes and pixel ratios / scales. It can be used to generate and install theme icons as well as application launcher icons. Have a look at the [source code documentation](https://github.com/Huessenbergnetz/HBN_SFOS_Cmake/blob/master/HBNSfosGenerateIcons.cmake) to learn how to use it.

### HBNSfosGenerateTranslations

This module provides the ``hbn_sfos_gen_translation`` function to generate
compiled translation files (.qm). Have a look at the [source code documentation](https://github.com/Huessenbergnetz/HBN_SFOS_Cmake/blob/master/HBNSfosGenerateTranslations.cmake) to learn how to use it.

## License
Copyright (c) 2022, Hüssenbergnetz/Matthias Fehring
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of HBN SFOS Components nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
