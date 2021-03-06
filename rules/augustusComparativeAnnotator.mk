include defs.mk

# jobTree configuration
batchSystem = parasol
maxThreads = 30
maxCpus = 1024
defaultMemory = 8589934592
maxJobDuration = 36000
retryCount = 3
jobTreeOpts = --defaultMemory ${defaultMemory} --batchSystem parasol --parasolCommand $(shell pwd)/bin/remparasol \
			  --maxJobDuration ${maxJobDuration} --maxThreads ${maxThreads} --maxCpus ${maxCpus} \
			  --retryCount ${retryCount} --maxJobDuration ${maxJobDuration} --stats

# call function to obtain a assembly file given an organism and extension
asmFileFunc = ${ASM_GENOMES_DIR}/$(1).$(2)

# call functions to get particular assembly files given an organism
asmFastaFunc = $(call asmFileFunc,${1},fa)
asmTwoBitFunc = $(call asmFileFunc,${1},2bit)
asmChromSizesFunc = $(call asmFileFunc,${1},chrom.sizes)

targetFastaFiles = ${augustusOrgs:%=$(call asmFastaFunc,%)}
targetChromSizes = ${augustusOrgs:%=$(call asmChromSizesFunc,%)}
queryFasta = $(call asmFastaFunc,${srcOrg})


comparativeAnnotationDir = ${ANNOTATION_DIR}_Augustus
transMapChainedAllPsls = ${augustusOrgs:%=${TRANS_MAP_DIR}/transMap/%/${augChaining}/transMap${gencodeComp}.psl}
transMapEvalAllGp = ${augustusOrgs:%=${TRANS_MAP_DIR}/transMap/%/${augChaining}/transMap${gencodeComp}.gp}
compGp = ${SRC_GENCODE_DATA_DIR}/wgEncode${gencodeComp}.gp
basicGp = ${SRC_GENCODE_DATA_DIR}/wgEncode${gencodeBasic}.gp
srcFa = ${SRC_GENCODE_DATA_DIR}/wgEncode${gencodeComp}.fa
augustusGps = ${augustusOrgs:%=${TMR_DIR}/%.gp}
consensusDir = ${comparativeAnnotationDir}/consensus
augustusStatsDir = ${comparativeAnnotationDir}/augustus_stats
augustusBeds = ${augustusOrgs:%=${augustusStatsDir}/%.bed}
augustusFastas = ${augustusOrgs:%=${augustusStatsDir}/%.fa}
augustusFaidx = ${augustusOrgs:%=${augustusStatsDir}/%.fa.fai}
metricsDir = ${comparativeAnnotationDir}/metrics


jobTreeCompAnnTmpDir = $(shell pwd)/${jobTreeRootTmpDir}/augustusComparativeAnnotator/${gencodeComp}_${augChaining}
jobTreeCompAnnJobOutput = ${jobTreeCompAnnTmpDir}/comparativeAnnotator.out
jobTreeCompAnnJobDir = ${jobTreeCompAnnTmpDir}/jobTree

jobTreeClusteringTmpDir = $(shell pwd)/${jobTreeRootTmpDir}/clustering/${gencodeComp}_${augChaining}
jobTreeClusteringJobOutput = ${jobTreeClusteringTmpDir}/clustering.out
jobTreeClusteringJobDir = ${jobTreeClusteringTmpDir}/jobTree

jobTreeAlignTmpDir = $(shell pwd)/${jobTreeRootTmpDir}/alignAugustus/${gencodeComp}_${augChaining}
jobTreeAlignJobOutput = ${jobTreeAlignTmpDir}/alignAugustus.out
jobTreeAlignJobDir = ${jobTreeAlignTmpDir}/jobTree


all: ${comparativeAnnotationDir}/DONE ${metricsDir}/DONE ${metricsDir}/CLUSTERING_DONE consensus

${comparativeAnnotationDir}/DONE: ${compGp} ${transMapChainedAllPsls} ${transMapEvalAllGp} ${augustusGps}
	@mkdir -p $(dir $@)
	@mkdir -p ${jobTreeCompAnnTmpDir}
	if [ -d ${jobTreeCompAnnJobDir} ]; then rm -rf ${jobTreeCompAnnJobDir}; fi
	cd ../comparativeAnnotator && ${python} src/annotationPipelineWithAugustus.py ${jobTreeOpts} \
	--refGenome ${srcOrg} --genomes ${augustusOrgs} --sizes ${targetChromSizes} --augustusGps ${augustusGps} \
	--psls ${transMapChainedAllPsls} --gps ${transMapEvalAllGp} --fastas ${targetFastaFiles} --refFasta ${queryFasta} \
	--annotationGp ${compGp} --gencodeAttributeMap ${srcGencodeAttrsTsv} --jobTree ${jobTreeCompAnnJobDir} \
	--outDir ${comparativeAnnotationDir} &> ${jobTreeCompAnnJobOutput}
	touch $@

${metricsDir}/DONE: ${comparativeAnnotationDir}/DONE
	@mkdir -p $(dir $@)
	cd ../comparativeAnnotator && ${python} scripts/coverage_identity_ok_plots.py \
	--outDir ${metricsDir} --genomes ${augustusOrgs} --annotationGp ${compGp} --gencode ${gencodeComp} \
	--comparativeAnnotationDir ${comparativeAnnotationDir} --attributePath ${srcGencodeAttrsTsv}
	touch $@

${metricsDir}/CLUSTERING_DONE: ${comparativeAnnotationDir}/DONE
	@mkdir -p $(dir $@)
	@mkdir -p ${jobTreeClusteringTmpDir}
	if [ -d ${jobTreeClusteringJobDir} ]; then rm -rf ${jobTreeClusteringJobDir}; fi
	cd ../comparativeAnnotator && ${python} scripts/clustering.py ${jobTreeOpts} \
	--outDir ${metricsDir} --comparativeAnnotationDir ${comparativeAnnotationDir} \
	--attributePath ${srcGencodeAttrsTsv} \
	--annotationGp ${compGp} --gencode ${gencodeComp} --genomes ${augustusOrgs} \
	--jobTree ${jobTreeClusteringJobDir} &> ${jobTreeClusteringJobOutput}
	touch $@
	

consensus: prepareTranscripts alignTranscripts makeConsensus

prepareTranscripts: ${augustusBeds} ${augustusFastas} ${augustusFaidx}

${augustusStatsDir}/%.bed: ${TMR_DIR}/%.gp
	@mkdir -p $(dir $@)
	genePredToBed $< $@.${tmpExt}
	mv -f $@.${tmpExt} $@

${augustusStatsDir}/%.fa: ${augustusStatsDir}/%.bed
	@mkdir -p $(dir $@)
	fastaFromBed -bed $< -fi ${ASM_GENOMES_DIR}/$*.fa -fo $@.${tmpExt} -s -split -name
	mv -f $@.${tmpExt} $@

${augustusStatsDir}/%.fa.fai: ${augustusStatsDir}/%.fa
	samtools faidx $<

alignTranscripts: ${augustusStatsDir}/DONE

${augustusStatsDir}/DONE: ${augustusBeds} ${augustusFastas} ${augustusFaidx}
	@mkdir -p $(dir $@)
	@mkdir -p ${jobTreeAlignTmpDir}
	if [ -d ${jobTreeAlignJobDir} ]; then rm -rf ${jobTreeAlignJobDir}; fi
	cd ../comparativeAnnotator && ${python} scripts/alignAugustus.py ${jobTreeOpts} \
	--jobTree ${jobTreeAlignJobDir} --genomes ${augustusOrgs} --refFasta ${srcFa} \
	--outDir ${augustusStatsDir} --augustusStatsDir ${augustusStatsDir} &> ${jobTreeAlignJobOutput}

makeConsensus: ${consensusDir}/DONE

${consensusDir}/DONE: ${augustusStatsDir}/DONE
	@mkdir -p $(dir $@)
	cd ../comparativeAnnotator && ${python} scripts/consensus.py --genomes ${augustusOrgs} \
	--compAnnPath ${comparativeAnnotationDir} --statsDir ${augustusStatsDir} --outDir ${consensusDir} \
	--attributePath ${srcGencodeAttrsTsv} --augGps ${augustusGps} --tmGps ${transMapEvalAllGp} --compGp ${compGp} \
	--basicGp ${basicGp}
	touch $@