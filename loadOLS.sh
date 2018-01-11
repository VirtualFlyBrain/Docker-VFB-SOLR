#!/bin/bash

precreate-core ontology ${WORKSPACE}/OLS/ols-solr/src/main/solr-5-config/ontology
precreate-core autosuggest ${WORKSPACE}/OLS/ols-solr/src/main/solr-5-config/autosuggest

cp -f /opt/VFB/OLS/ols-solr/src/main/solr-5-config/solr.xml /opt/solr/server/solr/

solr start -p 8984

java -Xmx2g -jar -Dspring.profiles.active=fbbt ${WORKSPACE}/OLS/ols-apps/ols-solr-app/target/ols-solr-app.jar

solr stop

solr-foreground
