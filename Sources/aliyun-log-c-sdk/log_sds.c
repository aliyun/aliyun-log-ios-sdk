/* SDSLib, A C dynamic strings library
 *
 * Copyright (c) 2006-2012, Salvatore Sanfilippo <antirez at gmail dot com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * Neither the name of Redis nor the names of its contributors may be used
 *     to endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>
#include "log_sds.h"

size_t log_sdslen(const log_sds s) {
    struct log_sdshdr *sh = (struct log_sdshdr *) (s - (sizeof(struct log_sdshdr)));
    return sh->len;
}

size_t log_sdsavail(const log_sds s) {
    struct log_sdshdr *sh = (struct log_sdshdr *) (s - (sizeof(struct log_sdshdr)));
    return sh->free;
}

/* Create a new log_sds string with the content specified by the 'init' pointer
 * and 'initlen'.
 * If NULL is used for 'init' the string is initialized with zero bytes.
 *
 * The string is always null-termined (all the log_sds strings are, always) so
 * even if you create an log_sds string with:
 *
 * mystring = log_sdsnewlen("abc",3);
 *
 * You can print the string with printf() as there is an implicit \0 at the
 * end of the string. However the string is binary safe and can contain
 * \0 characters in the middle, as the length is stored in the log_sds header. */
log_sds log_sdsnewlen(const void *init, size_t initlen) {
    struct log_sdshdr *sh;

    if (init) {
        sh = malloc(sizeof(struct log_sdshdr) + initlen + 1);
    } else {
        sh = calloc(sizeof(struct log_sdshdr) + initlen + 1, 1);
    }
    if (sh == NULL) return NULL;
    sh->len = initlen;
    sh->free = 0;
    if (initlen && init)
        memcpy(sh->buf, init, initlen);
    sh->buf[initlen] = '\0';
    return (char *) sh->buf;
}


log_sds log_sdsnewEmpty(size_t preAlloclen) {
    struct log_sdshdr *sh;

    sh = malloc(sizeof(struct log_sdshdr) + preAlloclen + 1);
    if (sh == NULL) return NULL;
    sh->len = 0;
    sh->free = preAlloclen;
    sh->buf[0] = '\0';
    return (char *) sh->buf;
}


/* Create an empty (zero length) log_sds string. Even in this case the string
 * always has an implicit null term. */
log_sds log_sdsempty(void) {
    return log_sdsnewlen("", 0);
}

/* Create a new log_sds string starting from a null terminated C string. */
log_sds log_sdsnew(const char *init) {
    size_t initlen = (init == NULL) ? 0 : strlen(init);
    return log_sdsnewlen(init, initlen);
}

/* Duplicate an log_sds string. */
log_sds log_sdsdup(const log_sds s) {
    if (s == NULL) return NULL;
    return log_sdsnewlen(s, log_sdslen(s));
}

/* Free an log_sds string. No operation is performed if 's' is NULL. */
void log_sdsfree(log_sds s) {
    if (s == NULL) return;
    free(s - sizeof(struct log_sdshdr));
}

/* Set the log_sds string length to the length as obtained with strlen(), so
 * considering as content only up to the first null term character.
 *
 * This function is useful when the log_sds string is hacked manually in some
 * way, like in the following example:
 *
 * s = log_sdsnew("foobar");
 * s[2] = '\0';
 * log_sdsupdatelen(s);
 * printf("%d\n", log_sdslen(s));
 *
 * The output will be "2", but if we comment out the call to log_sdsupdatelen()
 * the output will be "6" as the string was modified but the logical length
 * remains 6 bytes. */
void log_sdsupdatelen(log_sds s) {
    struct log_sdshdr *sh = (void *) (s - (sizeof(struct log_sdshdr)));
    int reallen = strlen(s);
    sh->free += (sh->len - reallen);
    sh->len = reallen;
}

/* Modify an log_sds string in-place to make it empty (zero length).
 * However all the existing buffer is not discarded but set as free space
 * so that next append operations will not require allocations up to the
 * number of bytes previously available. */
void log_sdsclear(log_sds s) {
    struct log_sdshdr *sh = (void *) (s - (sizeof(struct log_sdshdr)));
    sh->free += sh->len;
    sh->len = 0;
    sh->buf[0] = '\0';
}

/* Enlarge the free space at the end of the log_sds string so that the caller
 * is sure that after calling this function can overwrite up to addlen
 * bytes after the end of the string, plus one more byte for nul term.
 *
 * Note: this does not change the *length* of the log_sds string as returned
 * by log_sdslen(), but only the free buffer space we have. */
log_sds log_sdsMakeRoomFor(log_sds s, size_t addlen) {
    struct log_sdshdr *sh, *newsh;
    size_t free = log_sdsavail(s);
    size_t len, newlen;

    if (free >= addlen) return s;
    len = log_sdslen(s);
    sh = (void *) (s - (sizeof(struct log_sdshdr)));
    newlen = (len + addlen);
    if (newlen < LOG_SDS_MAX_PREALLOC)
        newlen *= 2;
    else
        newlen += LOG_SDS_MAX_PREALLOC;
    newsh = realloc(sh, sizeof(struct log_sdshdr) + newlen + 1);
    if (newsh == NULL) return NULL;

    newsh->free = newlen - len;
    return newsh->buf;
}

/* Reallocate the log_sds string so that it has no free space at the end. The
 * contained string remains not altered, but next concatenation operations
 * will require a reallocation.
 *
 * After the call, the passed log_sds string is no longer valid and all the
 * references must be substituted with the new pointer returned by the call. */
log_sds log_sdsRemoveFreeSpace(log_sds s) {
    struct log_sdshdr *sh;

    sh = (void *) (s - (sizeof(struct log_sdshdr)));
    sh = realloc(sh, sizeof(struct log_sdshdr) + sh->len + 1);
    sh->free = 0;
    return sh->buf;
}

/* Return the total size of the allocation of the specifed log_sds string,
 * including:
 * 1) The log_sds header before the pointer.
 * 2) The string.
 * 3) The free buffer at the end if any.
 * 4) The implicit null term.
 */
size_t log_sdsAllocSize(log_sds s) {
    struct log_sdshdr *sh = (void *) (s - (sizeof(struct log_sdshdr)));

    return sizeof(*sh) + sh->len + sh->free + 1;
}

/* Increment the log_sds length and decrements the left free space at the
 * end of the string according to 'incr'. Also set the null term
 * in the new end of the string.
 *
 * This function is used in order to fix the string length after the
 * user calls log_sdsMakeRoomFor(), writes something after the end of
 * the current string, and finally needs to set the new length.
 *
 * Note: it is possible to use a negative increment in order to
 * right-trim the string.
 *
 * Usage example:
 *
 * Using log_sdsIncrLen() and log_sdsMakeRoomFor() it is possible to mount the
 * following schema, to cat bytes coming from the kernel to the end of an
 * log_sds string without copying into an intermediate buffer:
 *
 * oldlen = log_sdslen(s);
 * s = log_sdsMakeRoomFor(s, BUFFER_SIZE);
 * nread = read(fd, s+oldlen, BUFFER_SIZE);
 * ... check for nread <= 0 and handle it ...
 * log_sdsIncrLen(s, nread);
 */
void log_sdsIncrLen(log_sds s, int incr) {
    struct log_sdshdr *sh = (void *) (s - (sizeof(struct log_sdshdr)));

    if (incr >= 0)
        assert(sh->free >= (unsigned int) incr);
    else
        assert(sh->len >= (unsigned int) (-incr));
    sh->len += incr;
    sh->free -= incr;
    s[sh->len] = '\0';
}

/* Grow the log_sds to have the specified length. Bytes that were not part of
 * the original length of the log_sds will be set to zero.
 *
 * if the specified length is smaller than the current length, no operation
 * is performed. */
log_sds log_sdsgrowzero(log_sds s, size_t len) {
    struct log_sdshdr *sh = (void *) (s - (sizeof(struct log_sdshdr)));
    size_t totlen, curlen = sh->len;

    if (len <= curlen) return s;
    s = log_sdsMakeRoomFor(s, len - curlen);
    if (s == NULL) return NULL;

    /* Make sure added region doesn't contain garbage */
    sh = (void *) (s - (sizeof(struct log_sdshdr)));
    memset(s + curlen, 0, (len - curlen + 1)); /* also set trailing \0 byte */
    totlen = sh->len + sh->free;
    sh->len = len;
    sh->free = totlen - sh->len;
    return s;
}

/* Append the specified binary-safe string pointed by 't' of 'len' bytes to the
 * end of the specified log_sds string 's'.
 *
 * After the call, the passed log_sds string is no longer valid and all the
 * references must be substituted with the new pointer returned by the call. */
log_sds log_sdscatlen(log_sds s, const void *t, size_t len) {
    struct log_sdshdr *sh;
    size_t curlen = log_sdslen(s);

    s = log_sdsMakeRoomFor(s, len);
    if (s == NULL) return NULL;
    sh = (void *) (s - (sizeof(struct log_sdshdr)));
    memcpy(s + curlen, t, len);
    sh->len = curlen + len;
    sh->free = sh->free - len;
    s[curlen + len] = '\0';
    return s;
}


log_sds log_sdscatchar(log_sds s, char c) {
    struct log_sdshdr *sh;
    size_t curlen = log_sdslen(s);

    s = log_sdsMakeRoomFor(s, 1);
    if (s == NULL) return NULL;
    sh = (void *) (s - (sizeof(struct log_sdshdr)));
    s[curlen] = c;
    s[curlen + 1] = '\0';
    ++sh->len;
    --sh->free;
    return s;
}


/* Append the specified null termianted C string to the log_sds string 's'.
 *
 * After the call, the passed log_sds string is no longer valid and all the
 * references must be substituted with the new pointer returned by the call. */
log_sds log_sdscat(log_sds s, const char *t) {
    if (s == NULL || t == NULL) {
        return s;
    }
    return log_sdscatlen(s, t, strlen(t));
}

/* Append the specified log_sds 't' to the existing log_sds 's'.
 *
 * After the call, the modified log_sds string is no longer valid and all the
 * references must be substituted with the new pointer returned by the call. */
log_sds log_sdscatsds(log_sds s, const log_sds t) {
    return log_sdscatlen(s, t, log_sdslen(t));
}

/* Destructively modify the log_sds string 's' to hold the specified binary
 * safe string pointed by 't' of length 'len' bytes. */
log_sds log_sdscpylen(log_sds s, const char *t, size_t len) {
    struct log_sdshdr *sh = (void *) (s - (sizeof(struct log_sdshdr)));
    size_t totlen = sh->free + sh->len;

    if (totlen < len) {
        s = log_sdsMakeRoomFor(s, len - sh->len);
        if (s == NULL) return NULL;
        sh = (void *) (s - (sizeof(struct log_sdshdr)));
        totlen = sh->free + sh->len;
    }
    memcpy(s, t, len);
    s[len] = '\0';
    sh->len = len;
    sh->free = totlen - len;
    return s;
}

/* Like log_sdscpylen() but 't' must be a null-termined string so that the length
 * of the string is obtained with strlen(). */
log_sds log_sdscpy(log_sds s, const char *t) {
    return log_sdscpylen(s, t, strlen(t));
}



/* Like log_sdscatprintf() but gets va_list instead of being variadic. */
log_sds log_sdscatvprintf(log_sds s, const char *fmt, va_list ap) {
    va_list cpy;
    char staticbuf[1024], *buf = staticbuf, *t;
    size_t buflen = strlen(fmt) * 2;

    /* We try to start using a static buffer for speed.
     * If not possible we revert to heap allocation. */
    if (buflen > sizeof(staticbuf)) {
        buf = malloc(buflen);
        if (buf == NULL) return NULL;
    } else {
        buflen = sizeof(staticbuf);
    }

    /* Try with buffers two times bigger every time we fail to
     * fit the string in the current buffer size. */
    while (1) {
        buf[buflen - 2] = '\0';
        va_copy(cpy, ap);
        vsnprintf(buf, buflen, fmt, cpy);
        va_end(cpy);
        if (buf[buflen - 2] != '\0') {
            if (buf != staticbuf) free(buf);
            buflen *= 2;
            buf = malloc(buflen);
            if (buf == NULL) return NULL;
            continue;
        }
        break;
    }

    /* Finally concat the obtained string to the SDS string and return it. */
    t = log_sdscat(s, buf);
    if (buf != staticbuf) free(buf);
    return t;
}

/* Append to the log_sds string 's' a string obtained using printf-alike format
 * specifier.
 *
 * After the call, the modified log_sds string is no longer valid and all the
 * references must be substituted with the new pointer returned by the call.
 *
 * Example:
 *
 * s = log_sdsnew("Sum is: ");
 * s = log_sdscatprintf(s,"%d+%d = %d",a,b,a+b).
 *
 * Often you need to create a string from scratch with the printf-alike
 * format. When this is the need, just use log_sdsempty() as the target string:
 *
 * s = log_sdscatprintf(log_sdsempty(), "... your format ...", args);
 */
log_sds log_sdscatprintf(log_sds s, const char *fmt, ...) {
    va_list ap;
    char *t;
    va_start(ap, fmt);
    t = log_sdscatvprintf(s, fmt, ap);
    va_end(ap);
    return t;
}


/* Append to the log_sds string "s" an escaped string representation where
 * all the non-printable characters (tested with isprint()) are turned into
 * escapes in the form "\n\r\a...." or "\x<hex-number>".
 *
 * After the call, the modified log_sds string is no longer valid and all the
 * references must be substituted with the new pointer returned by the call. */
log_sds log_sdscatrepr(log_sds s, const char *p, size_t len) {
    s = log_sdscatlen(s,"\"",1);
    while(len--) {
        switch(*p) {
            case '\\':
            case '"':
                s = log_sdscatprintf(s,"\\%c",*p);
                break;
            case '\n': s = log_sdscatlen(s,"\\n",2); break;
            case '\r': s = log_sdscatlen(s,"\\r",2); break;
            case '\t': s = log_sdscatlen(s,"\\t",2); break;
            case '\a': s = log_sdscatlen(s,"\\a",2); break;
            case '\b': s = log_sdscatlen(s,"\\b",2); break;
            default:
                if (isprint(*p))
                    s = log_sdscatprintf(s,"%c",*p);
                else
                    s = log_sdscatprintf(s,"\\\\x%02x",(unsigned char)*p);
                break;
        }
        p++;
    }
    return log_sdscatlen(s,"\"",1);
}
