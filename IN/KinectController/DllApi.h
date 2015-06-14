#pragma once

#ifdef MAKEDLL
#define DLLAPI __declspec(dllexport)
#define DLLAPITEMP
#else
#define DLLAPI __declspec(dllimport)
#define DLLAPITEMP extern
#endif