INCLUDE(CheckCSourceCompiles)

MACRO(CHECK_VARIABLE_EXISTS _SYMBOL _HEADER _RESULT)
  SET(_INCLUDE_FILES)
  FOREACH (it ${_HEADER})
    SET(_INCLUDE_FILES "${_INCLUDE_FILES}#include <${it}>\n")
  ENDFOREACH (it)
 
   SET(_CHECK_PROTO_EXISTS_SOURCE_CODE "
${_INCLUDE_FILES}
void cmakeRequireSymbol(int dummy,...){(void)dummy;}
int main()
{
  int i = ${_SYMBOL};
  return 0;
}
")
 
  CHECK_C_SOURCE_COMPILES("${_CHECK_PROTO_EXISTS_SOURCE_CODE}" ${_RESULT})
ENDMACRO(CHECK_VARIABLE_EXISTS _SYMBOL _HEADER _RESULT)
