# Template for C++ & Haskell Mixing Project

# Output (Modifiable)
TARGET_BASE=a

# Linking (Modifiable)
CXXLDFLAGS=-lm -lpthread

# Fixing
ifeq ($(OS),Windows_NT)
	RM=cmd \/C del \/Q \/F
	MKDIR=mkdir
	RMDIR=cmd \/C rmdir
	FixPath="$(subst /,\,$1)"
	FixPathRm=$(subst /,\,$1)
	TARGET=$(TARGET_BASE).exe
else
	MKDIR=mkdir -p
	RM=rm -rf
	RMDIR=rm -rf
	FixPath=$1
	FixPathRm=$1
	TARGET=$(TARGET_BASE)
endif

# General
DEBUG?=1

# Make
ifeq ($(OS),Windows_NT)
MAKE=mingw32-make
endif

# C++ Things
CXX=g++
CXXFLAGS=-Wall -Wextra -Wshadow \
		 -Wno-virtual-dtor \
		 -Wold-style-cast \
		 -Wcast-align \
		 -Woverloaded-virtual \
		 -Wpedantic \
		 -Wconversion \
		 -Wsign-conversion \
		 -Wmisleading-indentation \
		 -Wduplicated-cond \
		 -Wduplicated-branches \
		 -Wlogical-op \
		 -Wnull-dereference \
		 -Wuseless-cast \
		 -Wdouble-promotion \
		 -Wformat=2
CXXSTD=-std=c++17
CXXEXT=cpp
SRCS=$(wildcard *.$(CXXEXT))
CXXFLAGS_DEBUG=-g
CXXFLAGS_RELEASE=-O2
ifeq ($(DEBUG), 1)
	CXXFLAGS+=$(CXXFLAGS_DEBUG)
else
	CXXFLAGS+=$(CXXFLAGS_RELEASE)
endif

# C++ Things
ifeq ($(OS),Windows_NT)
	CXXLDFLAGS+=-static
	OS_A_PRFIX=
	OS_A_SUFFIX=lib
else
	OS_A_PRFIX=lib
	OS_A_SUFFIX=a
endif
CXXBUILDPATH=.cxxbuild
CXXSRCS=$(wildcard *.$(CXXEXT))
CXXOBJS=$(addprefix $(CXXBUILDPATH)/, $(notdir $(CXXSRCS:.$(CXXEXT)=.o)))
DEPS=$(CXXOBJS:.o=.d)

# Haskell Things
GHC=ghc
HSDIR=depshs
HSEXT=hs
HSHIEXT=hi
HSOEXT=o
HSBUILDPATH=.hsbuild
HSSRCS=$(wildcard $(HSDIR)/*.$(HSEXT))
HSHIS=$(wildcard $(HSDIR)/*.$(HSHIEXT))
HSOS=$(wildcard $(HSDIR)/*.$(HSOEXT))
HSOBJS=$(addprefix $(HSBUILDPATH)/, $(notdir $(HSSRCS:.$(HSEXT)=.o)))
GHCLIBDIR=$(shell ghc --print-libdir)
HSINCLUDES=-I$(call FixPath,$(GHCLIBDIR)/include) -I$(HSDIR)
HSFLAGS=-XForeignFunctionInterface -fPIC
HSFLAGS_DEBUG=-g
HSFLAGS_RELEASE=-O2
ifeq ($(DEBUG), 1)
	HSFLAGS+=$(HSFLAGS_DEBUG)
else
	HSFLAGS+=$(HSFLAGS_RELEASE)
endif
HSLDFLAGS=-no-hs-main -lstdc++

# Combine
INCLUDES=$(CXXINCLUDES) $(HSINCLUDES)
LDFLAGS=$(CXXLDFLAGS) $(HSLDFLAGS)

.PHONY: default
default: $(TARGET)

.PHONY: release
release:
	$(MAKE) DEBUG=0

# Linking
$(TARGET): $(HSBUILDPATH) $(HSOBJS) $(CXXBUILDPATH) $(CXXOBJS)
	@echo 'LD' $(abspath $(TARGET))
	@$(GHC) -o $(TARGET) $(CXXOBJS) $(HSOBJS) $(LDFLAGS)

# C++ Sources
$(CXXBUILDPATH)/%.o: %.$(CXXEXT)
	@echo 'CXX' $(abspath $<)
	@$(CXX) $(CXXFLAGS) $(INCLUDES) $(CXXSTD) -MMD -MP -o $@ -c $<

$(CXXBUILDPATH):
	@echo 'MKDIR' $(abspath $@)
	@$(MKDIR) $(CXXBUILDPATH)

# Haskell Sources
$(HSBUILDPATH)/%.o: $(HSDIR)/%.$(HSEXT)
	@echo 'GHC' $(abspath $<)
	@$(GHC) $(HSFLAGS) -o $@ -c $<

$(HSBUILDPATH):
	@echo 'MKDIR' $(abspath $@)
	@$(MKDIR) $(HSBUILDPATH)

.PHONY: clean
clean:
	@echo 'RM' $(TARGET)
	@$(RM) $(TARGET)
	@echo 'RM' $(call FixPathRm,$(CXXOBJS))
	@$(RM) $(call FixPathRm,$(CXXOBJS))
	@echo 'RM' $(call FixPathRm,$(DEPS))
	@$(RM) $(call FixPathRm,$(DEPS))
	@echo 'RM' $(call FixPathRm,$(HSOBJS))
	@$(RM) $(call FixPathRm,$(HSOBJS))
	@echo 'RM' $(call FixPathRm,$(HSHIS))
	@$(RM) $(call FixPathRm,$(HSHIS))
	@echo 'RM' $(call FixPathRm,$(HSOS))
	@$(RM) $(call FixPathRm,$(HSOS))
	@echo 'RMDIR' $(CXXBUILDPATH)
	@$(RMDIR) $(CXXBUILDPATH)
	@echo 'RMDIR' $(HSBUILDPATH)
	@$(RMDIR) $(HSBUILDPATH)

-include $(DEPS)
