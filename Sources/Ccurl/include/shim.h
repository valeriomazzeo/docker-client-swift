//
//  shim.h
//  Ccurl
//
//  Created by Valerio Mazzeo on 12/11/2017.
//  Copyright (c) 2017 Valerio Mazzeo. All rights reserved.
//

#import <curl/curl.h>

typedef size_t (*curl_func)(void * ptr, size_t size, size_t num, void * user_data);

static inline CURLcode curl_easy_setopt_long(CURL *handle, CURLoption option, long value)
{
    return curl_easy_setopt(handle, option, value);
}

static inline CURLcode curl_easy_setopt_cstr(CURL *handle, CURLoption option, const char * value)
{
    return curl_easy_setopt(handle, option, value);
}

static inline CURLcode curl_easy_setopt_int64(CURL *handle, CURLoption option, long long value)
{
    return curl_easy_setopt(handle, option, value);
}

static inline CURLcode curl_easy_setopt_slist(CURL *handle, CURLoption option, struct curl_slist * value)
{
    return curl_easy_setopt(handle, option, value);
}

static inline CURLcode curl_easy_setopt_void(CURL *handle, CURLoption option, void * value)
{
    return curl_easy_setopt(handle, option, value);
}

static inline CURLcode curl_easy_setopt_func(CURL *handle, CURLoption option, curl_func value)
{
    return curl_easy_setopt(handle, option, value);
}

static inline CURLcode curl_easy_getinfo_long(CURL *handle, CURLINFO option, long * value)
{
    return curl_easy_getinfo(handle, option, value);
}

static inline CURLcode curl_easy_getinfo_cstr(CURL *handle, CURLINFO option, const char ** value)
{
    return curl_easy_getinfo(handle, option, value);
}

static inline CURLcode curl_easy_getinfo_double(CURL *handle, CURLINFO option, double * value)
{
    return curl_easy_getinfo(handle, option, value);
}

static inline CURLcode curl_easy_getinfo_slist(CURL *handle, CURLINFO option, struct curl_slist ** value)
{
    return curl_easy_getinfo(handle, option, value);
}
