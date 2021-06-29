#[=======================================================================[.rst:
Findpthread
-------

Finds the pthread library.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``pthread::pthread``
  The pthread library

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``pthread_FOUND``
  True if the system has the pthread library.
``pthread_VERSION``
  The version of the pthread library which was found.
``pthread_INCLUDE_DIRS``
  Include directories needed to use pthread.
``pthread_LIBRARIES``
  Libraries needed to link to pthread.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``pthread_INCLUDE_DIR``
  The directory containing ``hb.h``.
``pthread_LIBRARY``
  The path to the pthread library.

#]=======================================================================]

find_package(PkgConfig)
if (PkgConfig_FOUND)
    pkg_check_modules(PC_pthread QUIET pthread)
endif()

find_path(pthread_INCLUDE_DIR
    NAMES pthread.h
    PATHS ${PC_pthread_INCLUDE_DIRS}
    PATH_SUFFIXES pthread
)
find_library(pthread_LIBRARY
    NAMES pthread
    PATHS ${PC_pthread_LIBRARY_DIRS}
)
set(pthread_VERSION ${PC_pthread_VERSION})
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(pthread
    FOUND_VAR pthread_FOUND
  REQUIRED_VARS
    pthread_LIBRARY
    pthread_INCLUDE_DIR
  VERSION_VAR pthread_VERSION
)
if (pthread_FOUND)
    set(pthread_LIBRARIES ${pthread_LIBRARY})
    set(pthread_INCLUDE_DIRS ${pthread_INCLUDE_DIR})
    set(pthread_DEFINITIONS ${PC_pthread_CFLAGS_OTHER})
endif()
if(pthread_FOUND AND NOT TARGET pthread::pthread)
  add_library(pthread::pthread UNKNOWN IMPORTED)
  set_target_properties(pthread::pthread PROPERTIES
    IMPORTED_LOCATION "${pthread_LIBRARY}"
    INTERFACE_COMPILE_OPTIONS "${PC_pthread_CFLAGS_OTHER}"
    INTERFACE_INCLUDE_DIRECTORIES "${pthread_INCLUDE_DIR}"
  )
endif()
