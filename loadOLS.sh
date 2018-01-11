#!/bin/bash

start-local-solr

java -Xmx2g -jar -Dspring.profiles.active=fbbt ${WORKSPACE}/OLS/ols-apps/ols-solr-app/target/ols-solr-app.jar

stop-local-solr

solr-foreground
