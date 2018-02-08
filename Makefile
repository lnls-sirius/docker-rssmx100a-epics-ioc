PREFIX ?= /usr/local
# This INIT_FILES_PREFIX could be different than PREFIX, as INIT_FILES_PREFIX
# is defined as the location of init scripts and must be placed in a specific
# place. The main use of this variable is for testing the build system
INIT_FILES_PREFIX ?=
BIN_FILES_PREFIX ?= /usr/local

CMDSEP = ;

PWD = 		$(shell pwd)
MKDIR =     mkdir
RMDIR =     rmdir
CP =        cp
INSTALL =   install
RM =        rm

INIT_SYSTEM := systemd

# Input files
SRC_DOCKER_FILE = Dockerfile
SERVICE_NAME = docker-rssmx100a@

# Generated names from Input
DOCKER_FILES_DEST = ${PREFIX}/etc/${SERVICE_NAME}

# All installable files grouped
DOCKER_FILES_FULL_NAME := ${SRC_DOCKER_FILE}

# Strip off a leading ./
DOCKER_FILES=$(DOCKER_FILES_FULL_NAME:./%=%)

# Script files
INIT_FILES_FULL_NAME := $(shell cd ${INIT_SYSTEM} && find etc -type f)
# Strip off a leading ./
INIT_FILES=$(INIT_FILES_FULL_NAME:./%=%)
INIT_FILES_ABS=$(INIT_FILES:%=/%)
INIT_FILES_DIR=$(dir $(INIT_FILES_PREFIX)$(INIT_FILES_ABS))

# Binary files
BIN_FILES_FULL_NAME := $(shell cd ${INIT_SYSTEM} && find bin -type f)
# Strip off a leading ./
BIN_FILES=$(BIN_FILES_FULL_NAME:./%=%)

.PHONY: all clean mrproper install uninstall

all:

install:
	${MKDIR} -p ${DOCKER_FILES_DEST}
	${MKDIR} -p ${INIT_FILES_DIR}
	$(foreach dockerfile,$(DOCKER_FILES),cp --preserve=mode --parents $(dockerfile) ${DOCKER_FILES_DEST}/ $(CMDSEP))
	$(foreach script,$(INIT_FILES),cp --preserve=mode ${INIT_SYSTEM}/$(script) ${INIT_FILES_PREFIX}/$(script) $(CMDSEP))
	$(foreach bin,$(BIN_FILES),cp --preserve=mode ${INIT_SYSTEM}/$(bin) ${BIN_FILES_PREFIX}/$(bin) $(CMDSEP))
	-./scripts/enable-service.sh -s $(SERVICE_NAME)

uninstall:
	-./scripts/disable-service.sh -s $(SERVICE_NAME)
	-$(foreach bin,$(BIN_FILES),rm -f ${BIN_FILES_PREFIX}/$(bin) $(CMDSEP))
	-$(foreach script,$(INIT_FILES),rm -f ${INIT_FILES_PREFIX}/$(script) $(CMDSEP))
	$(foreach dockerfile,$(DOCKER_FILES),rm -f ${DOCKER_FILES_DEST}/$(dockerfile) $(CMDSEP))
	-${RMDIR} ${DOCKER_FILES_DEST}

clean:

mrproper: clean
