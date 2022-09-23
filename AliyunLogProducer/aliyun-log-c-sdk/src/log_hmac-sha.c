

#include <stdint.h>
#include <string.h>
#include "log_sha1.h"
#include "log_hmac-sha.h"

#define LOG_IPAD 0x36
#define LOG_OPAD 0x5C


#ifndef HMAC_SHORTONLY

void log_hmac_sha1_init(log_hmac_sha1_ctx_t *s, const void *key, uint16_t keylength_b){
    uint8_t buffer[LOG_SHA1_BLOCK_BYTES];
    uint8_t i;

    memset(buffer, 0, LOG_SHA1_BLOCK_BYTES);
    if (keylength_b > LOG_SHA1_BLOCK_BITS){
        log_sha1((void*)buffer, key, keylength_b);
    } else {
        memcpy(buffer, key, (keylength_b+7)/8);
    }

    for (i=0; i<LOG_SHA1_BLOCK_BYTES; ++i){
        buffer[i] ^= LOG_IPAD;
    }
    log_sha1_init(&(s->a));
    log_sha1_nextBlock(&(s->a), buffer);

    for (i=0; i<LOG_SHA1_BLOCK_BYTES; ++i){
        buffer[i] ^= LOG_IPAD^LOG_OPAD;
    }
    log_sha1_init(&(s->b));
    log_sha1_nextBlock(&(s->b), buffer);


#if defined SECURE_WIPE_BUFFER
    memset(buffer, 0, LOG_SHA1_BLOCK_BYTES);
#endif
}

void log_hmac_sha1_nextBlock(log_hmac_sha1_ctx_t *s, const void *block){
    log_sha1_nextBlock(&(s->a), block);
}
void log_hmac_sha1_lastBlock(log_hmac_sha1_ctx_t *s, const void *block, uint16_t length_b){
    while(length_b>=LOG_SHA1_BLOCK_BITS){
        log_sha1_nextBlock(&s->a, block);
        block = (uint8_t*)block + LOG_SHA1_BLOCK_BYTES;
        length_b -= LOG_SHA1_BLOCK_BITS;
    }
    log_sha1_lastBlock(&s->a, block, length_b);
}

void log_hmac_sha1_final(void *dest, log_hmac_sha1_ctx_t *s){
    log_sha1_ctx2hash(dest, &s->a);
    log_sha1_lastBlock(&s->b, dest, LOG_SHA1_HASH_BITS);
    log_sha1_ctx2hash(dest, &(s->b));
}

#endif

/*
 * keylength in bits!
 * message length in bits!
 */
void log_hmac_sha1(void *dest, const void *key, uint16_t keylength_b, const void *msg, uint32_t msglength_b){ /* a one-shot*/
    log_sha1_ctx_t s;
    uint8_t i;
    uint8_t buffer[LOG_SHA1_BLOCK_BYTES];

    memset(buffer, 0, LOG_SHA1_BLOCK_BYTES);

    /* if key is larger than a block we have to hash it*/
    if (keylength_b > LOG_SHA1_BLOCK_BITS){
        log_sha1((void*)buffer, key, keylength_b);
    } else {
        memcpy(buffer, key, (keylength_b+7)/8);
    }

    for (i=0; i<LOG_SHA1_BLOCK_BYTES; ++i){
        buffer[i] ^= LOG_IPAD;
    }
    log_sha1_init(&s);
    log_sha1_nextBlock(&s, buffer);
    while (msglength_b >= LOG_SHA1_BLOCK_BITS){
        log_sha1_nextBlock(&s, msg);
        msg = (uint8_t*)msg + LOG_SHA1_BLOCK_BYTES;
        msglength_b -=  LOG_SHA1_BLOCK_BITS;
    }
    log_sha1_lastBlock(&s, msg, msglength_b);
    /* since buffer still contains key xor ipad we can do ... */
    for (i=0; i<LOG_SHA1_BLOCK_BYTES; ++i){
        buffer[i] ^= LOG_IPAD ^ LOG_OPAD;
    }
    log_sha1_ctx2hash(dest, &s); /* save inner hash temporary to dest */
    log_sha1_init(&s);
    log_sha1_nextBlock(&s, buffer);
    log_sha1_lastBlock(&s, dest, LOG_SHA1_HASH_BITS);
    log_sha1_ctx2hash(dest, &s);
}
