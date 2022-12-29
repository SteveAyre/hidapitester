#
# Makefile for 'hidapitester'
# 2019 Tod E. Kurt, todbot.com
#

# overide this with something like `HIDAPI_DIR=../hidapi-libusb make`
HIDAPI_DIR ?= ../hidapi

# try to do some autodetecting
UNAME := $(shell uname -s)
ARCH := $(shell uname -m)

ifeq "$(UNAME)" "Darwin"
	OS=macos
endif
ifeq "$(OS)" "Windows_NT"
	OS=windows
endif
ifeq "$(UNAME)" "Linux"
	OS=linux
endif
ifeq "$(UNAME)" "FreeBSD"
	OS=freebsd
endif


#############  Mac
ifeq "$(OS)" "macos"

CFLAGS+=-arch x86_64 -arch arm64
LIBS=-framework IOKit -framework CoreFoundation -framework AppKit
OBJS=$(HIDAPI_DIR)/mac/hid.o
EXE=

endif

############# Windows
ifeq "$(OS)" "windows"

# deal with Windows not having 'cc'
ifeq (default,$(origin CC))
  CC = gcc
endif

LIBS += -lsetupapi -Wl,--enable-auto-import -static-libgcc -static-libstdc++
OBJS = $(HIDAPI_DIR)/windows/hid.o
EXE=.exe

endif

############ Linux (hidraw)
ifeq "$(OS)" "linux"

#PKGS = libudev 

#ifneq ($(wildcard $(HIDAPI_DIR)),)
#OBJS = $(HIDAPI_DIR)/linux/hid.o
#else
#PKGS += hidapi-hidraw hidapi-libusb
#endif

#CFLAGS += $(shell pkg-config --cflags $(PKGS))
#LIBS = $(shell pkg-config --libs $(PKGS))
#EXE=

LIBS += -lhdapi-hidraw -lhidapi-libusb

endif

########### FreeBSD
ifeq "$(OS)" "freebsd"

CFLAGS += -I/usr/local/include
OBJS = $(HIDAPI_DIR)/libusb/hid.o
LIBS += -L/usr/local/lib -lusb -liconv -pthread
EXE=

endif

############# common

CFLAGS += -I $(HIDAPI_DIR)/hidapi
OBJS += hidapitester.o

all: hidapitester

$(OBJS): %.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@


hidapitester: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o hidapitester$(EXE) $(LIBS)

clean:
	rm -f $(OBJS)
	rm -f hidapitester$(EXE)

package: hidapitester$(EXE)
	@echo "Packaging up hidapitester for '$(OS)-$(ARCH)'"
	zip hidapitester-$(OS)-$(ARCH).zip hidapitester$(EXE)
