#!/bin/bash

init-solr-home

solr start -p 8983 -Dsolr.solr.home=/opt/VFB/OLS/ols-solr/src/main/solr-5-config/ -Dsolr.data.dir=/opt/VFB/OLS/ols-solr/src/main/solr-5-config

cd ${WORKSPACE}/
wget https://github.com/VirtualFlyBrain/VFB_owl/raw/${VFB_OWL_VERSION}/src/owl/vfb.owl.gz
gzip -d vfb.owl.gz

curl -sSf http://localhost:8983/solr

curl -sSf http://localhost:8983/solr/ontology

curl -sSf http://localhost:8983/solr/ontology/select

java -Xmx2g -jar -Dspring.profiles.active=vfb ${WORKSPACE}/OLS/ols-apps/ols-solr-app/target/ols-solr-app.jar

solr stop

solr-foreground -Dsolr.solr.home=/opt/VFB/OLS/ols-solr/src/main/solr-5-config/ -Dsolr.data.dir=/opt/VFB/OLS/ols-solr/src/main/solr-5-config
