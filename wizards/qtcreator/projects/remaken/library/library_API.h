#ifndef %{LibraryName}API_H
#define %{LibraryName}API_H

#if _WIN32
#ifdef %{LibraryName}_API_DLLEXPORT
#define %{LibraryName}_EXPORT_API __declspec(dllexport)
#else
#define %{LibraryName}_EXPORT_API __declspec(dllimport)
#endif
#else //!_WIN32
#define %{LibraryName}_EXPORT_API
#endif //!_WIN32

#endif
