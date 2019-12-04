FROM solr:7-alpine

ARG SOLR_ROOT='/opt/solr'
ARG SOLR_DEFAULT_CONF_DIR="${SOLR_ROOT}/server/solr/configsets/_default/conf"
ARG EZ_TEMPLATE_DIR="${SOLR_ROOT}/server/ez/template"

# Copy solr config from the version used by eZ Platform
COPY lib/Resources/config/solr/ ${SOLR_ROOT}/server/tmp

# Prepare config
RUN mkdir -p ${SOLR_ROOT}/server/ez/template \
 && cp -R ${SOLR_ROOT}/server/tmp/* ${EZ_TEMPLATE_DIR} \
 && cp ${SOLR_DEFAULT_CONF_DIR}/solrconfig.xml ${EZ_TEMPLATE_DIR} \
 && cp ${SOLR_DEFAULT_CONF_DIR}/stopwords.txt ${EZ_TEMPLATE_DIR} \
 && cp ${SOLR_DEFAULT_CONF_DIR}/synonyms.txt ${EZ_TEMPLATE_DIR} \
 && cp ${SOLR_ROOT}/server/solr/solr.xml ${SOLR_ROOT}/server/ez \
 && sed -i.bak '/<updateRequestProcessorChain name="add-unknown-fields-to-the-schema">/,/<\/updateRequestProcessorChain>/d' ${EZ_TEMPLATE_DIR}/solrconfig.xml \
 && sed -ie 's/${solr.autoSoftCommit.maxTime:-1}/${solr.autoSoftCommit.maxTime:20}/' ${EZ_TEMPLATE_DIR}/solrconfig.xml

# Set our core config as home
ENV SOLR_HOME ${SOLR_ROOT}/server/ez

# Make sure core is created on startup
CMD ["solr-create", "-c", "collection1", "-d", "/opt/solr/server/ez/template"]
