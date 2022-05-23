#!/bin/bash

#--------------------------sbatch header------------------------#

#SBATCH --job-name=genotype
#SBATCH --time=23:99:99
#SBATCH --ntasks=1
#SBATCH --mem=110GB
#SBATCH -p m3tb



#---------------------------------------------------------------#
module load jdk
module add gatk/3.5.0

#java -Xmx495g -jar /apps/gatk/3.5.0/GenomeAnalysisTK.jar \
#    -T GenotypeGVCFs \
#    -R /OSM/CBR/NRCA_FINCHGENOM/data/2015-10-01_quail/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel.fa \
#    --variant /OSM/CBR/NRCA_FINCHGENOM/analysis/2015-10-01_quail/gatk/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel/2019-06_quail_all_new_gvcf.list \
#    -o /OSM/CBR/NRCA_FINCHGENOM/analysis/2015-10-01_quail/gatk/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel/2019/2019_quail_complete.new.all.gvcf.raw.vcf 2> /OSM/CBR/NRCA_FINCHGENOM/analysis/2015-10-01_quail/gatk/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel/2019/2019_quail_complete.new.all.gvcf.raw.log
#
#java -Xmx100g -jar /apps/gatk/3.5.0/GenomeAnalysisTK.jar \
#    -T SelectVariants \
#    -R /OSM/CBR/NRCA_FINCHGENOM/data/2015-10-01_quail/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel.fa \
#    -V /OSM/CBR/NRCA_FINCHGENOM/analysis/2015-10-01_quail/gatk/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel/2019/2019_quail_complete.new.all.gvcf.raw.vcf \
#    -selectType SNP \
#    -o /OSM/CBR/NRCA_FINCHGENOM/analysis/2015-10-01_quail/gatk/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel/2019/2019_quail_complete.new.all.gvcf.raw.snps.vcf 2> /OSM/CBR/NRCA_FINCHGENOM/analysis/2015-10-01_quail/gatk/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel/2019/2019_quail_complete.new.all.gvcf.raw.snps.log
#
java -Xmx100g -jar /apps/gatk/3.5.0/GenomeAnalysisTK.jar \
    -T VariantFiltration \
    -R /OSM/CBR/NRCA_FINCHGENOM/data/2015-10-01_quail/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel.fa \
    -V /OSM/CBR/NRCA_FINCHGENOM/analysis/2015-10-01_quail/gatk/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel/2019/2019_quail_complete.new.Z.gvcf.raw.snps.male.recode.vcf \
    --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || SOR > 4.0 || ReadPosRankSum < -8.0" \
    --filterName "snps_0" \
    -o /OSM/CBR/NRCA_FINCHGENOM/analysis/2015-10-01_quail/gatk/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel/2019/2019_quail_complete.new.Z.gvcf.filtered.snps.male.vcf 2> /OSM/CBR/NRCA_FINCHGENOM/analysis/2015-10-01_quail/gatk/Taeniopygia_guttata.taeGut3.2.4.dna_sm.toplevel/2019/2019_quail_complete.new.Z.gvcf.filtered.snps.male.log


