#include "Stdafx.h"
#include "StringConverter.h"
#include <msclr\marshal_cppstd.h>

std::string cstr(System::String^ str)
{
	msclr::interop::marshal_context context;
	return context.marshal_as<std::string>(str);
}