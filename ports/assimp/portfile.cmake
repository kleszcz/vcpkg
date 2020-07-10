include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO assimp/assimp
    REF v5.0.0
    SHA512 0f73b6e961cd8455d6b6c8c10ed8b99485d846c96377b5d4fcc3b83f737647207c1306aa3dd51dad9654fbfa61bfe1119b34646f90288ae7ecab45efa6fa418a
    HEAD_REF master
    PATCHES
        uninitialized-variable.patch
        fix-static-build-error.patch
)

file(REMOVE ${SOURCE_PATH}/cmake-modules/FindZLIB.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/zlib ${SOURCE_PATH}/contrib/gtest ${SOURCE_PATH}/contrib/rapidjson)

set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DASSIMP_BUILD_TESTS=OFF
            -DASSIMP_BUILD_ASSIMP_VIEW=OFF
            -DASSIMP_BUILD_ZLIB=OFF
            -DASSIMP_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
            -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
            -DASSIMP_INSTALL_PDB=OFF
            -DZLIB_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
            -DZLIB_FOUND=1
    OPTIONS_RELEASE
            -DZLIB_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/zlib.lib
            -DZLIB_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/zlib.lib
    OPTIONS_DEBUG
            -DZLIB_LIBRARIES=${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib
            -DZLIB_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/assimp-4.1")

vcpkg_copy_pdbs()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(READ ${CURRENT_PACKAGES_DIR}/share/assimp/assimp-config.cmake ASSIMP_CONFIG)
string(REPLACE "get_filename_component(ASSIMP_ROOT_DIR \"\${_PREFIX}\" PATH)"
               "set(ASSIMP_ROOT_DIR \${_PREFIX})" ASSIMP_CONFIG ${ASSIMP_CONFIG})

if(WIN32)
  string(REPLACE "set( ASSIMP_LIBRARIES \${ASSIMP_LIBRARIES})"
                 "set( ASSIMP_LIBRARIES optimized \${ASSIMP_LIBRARY_DIRS}/\${ASSIMP_LIBRARIES}.lib debug \${ASSIMP_LIBRARY_DIRS}/../debug/lib/\${ASSIMP_LIBRARIES}d.lib)" ASSIMP_CONFIG ${ASSIMP_CONFIG})
else()
  string(REPLACE "set( ASSIMP_LIBRARIES \${ASSIMP_LIBRARIES})"
                 "set( ASSIMP_LIBRARIES optimized \${ASSIMP_LIBRARY_DIRS}/lib\${ASSIMP_LIBRARIES}.a \${ASSIMP_LIBRARY_DIRS}/libIrrXML.a \${ASSIMP_LIBRARY_DIRS}/libz.a debug \${ASSIMP_LIBRARY_DIRS}/../debug/lib/lib\${ASSIMP_LIBRARIES}d.a \${ASSIMP_LIBRARY_DIRS}/../debug/lib/libIrrXMLd.a \${ASSIMP_LIBRARY_DIRS}/../debug/lib/libz.a)" ASSIMP_CONFIG ${ASSIMP_CONFIG})
endif()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/assimp/assimp-config.cmake "${ASSIMP_CONFIG}")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/assimp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/assimp/LICENSE ${CURRENT_PACKAGES_DIR}/share/assimp/copyright)
