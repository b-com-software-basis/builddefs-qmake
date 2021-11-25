#ifndef %{ModuleName}API_H
#define %{ModuleName}API_H

#if _WIN32
#ifdef %{ModuleName}_API_DLLEXPORT
#define %{ModuleName}_EXPORT_API __declspec(dllexport)
#else
#define %{ModuleName}_EXPORT_API __declspec(dllimport)
#endif
#else //!_WIN32
#define %{ModuleName}_EXPORT_API
#endif //!_WIN32

#endif
