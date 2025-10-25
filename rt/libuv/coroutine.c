#include <stdlib.h>
#include "moonbit.h"

typedef struct tlstack
{
    tlstack_t *prev;
    void *coro_ptr;
} tlstack_t;

thread_local tlstack_t *current = NULL;

MOONBIT_FFI_EXPORT
void *moonbit_uvrt_current_coroutine()
{
    if (current == NULL)
    {
        return 0;
    }
    return current->coro_ptr;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_uvrt_has_coroutine()
{
    return current == NULL ? 0 : 1;
}

MOONBIT_FFI_EXPORT
void *moonbit_uvrt_push_coroutine_stack(void *coro)
{
    moonbit_incref(coro);
    tlstack_t *prev = current;
    tlstack_t *new = (tlstack_t *)calloc(1, sizeof(tlstack_t));
    new->prev = prev;
    new->coro_ptr = coro;
    current = new;
    return coro;
}

MOONBIT_FFI_EXPORT
void *moonbit_uvrt_pop_coroutine_stack()
{
    if(current==NULL) return NULL;
    tlstack_t* to_be_freed = current;
    void* coro_ptr = current->coro_ptr;
    current=to_be_freed->prev;
    free(to_be_freed);
    moonbit_decref(coro_ptr);
    return coro_ptr;
}