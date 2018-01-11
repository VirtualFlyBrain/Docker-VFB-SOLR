FROM solr:5

ENV VFB_OWL_VERSION=Current

ENV WORKSPACE=/opt/VFB

RUN chmod -R 777 /opt/solr

ENV SOLR_HOME=/opt/VFB/OLS/ols-solr/src/main/solr-5-config
ENV solr.data.dir=/opt/solr/server/solr

USER root

RUN apt-get -qq update && \
  apt-get -qq -y install git maven openjdk-8-jdk && \
  rm -rf /var/lib/apt/lists/*

RUN echo Building OLS && \
mkdir -p ${WORKSPACE} && \
cd ${WORKSPACE} && \
git clone --quiet https://github.com/EBISPOT/OLS.git

COPY application-fbbt.properties ${WORKSPACE}/OLS/ols-apps/ols-solr-app/src/main/resources/application-fbbt.properties

RUN cd ${WORKSPACE}/OLS && \
mvn -q clean package

COPY loadOLS.sh /opt/VFB/loadOLS.sh

RUN chmod -R 777 /opt || :

RUN chmod +x /opt/VFB/loadOLS.sh

USER $SOLR_USER

ENTRYPOINT ["/opt/VFB/loadOLS.sh"]
