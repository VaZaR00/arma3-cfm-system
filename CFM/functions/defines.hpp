#include "..\includes\defines.hpp"

#include "modDefines.hpp"

#ifdef TEST_NET
    _FILE_NAME_ = __FILE_SHORT__;
    // Test remoteExecs frequency
    #define CFM_fnc_remoteExec call { \
        if (isNil "CFM_remoteExec_logCounter") then { \
            CFM_remoteExec_logCounter = []; \
        }; \
        CFM_remoteExec_logCounter pushbackunique [diag_tickTime, _FILE_NAME_, [_NIL(_className), _NIL(_methodName)], _NIL(_this)]; \
        _this call cfm_fnc_remoteExec; \
    }
#endif