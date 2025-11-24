#include "moonbit.h"
#include "stdio.h"

MOONBIT_FFI_EXPORT
int32_t mbt_miao_print_error(int32_t len, uint8_t* data) {
    fprintf(stderr, data);
    fflush(stderr);
    return 0;
}