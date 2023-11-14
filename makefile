# Directories
SRCDIR := src
BUILDDIR := build
TARGETDIR := bin

# Compiler options (default to clang)
COMPILER ?= gcc

# Build type (default to release)
BUILD_TYPE := debug
ifeq ($(BUILD), release)
    BUILD_TYPE := release
endif

# Compiler and linker flags
CFLAGS := -Isrc -MMD -Wall -Wunused-result
LDFLAGS :=
ifeq ($(BUILD_TYPE), release)
    CFLAGS += -O2 -DNDEBUG
else
    CFLAGS += -g
endif

# Platform specifics
HOST_OS := $(shell uname -s)
ifeq ($(HOST_OS), Linux)
    CFLAGS += -DPLATFORM_LINUX
endif
ifeq ($(HOST_OS), Darwin)
    CFLAGS += -DPLATFORM_MACOS
endif
ifeq ($(HOST_OS), Windows_NT)
    CFLAGS += -DPLATFORM_WINDOWS
endif


# Find all the source files in the src directory and its subdirectories
SOURCES := $(shell find $(SRCDIR) -type f -name "*.c")
OBJECTS := $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(SOURCES))
DEPS := $(OBJECTS:.o=.d)
TARGET := $(TARGETDIR)/host

# Default target is to build the program
all: $(TARGET)

$(TARGET): $(OBJECTS)
	@mkdir -p $(@D)
	$(COMPILER) $^ -o $@ $(LDFLAGS)

# Pattern rule to build object files from source files
$(OBJECTS): $(BUILDDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(COMPILER) $(CFLAGS) -c $< -o $@


# Include the dependency files
-include $(DEPS)

# Clean target
clean:
	@echo " Cleaning... "
	rm -rf $(BUILDDIR) $(TARGETDIR)
	@echo " Done. "

run: all
	@./$(TARGET)

# Phony targets
.PHONY: all clean
