-- Compressonator SDK static libs (CPU-only configuration).
-- Mirrors build_sdk/CMakeLists.txt with all GPU-app options off:
-- no DirectX / Vulkan / Qt / OpenCV / Draco / ASTC / Brotli-G.
--   CMP_Core           : SIMD kernels + core math (see cmp_core/CMakeLists.txt)
--   CMP_Framework      : framework, DDS I/O, CPU HPC, base codecs (see cmp_framework/CMakeLists.txt)
--   CMP_Compressonator : full codec set incl. BC7, exposes Compressonator.h API
--                        (see cmp_compressonatorlib/CMakeLists.txt)

-- ---------------------------------------------------------------------------
project "CMP_Core"
    kind "StaticLib"
    language "C++"
    staticruntime "on"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("obj/" .. outputdir .. "/%{prj.name}")

    files
    {
        "cmp_core/source/cmp_core.cpp",
        "cmp_core/source/cmp_core.h",
        "cmp_core/source/cmp_math_func.h",
        "cmp_core/source/cmp_math_vec4.h",
        "cmp_core/source/core_simd.h",
        "cmp_core/source/core_simd_sse.cpp",
        "cmp_core/source/core_simd_avx.cpp",
        "cmp_core/source/core_simd_avx512.cpp",
        "cmp_core/shaders/bc1_encode_kernel.cpp",
        "cmp_core/shaders/bc2_encode_kernel.cpp",
        "cmp_core/shaders/bc3_encode_kernel.cpp",
        "cmp_core/shaders/bc4_encode_kernel.cpp",
        "cmp_core/shaders/bc5_encode_kernel.cpp",
        "cmp_core/shaders/bc6_encode_kernel.cpp",
        "cmp_core/shaders/bc7_encode_kernel.cpp",
        "cmp_core/shaders/*.h",
        "applications/_libs/cmp_math/cpu_extensions.cpp",
        "applications/_libs/cmp_math/cpu_extensions.h",
        "applications/_libs/cmp_math/cmp_math_common.cpp",
        "applications/_libs/cmp_math/cmp_math_common.h",
    }

    includedirs
    {
        "cmp_core/shaders",
        "cmp_core/source",
        "applications/_libs/cmp_math",
    }

    -- SIMD arch: Linux uses #pragma GCC target in source files (gmake ignores per-file buildoptions)
    filter { "system:windows", "files:cmp_core/source/core_simd_avx.cpp" }
        buildoptions { "/arch:AVX2" }
    filter { "system:windows", "files:cmp_core/source/core_simd_avx512.cpp" }
        buildoptions { "/arch:AVX512" }

    filter "system:windows"
        systemversion "latest"
        disablewarnings { "4267", "4244", "4305", "4838" }

    filter "system:linux"
        defines { "_LINUX", "ASPM_GPU" }
        pic "On"
        buildoptions { "-fPIC" }

    filter "configurations:Debug"
        runtime "Debug"
        symbols "on"

    filter "configurations:Release"
        runtime "Release"
        optimize "speed"

    filter "configurations:Dist"
        runtime "Release"
        optimize "speed"
        symbols "off"
        if vsprops then
            vsprops { ["VcpkgConfiguration"] = "Release" }
        end

-- ---------------------------------------------------------------------------
project "CMP_Framework"
    kind "StaticLib"
    language "C++"
    staticruntime "on"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("obj/" .. outputdir .. "/%{prj.name}")

    files
    {
        "cmp_framework/compute_base.cpp",
        "cmp_framework/compute_base.h",
        "cmp_framework/common/*.cpp",
        "cmp_framework/common/*.h",
        "cmp_framework/common/half/*.cpp",
        "cmp_framework/common/half/*.h",
        "applications/_plugins/cimage/dds/*.cpp",
        "applications/_plugins/cimage/dds/*.h",
        "applications/_plugins/ccmp_encode/hpc/*.cpp",
        "applications/_plugins/ccmp_encode/hpc/*.h",
        "applications/_libs/cmp_math/cmp_math_common.cpp",
        "applications/_libs/cmp_math/cmp_math_common.h",
        "applications/_libs/cmp_math/cpu_extensions.cpp",
        "applications/_libs/cmp_math/cpu_extensions.h",
        "applications/_plugins/common/atiformats.cpp",
        "applications/_plugins/common/atiformats.h",
        "applications/_plugins/common/pluginbase.h",
        "applications/_plugins/common/plugininterface.h",
        "applications/_plugins/common/pluginmanager.cpp",
        "applications/_plugins/common/pluginmanager.h",
        "applications/_plugins/common/cpu_timing.cpp",
        "applications/_plugins/common/cpu_timing.h",
        "applications/_plugins/common/tc_pluginapi.h",
        "applications/_plugins/common/tc_plugininternal.cpp",
        "applications/_plugins/common/tc_plugininternal.h",
        "applications/_plugins/common/utilfuncs.cpp",
        "applications/_plugins/common/utilfuncs.h",
        "applications/_plugins/common/cmp_fileio.cpp",
        "applications/_plugins/common/cmp_fileio.h",
        "applications/_plugins/common/format_conversion.cpp",
        "applications/_plugins/common/format_conversion.h",
        "applications/_plugins/common/codec_common.cpp",
        "applications/_plugins/common/codec_common.h",
        "applications/_plugins/common/texture_utils.cpp",
        "applications/_plugins/common/texture_utils.h",
        "applications/_plugins/ccmp_sdk/bcn.cpp",
        "applications/_plugins/ccmp_sdk/bcn.h",
        "applications/_plugins/ccmp_sdk/bc1/*.cpp",
        "applications/_plugins/ccmp_sdk/bc1/*.h",
        "applications/_plugins/ccmp_sdk/bc2/*.cpp",
        "applications/_plugins/ccmp_sdk/bc2/*.h",
        "applications/_plugins/ccmp_sdk/bc3/*.cpp",
        "applications/_plugins/ccmp_sdk/bc3/*.h",
        "applications/_plugins/ccmp_sdk/bc4/*.cpp",
        "applications/_plugins/ccmp_sdk/bc4/*.h",
        "applications/_plugins/ccmp_sdk/bc5/*.cpp",
        "applications/_plugins/ccmp_sdk/bc5/*.h",
        "applications/_plugins/ccmp_sdk/bc6/*.cpp",
        "applications/_plugins/ccmp_sdk/bc6/*.h",
        "applications/_plugins/ccmp_sdk/bc7/*.cpp",
        "applications/_plugins/ccmp_sdk/bc7/*.h",
        "external/stb/stb_image.h",
        "external/stb/stb_image_write.h",
    }

    -- DirectX GPU compute backend (Windows only): HLSL is compiled from file
    -- at runtime via d3dcompiler (ships with Windows), no SDK install needed.
    filter "system:windows"
        files
        {
            "applications/_plugins/cmp_gpu/directx/compute_directx.cpp",
            "applications/_plugins/cmp_gpu/directx/compute_directx.h",
            "applications/_plugins/cmp_gpu/directx/cdirectx.cpp",
            "applications/_plugins/cmp_gpu/directx/cdirectx.h",
        }
        includedirs
        {
            "applications/_plugins/cmp_gpu/directx",
        }
        links
        {
            "d3d11",
            "d3dcompiler",
        }
    filter {}

    includedirs
    {
        "cmp_framework",
        "cmp_framework/common/half",
        "cmp_framework/common",
        "cmp_compressonatorlib",
        "cmp_compressonatorlib/buffer",
        "cmp_core/shaders", -- common_def.h, bcn_common_kernel.h (via CMP_Core PUBLIC includes in CMake)
        "cmp_core/source",
        "applications/_plugins/ccmp_sdk",
        "applications/_plugins/common",
        "applications/_libs/cmp_math",
        "applications/_libs/gpu_decode",
        "external/stb",
    }

    links
    {
        "CMP_Core",
    }

    filter "system:windows"
        systemversion "latest"
        defines { "CMP_USE_XMMINTRIN" }
        buildoptions { "/bigobj" }
        disablewarnings { "4267", "4244", "4305", "4838" }

    filter "system:linux"
        defines { "_LINUX" }
        pic "On"
        buildoptions { "-fPIC" }

    filter "configurations:Debug"
        runtime "Debug"
        symbols "on"

    filter "configurations:Release"
        runtime "Release"
        optimize "speed"

    filter "configurations:Dist"
        runtime "Release"
        optimize "speed"
        symbols "off"
        if vsprops then
            vsprops { ["VcpkgConfiguration"] = "Release" }
        end

-- ---------------------------------------------------------------------------
project "CMP_Compressonator"
    kind "StaticLib"
    language "C++"
    staticruntime "on"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("obj/" .. outputdir .. "/%{prj.name}")

    files
    {
        "cmp_compressonatorlib/version.h",
        "cmp_compressonatorlib/common.h",
        "cmp_compressonatorlib/compress.cpp",
        "cmp_compressonatorlib/compressonator.cpp",
        "cmp_compressonatorlib/compressonator.h",
        "cmp_compressonatorlib/apc/*.cpp",
        "cmp_compressonatorlib/apc/*.h",
        "cmp_compressonatorlib/atc/*.cpp",
        "cmp_compressonatorlib/atc/*.h",
        "cmp_compressonatorlib/ati/*.cpp",
        "cmp_compressonatorlib/ati/*.h",
        "cmp_compressonatorlib/ati/*.c",
        "cmp_compressonatorlib/basis/*.cpp",
        "cmp_compressonatorlib/basis/*.h",
        "cmp_compressonatorlib/bc6h/*.cpp",
        "cmp_compressonatorlib/bc6h/*.h",
        "cmp_compressonatorlib/bc7/*.cpp",
        "cmp_compressonatorlib/bc7/*.h",
        "cmp_compressonatorlib/block/*.cpp",
        "cmp_compressonatorlib/block/*.h",
        "cmp_compressonatorlib/buffer/*.cpp",
        "cmp_compressonatorlib/buffer/*.h",
        "cmp_compressonatorlib/dxt/*.cpp",
        "cmp_compressonatorlib/dxt/*.h",
        "cmp_compressonatorlib/dxtc/*.cpp",
        "cmp_compressonatorlib/dxtc/*.h",
        "cmp_compressonatorlib/dxtc/*.c",
        "cmp_compressonatorlib/etc/*.cpp",
        "cmp_compressonatorlib/etc/*.h",
        "cmp_compressonatorlib/etc/etcpack/*.cpp",
        "cmp_compressonatorlib/etc/etcpack/*.h",
        "cmp_compressonatorlib/etc/etcpack/*.cxx",
        "cmp_compressonatorlib/gt/*.cpp",
        "cmp_compressonatorlib/gt/*.h",
        "cmp_compressonatorlib/common/*.cpp",
        "cmp_compressonatorlib/common/*.h",
        "cmp_framework/common/*.cpp",
        "cmp_framework/common/*.h",
        "cmp_framework/common/half/*.cpp",
        "cmp_framework/common/half/*.h",
        "applications/_plugins/common/atiformats.cpp",
        "applications/_plugins/common/atiformats.h",
        "applications/_plugins/common/format_conversion.cpp",
        "applications/_plugins/common/format_conversion.h",
        "applications/_plugins/common/codec_common.cpp",
        "applications/_plugins/common/codec_common.h",
        "applications/_plugins/common/texture_utils.cpp",
        "applications/_plugins/common/texture_utils.h",
    }

    includedirs
    {
        "cmp_compressonatorlib",
        "cmp_compressonatorlib/apc",
        "cmp_compressonatorlib/atc",
        "cmp_compressonatorlib/ati",
        "cmp_compressonatorlib/basis",
        "cmp_compressonatorlib/bc6h",
        "cmp_compressonatorlib/bc7",
        "cmp_compressonatorlib/block",
        "cmp_compressonatorlib/buffer",
        "cmp_compressonatorlib/dxt",
        "cmp_compressonatorlib/dxtc",
        "cmp_compressonatorlib/etc",
        "cmp_compressonatorlib/etc/etcpack",
        "cmp_compressonatorlib/gt",
        "cmp_compressonatorlib/common",
        "cmp_core/shaders", -- common_def.h (via CMP_Core PUBLIC includes in CMake)
        "cmp_core/source",
        "cmp_framework/common",
        "cmp_framework/common/half",
        "applications/_plugins/common",
        "applications/_libs/cmp_math",
    }

    links
    {
        "CMP_Core",
    }

    filter "system:windows"
        systemversion "latest"
        buildoptions { "/bigobj" }
        disablewarnings { "4267", "4244", "4305", "4838" }

    filter "system:linux"
        defines { "_LINUX" }
        pic "On"
        buildoptions { "-fPIC" }

    filter "configurations:Debug"
        runtime "Debug"
        symbols "on"

    filter "configurations:Release"
        runtime "Release"
        optimize "speed"

    filter "configurations:Dist"
        runtime "Release"
        optimize "speed"
        symbols "off"
        if vsprops then
            vsprops { ["VcpkgConfiguration"] = "Release" }
        end
