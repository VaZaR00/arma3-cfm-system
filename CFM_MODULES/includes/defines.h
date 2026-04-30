#include "generic.h"
#include "main.h"

#define SPLIT_CHARACTERS " ,.;:[](){}"
#define WARN DLOG
#define IS_OBJ(o) (!(o isEqualTo objNull) && {o isEqualType objNull})