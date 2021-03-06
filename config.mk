####################################################################################################
# Configuration
# Modify variables below as new releases are made.
# Tag the commit when running the pipeline.
####################################################################################################


MSCA_VERSION = 1509

# this lists all assembly version we wish to keep live in the browser
# the last one is the default
MSCA_LIVE_VERSIONS = 1411 1504 1509

ifeq (${MSCA_VERSION},1509)
mappedOrgs = Rattus 129S1 AJ AKRJ BALBcJ C3HHeJ C57B6NJ CASTEiJ CBAJ DBA2J FVBNJ LPJ NODShiLtJ NZOHlLtJ PWKPhJ SPRETEiJ WSBEiJ CAROLIEiJ PAHARIEiJ
augustusOrgs = 129S1 AJ AKRJ BALBcJ C3HHeJ C57B6NJ CASTEiJ CBAJ DBA2J FVBNJ LPJ NODShiLtJ NZOHlLtJ PWKPhJ SPRETEiJ WSBEiJ CAROLIEiJ PAHARIEiJ
GENCODE_VERSION = VM4
TRANS_MAP_VERSION = 2015-09-28
CHAINING_VERSION = 2015-08-19
COMPARATIVE_ANNOTATOR_VERSION = 2015-09-28
augChaining = all
haveRnaSeq = yes
rnaSeqStrains = 129S1 AJ AKRJ BALBcJ C3HHeJ C57B6NJ CASTEiJ CBAJ DBA2J LPJ NODShiLtJ NZOHlLtJ PWKPhJ SPRETEiJ WSBEiJ CAROLIEiJ PAHARIEiJ FVBNJ
else ifeq (${MSCA_VERSION},1504)
mappedOrgs = Rattus 129S1 AJ AKRJ BALBcJ C3HHeJ C57B6NJ CASTEiJ CBAJ DBA2J FVBNJ LPJ NODShiLtJ NZOHlLtJ PWKPhJ SPRETEiJ WSBEiJ CAROLIEiJ PAHARIEiJ
augustusOrgs = 129S1 AJ AKRJ BALBcJ C3HHeJ C57B6NJ CASTEiJ CBAJ DBA2J FVBNJ LPJ NODShiLtJ NZOHlLtJ PWKPhJ SPRETEiJ WSBEiJ CAROLIEiJ PAHARIEiJ
GENCODE_VERSION = VM4
TRANS_MAP_VERSION = 2015-05-28
CHAINING_VERSION = 2015-08-19
COMPARATIVE_ANNOTATOR_VERSION = 2015-09-01
haveRnaSeq = yes
rnaSeqStrains = 129S1 AJ AKRJ BALBcJ C3HHeJ C57B6NJ CASTEiJ CBAJ DBA2J LPJ NODShiLtJ NZOHlLtJ PWKPhJ SPRETEiJ WSBEiJ CAROLIEiJ PAHARIEiJ
else ifeq (${MSCA_VERSION},1411)
mappedOrgs = Rattus 129S1 AJ AKRJ BALBcJ C3HHeJ C57B6NJ CASTEiJ CBAJ DBA2J FVBNJ LPJ NODShiLtJ NZOHlLtJ PWKPhJ SPRETEiJ WSBEiJ
GENCODE_VERSION = VM4
TRANS_MAP_VERSION = 2015-05-28
COMPARATIVE_ANNOTATOR_VERSION = 2015-09-01
haveRnaSeq = no
else
$(error config.mk variables not defined for MSCA_VERSION=${MSCA_VERSION})
endif

# source organism information (reference mouse)
srcOrg = C57B6J
srcOrgHgDb = mm10

