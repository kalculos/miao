#include "moonbit.h"
#ifdef _WIN32
#include "winsock2.h"
#else
#include <sys/socket.h>
#endif
#include "string.h"

typedef struct sockaddr sockaddr_t;

MOONBIT_FFI_EXPORT
sa_family_t mbt_miao_get_safamily(sockaddr_t *addr)
{
    return addr->sa_family;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbt_miao_get_sadata(sockaddr_t *addr)
{
    int32_t len = sizeof(addr->sa_data);
    moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
    memcpy(bytes, &addr->sa_family, len);
    return bytes;
}

#ifndef _WIN32
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/un.h>
#else
/* on Windows winsock2.h is already included above; IPv6 support is in Ws2tcpip.h if needed */
#endif

MOONBIT_FFI_EXPORT
uint16_t mbt_miao_get_sin_port(sockaddr_t *addr)
{
    struct sockaddr_in *a = (struct sockaddr_in *)addr;
    return ntohs(a->sin_port);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbt_miao_get_sin_addr(sockaddr_t *addr)
{
    struct sockaddr_in *a = (struct sockaddr_in *)addr;
    int32_t len = sizeof(a->sin_addr.s_addr);
    moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
    memcpy(bytes, &a->sin_addr.s_addr, len);
    return bytes;
}

MOONBIT_FFI_EXPORT
uint16_t mbt_miao_get_sin6_port(sockaddr_t *addr)
{
    struct sockaddr_in6 *a = (struct sockaddr_in6 *)addr;
    return ntohs(a->sin6_port);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbt_miao_get_sin6_addr(sockaddr_t *addr)
{
    struct sockaddr_in6 *a = (struct sockaddr_in6 *)addr;
    int32_t len = sizeof(a->sin6_addr.s6_addr);
    moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
    memcpy(bytes, a->sin6_addr.s6_addr, len);
    return bytes;
}

MOONBIT_FFI_EXPORT
uint32_t mbt_miao_get_sin6_flowinfo(sockaddr_t *addr)
{
    struct sockaddr_in6 *a = (struct sockaddr_in6 *)addr;
    return a->sin6_flowinfo;
}

MOONBIT_FFI_EXPORT
uint32_t mbt_miao_get_sin6_scope_id(sockaddr_t *addr)
{
    struct sockaddr_in6 *a = (struct sockaddr_in6 *)addr;
    return a->sin6_scope_id;
}

#ifndef _WIN32
MOONBIT_FFI_EXPORT
moonbit_bytes_t mbt_miao_get_sun_path(sockaddr_t *addr)
{
    struct sockaddr_un *u = (struct sockaddr_un *)addr;
    int32_t max_len = sizeof(u->sun_path);
    int32_t real_len = (int32_t)strnlen(u->sun_path, max_len);
    /* return path without the trailing NUL */
    moonbit_bytes_t bytes = moonbit_make_bytes(real_len, 0);
    if (real_len > 0)
        memcpy(bytes, u->sun_path, real_len);
    return bytes;
}
#else
MOONBIT_FFI_EXPORT
moonbit_bytes_t mbt_miao_get_sun_path(sockaddr_t *addr)
{
    /* Windows does not support sockaddr_un; return empty bytes */
    return moonbit_make_bytes(0, 0);
}
#endif

sa_family_t mbt_miao_safamily_inet()
{
    return AF_INET;
}
sa_family_t mbt_miao_safamily_inet6()
{
    return AF_INET6;
}
sa_family_t mbt_miao_safamily_unix()
{
#ifdef _WIN32
    return AF_UNSPEC; /* Windows does not support AF_UNIX */
#else
    return AF_UNIX;
#endif
}