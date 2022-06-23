//
//  CppExceptionFaker.cpp
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/21.
//

#include "CppExceptionFaker.hpp"
#include <string>
#include <array>

void makeNullPointException() {
    std::string hello = nullptr;
    hello.c_str();
}

void makeWildPointerException() {
    std::string hello = "sss";
    int* p;
    *p = 1;
    hello.c_str();
}

void makeAbortException() {
    abort();
}

// CAN NOT CATCH
void makeExitException() {
    exit(0);
}

void makeCustomException() {
    throw "fake cpp exception.";
}
