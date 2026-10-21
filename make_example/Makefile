# Example on how to build against a local installation of LiteRT / tensorflow lite.
#
# ./cmake_example shows how to build a C LiteRT application using CMake.
# This example shows how to build a C++ application using a Makefile and make.
# Because LiteRT has many dependencies and LiteRT built with cmake does not install
# shared libraries correctly, this example links against a local build of LiteRT
# which contains both libtensorflowlite.so and all of its dependencies. See
# build-local-litert.sh in this directory

FLAGS := $(CXXFLAGS) -g -fmessage-length=0 $(FLAGS)

# Native development: link against an uninstalled LiteRT cmake build tree instead of a global install.
# To build it, see ./build-local-litert.sh
# The library's RUNPATH already locates its version-specific dependencies (absl, XNNPACK, ...) in the tree.
# Cross builds (buildroot package build, or a shell that sourced buildroot's environment-setup) set CXX
# and use LiteRT from the sysroot, so only a native build with the default compiler uses the tree.

LITERT_BUILD ?= $(HOME)/LiteRT/cmake_build
TFLITE_BUILD := $(LITERT_BUILD)/tflite_build

# Cross builds (buildroot package build, or a shell that sourced buildroot's environment-setup) set CXX
# and use LiteRT from the sysroot, so only a native build with the default compiler uses the tree.

ifeq ($(origin CXX),default)
ifneq ($(wildcard $(TFLITE_BUILD)/libtensorflow-lite.so),)
# -isystem so -Wall/-Wshadow don't fire in tensorflow headers, as would be the case with a /usr/local install
# If succesfully install libtensorflow-lite.so, headers, and dependency in /usr/local then just use -I
	FLAGS := $(FLAGS) -isystem $(TFLITE_BUILD)/tensorflow-src -isystem $(LITERT_BUILD)/flatbuffers/include -isystem $(LITERT_BUILD)/abseil-cpp
	TFLITE_LDFLAGS := -L$(TFLITE_BUILD) -Wl,-rpath,$(TFLITE_BUILD)
endif
endif

CXXSTD ?= -std=c++17
FLAGS := $(CXXSTD) $(FLAGS)

TARGETS := bin/simple-interpreter

$(info FLAGS = $(FLAGS))
$(info TFLITE_LDFLAGS = $(TFLITE_LDFLAGS))
$(info TARGETS = $(TARGETS))

SIMPLE_INTERPRETER_OBJECTS := obj/simple-interpreter.o

.PHONY : all prebuild clean clobber
all : $(TARGETS)

prebuild :
	@mkdir -p bin/
	@mkdir -p obj/

clean :
	rm -rf bin/
	rm -rf obj/

# Restore tree to pristine svn co state
clobber : clean
	rm -rf bin
	rm -rf obj

bin/simple-interpreter : $(SIMPLE_INTERPRETER_OBJECTS) | prebuild
	$(CXX) -o $@ $(FLAGS) $^ $(LIBRARIES) $(TFLITE_LDFLAGS) -ltensorflow-lite

obj/%.o : %.cpp | prebuild
	$(CXX) -c -o $@ $(FLAGS) $<
