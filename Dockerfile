FROM solr:5

ENV VFB_OWL_VERSION=Current

ENV WORKSPACE=/opt/VFB

ENV SOLRDOCS={"id":"vfb:individual:http://virualflybrain.org/data/Court2017","iri":"http://virualflybrain.org/data/Court2017","short_form":"Court2017","shortform_autosuggest":["Court2017","Court2017"],"obo_id":"Court2017","label":"Court2017","label_autosuggest":"Court2017","label_autosuggest_ws":"Court2017","label_autosuggest_e":"Court2017","autosuggest":["Court2017"],"autosuggest_e":["Court2017"],"description":["Court2017 DataSet"],"ontology_name":"vfb","ontology_title":"Virtual Fly Brain Knowledge Base","ontology_prefix":"VFB","ontology_iri":"http://purl.obolibrary.org/obo/fbbt/vfb/vfb.owl","type":"individual","is_defining_ontology":true,"has_children":false,"is_root":true}

RUN chmod -R 777 /opt/solr

ENV SOLR_HOME=/opt/VFB/OLS/ols-solr/src/main/solr-5-config
ENV solr.data.dir=/opt/solr/server/solr

USER root

RUN apt-get -qq update && \
  apt-get -qq -y install git maven openjdk-8-jdk apt-transport-https tree apt-utils nano && \
  rm -rf /var/lib/apt/lists/*
  
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN echo Building OLS && \
mkdir -p ${WORKSPACE} && \
cd ${WORKSPACE} && \
git clone --quiet https://github.com/EBISPOT/OLS.git

COPY application-vfb.properties ${WORKSPACE}/OLS/ols-apps/ols-solr-app/src/main/resources/application-vfb.properties

RUN cd ${WORKSPACE}/OLS && \
mvn -q clean package

COPY loadOLS.sh /opt/VFB/loadOLS.sh

RUN chmod -R 777 /opt || :

RUN chmod +x /opt/VFB/loadOLS.sh

RUN curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg && \
  install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/
  
RUN echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" > /etc/apt/sources.list.d/conda.list

RUN apt-get -qq update && \
  apt-get -qq -y install conda

#USER $SOLR_USER

ENTRYPOINT ["/opt/VFB/loadOLS.sh"]
