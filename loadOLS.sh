#!/bin/bash

solr start -p 8984 -Dsolr.solr.home=${SOLR_HOME}

java -Xmx2g -jar -Dspring.profiles.active=fbbt ${WORKSPACE}/OLS/ols-apps/ols-solr-app/target/ols-solr-app.jar

solr stop

solr-foreground -Dsolr.solr.home=${SOLR_HOME}
