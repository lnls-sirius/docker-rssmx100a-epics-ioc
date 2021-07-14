ARG BASE_VERSION
ARG DEBIAN_VERSION
ARG SYNAPPS_VERSION
FROM lnls/epics-synapps:${BASE_VERSION}-${SYNAPPS_VERSION}-${DEBIAN_VERSION}

ARG BASE_VERSION
ARG DEBIAN_VERSION
ARG IOC_COMMIT
ARG IOC_GROUP
ARG IOC_REPO
ARG SYNAPPS_VERSION

ENV BOOT_DIR iocrssmx100a

ENV EPICS_IOC_CAPUTLOG_INET	0.0.0.0
ENV EPICS_IOC_CAPUTLOG_PORT	7012
ENV EPICS_IOC_LOG_INET	0.0.0.0
ENV EPICS_IOC_LOG_PORT	7011

RUN git clone https://github.com/${IOC_GROUP}/${IOC_REPO}.git /opt/epics/${IOC_REPO} && \
    cd /opt/epics/${IOC_REPO} && \
    git checkout ${IOC_COMMIT} && \
    sed -i -e 's|^EPICS_BASE=.*$|EPICS_BASE=/opt/epics/base|' configure/RELEASE && \
    sed -i -e 's|^SUPPORT=.*$|SUPPORT=/opt/epics/synApps/support|' configure/RELEASE && \
    sed -i -e 's|^STREAM=.*$|STREAM=$(SUPPORT)/stream-R2-8-8/StreamDevice-2-8-8|' configure/RELEASE && \
    sed -i -e 's|^SNCSEQ=.*$|SNCSEQ=$(SUPPORT)/seq-2-2-6|' configure/RELEASE && \
    sed -i -e 's|^CALC=.*$|CALC=$(SUPPORT)/calc-R3-7-2|' configure/RELEASE && \
    sed -i -e 's|^ASYN=.*$|ASYN=$(SUPPORT)/asyn-R4-35|' configure/RELEASE && \
    sed -i -e 's|^AUTOSAVE=.*$|AUTOSAVE=$(SUPPORT)/autosave-R5-9|' configure/RELEASE && \
    sed -i -e "s|^CAPUTLOG=.*$|CAPUTLOG=${EPICS_MODULES}/${CAPUTLOG}|" configure/RELEASE && \
    make -j$(nproc) && \
    make install && \
    make clean

# Source environment variables until we figure it out
# where to put system-wide env-vars on docker-debian
RUN . /root/.bashrc

WORKDIR /opt/epics/startup/ioc/${IOC_REPO}/iocBoot/${BOOT_DIR}

ENTRYPOINT ["./runProcServ.sh"]
