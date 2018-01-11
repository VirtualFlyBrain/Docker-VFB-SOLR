#!/bin/bash

init-solr-home

solr start -p 8984

curl -sSf http://localhost:8983/solr

curl -sSf http://localhost:8983/solr/ontology

curl -sSf http://localhost:8983/solr/ontology/select

java -Xmx2g -jar -Dspring.profiles.active=fbbt ${WORKSPACE}/OLS/ols-apps/ols-solr-app/target/ols-solr-app.jar

solr stop

solr-foreground
