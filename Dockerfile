FROM solr:5

ENV VFB_OWL_VERSION=Current

ENV WORKSPACE=/opt/VFB

USER root

RUN apt-get update && \
  apt-get -y install git maven && \
  rm -rf /var/lib/apt/lists/*

RUN echo Building OLS && \
mkdir -p ${WORKSPACE} && \
cd ${WORKSPACE} && \
git clone https://github.com/VirtualFlyBrain/OLS_configs.git && \
git clone https://github.com/EBISPOT/OLS.git && \
cp ${WORKSPACE}/OLS_configs/*.properties ${WORKSPACE}/OLS/ols-apps/ols-neo4j-app/src/main/resources/ && \
cd ${WORKSPACE}/OLS && \
mvn clean package

COPY loadOLS.sh /opt/VFB/loadOLS.sh

RUN chmod -R 777 /opt/VFB

RUN chmod +x /opt/VFB/loadOLS.sh

USER $SOLR_USER

ENTRYPOINT ["/opt/VFB/loadOLS.sh"]
