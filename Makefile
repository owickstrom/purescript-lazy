# PureScript to native binary (via C++) Makefile
#
# Run 'make' or 'make release' to build an optimized release build
# Run 'make debug' to build a non-optimized build suitable for debugging
#
# You can also perform a parallel build with 'make -jN', where N is the
# number of cores to use.
#
# PCC, PURESCRIPT_PKGS, OUTPUT, and BIN can all be overridden with the
# command itself. For example: 'make PURESCRIPT_PKGS=../gitpackages BIN=myexe'
#
# Flags can be added to either the codegen or native build phases.
# For example: 'make PCCFLAGS=--no-tco CXXFLAGS=-DDEBUG LDFLAGS=lobjc'
#
# You can also edit the generated version of this file directly.
#
PCC             := /home/owi/.local/bin/pcc
PSC_PKG_BIN     := psc-package
PSC_PACKAGE     := /home/owi/.local/bin/$(PSC_PKG_BIN)
PURESCRIPT_PKGS := .psc-package
PURESCRIPT_SRC  := src
OUTPUT          := output
BIN             := main
OBJ             := purescript.o

override PCCFLAGS += --comments
override CXXFLAGS += -std=c++11
override LDFLAGS  +=

ifeq ("$(wildcard $(PSC_PACKAGE))","")
	PSC_PACKAGE := $(PSC_PKG_BIN)
endif

ifeq ($(GC),yes)
  override CXXFLAGS += -DUSE_GC
  override LDFLAGS += -lgc
endif

DEBUG := "-DDEBUG -g"
RELEASE := "-O3 -flto"

INCLUDES := -I $(OUTPUT)
BIN_DIR := $(OUTPUT)/bin

release: codegen
	@$(MAKE) $(BIN) CXXFLAGS+=$(RELEASE)

debug: codegen
	@$(MAKE) $(BIN) CXXFLAGS+=$(DEBUG)

release-object: codegen
	@$(MAKE) $(OBJ) CXXFLAGS+=$(RELEASE)

debug-object: codegen
	@$(MAKE) $(OBJ) CXXFLAGS+=$(DEBUG)

codegen: PURESCRIPT_PKG_SRCS=$(shell find $(PURESCRIPT_PKGS) -name '*.purs' | grep -v \/test\/ | grep -v \/example\/ | grep -v \/examples\/)
codegen: PURESCRIPT_SRCS=$(shell find $(PURESCRIPT_SRC) -name '*.purs')
#
codegen: $(PURESCRIPT_PKGS)
	@$(PCC) $(PCCFLAGS) --output $(OUTPUT) $(PURESCRIPT_PKG_SRCS) $(PURESCRIPT_SRCS)

$(PURESCRIPT_PKGS):
	@echo "Getting packages using" $(PSC_PACKAGE) "..."
	@$(PSC_PACKAGE) update

SRCS := $(shell find $(OUTPUT) 2>/dev/null -name '*.cc')

OBJS = $(SRCS:.cc=.o)
DEPS = $(SRCS:.cc=.d)

$(BIN): $(OBJS)
	@echo "Linking" $(BIN_DIR)/$(BIN)
	@mkdir -p $(BIN_DIR)
	@$(CXX) $^ -o $(BIN_DIR)/$@ $(LDFLAGS)

$(OBJ): $(OBJS)
	@echo "Creating combined object file" $(BIN_DIR)/$(OBJ)
	@mkdir -p $(BIN_DIR)
	@$(LD) -r $^ -o $(BIN_DIR)/$@ $(LDFLAGS)

-include $(DEPS)

%.o: %.cc
	@echo "Creating" $@
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -MMD -MP -c $< -o $@

.PHONY: clean
clean:
	@-rm -rf $(OUTPUT)
