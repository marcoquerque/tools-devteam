## Feature Selection ##
get_features <- function(myGenes, f="gene") {
    if (f == "isoforms")
        return(isoforms(myGenes))
    else if (f == "tss")
        return(TSS(myGenes))
    else if (f == "cds")
        return(CDS(myGenes))
    else
        return(myGenes)
}

## Main Function ##

library(argparse)

parser <- ArgumentParser(description='Create a plot with cummeRbund')

parser$add_argument('--type', dest='plotType', default='Density', required=TRUE)
parser$add_argument('--height', dest='height', type='integer', default=960, required=TRUE)
parser$add_argument('--width', dest='width', type='integer', default=1280, required=TRUE)
parser$add_argument('--outfile', dest='filename', default="plot-unknown-0.png", required=TRUE)
parser$add_argument('--input', dest='input_database', default="cuffData.db", required=TRUE)
parser$add_argument('--smooth', dest='smooth', action="store_true", default=FALSE)
parser$add_argument('--gene_selector', dest='gene_selector', action="store_true", default=FALSE)
parser$add_argument('--replicates', dest='replicates', action="store_true", default=FALSE)
parser$add_argument('--labcol', dest='labcol', action="store_true", default=FALSE)
parser$add_argument('--labrow', dest='labrow', action="store_true", default=FALSE)
parser$add_argument('--border', dest='border', action="store_true", default=FALSE)
parser$add_argument('--summary', dest='summary', action="store_true", default=FALSE)
parser$add_argument('--count', dest='count', action="store_true", default=FALSE)
parser$add_argument('--error_bars', dest='error_bars', action="store_true", default=FALSE)
parser$add_argument('--log10', dest='log10', action="store_true", default=FALSE)
parser$add_argument('--features', dest='features', action="store", default="genes")
parser$add_argument('--clustering', dest='clustering', action="store", default="both")
parser$add_argument('--iter_max', dest='iter_max', action="store")
parser$add_argument('--genes', dest='genes', action="append")
parser$add_argument('--k', dest='k', action="store")
parser$add_argument('--x', dest='x', action="store")
parser$add_argument('--y', dest='y', action="store")

args <- parser$parse_args()

## Load cummeRbund library
library("cummeRbund")

## Initialize cuff object
cuff <- readCufflinks(dir = "", dbFile = args$input_database, rebuild = FALSE)

## Print out info
print(cuff)
sink("cuffdb_info.txt")
print(cuff)
print("SAMPLES:")
samples(cuff)
print("REPLICATES:")
replicates(cuff)
print("FEATURES:")
print(annotation(genes(cuff)))
cat(annotation(genes(cuff))[[1]],sep=",")
sink()

png(filename = args$filename, width = args$width, height = args$height, type=c('cairo-png'))
tryCatch({
    if (args$plotType == 'density') {
        csDensity(genes(cuff), replicates=args$replicates, logMode=args$log10)
    }
    else if (args$plotType == 'boxplot') {
        csBoxplot(genes(cuff), replicates=args$replicates, logMode=args$log10)
    }
    else if (args$plotType == 'mds') {
        MDSplot(genes(cuff), replicates=args$replicates)
    }
    else if (args$plotType == 'pca') {
        PCAplot(genes(cuff), "PC1", "PC2", replicates=args$replicates)
    }
    else if (args$plotType == 'dendrogram') {
        csDendro(genes(cuff), replicates=args$replicates)
    }
    else if (args$plotType == 'scatter') {
        if (args$gene_selector) {
            myGenes <- getGenes(cuff, args$genes)
            csScatter(get_features(myGenes, args$features), args$x, args$y, smooth=args$smooth, logMode=args$log10)
        }
        else {
            csScatter(genes(cuff), args$x, args$y, smooth=args$smooth, logMode=args$log10)
        }
    }
    else if (args$plotType == 'volcano') {
        if (args$gene_selector) {
            myGenes <- get_features(getGenes(cuff, args$genes), args$features)
        }
        else {
            myGenes <- genes(cuff)
        }
        csVolcano(myGenes, args$x, args$y)
    }
    else if (args$plotType == 'heatmap') {
        if (args$gene_selector) {
            myGenes <- getGenes(cuff, args$genes)
        }
        else {
            myGenes <- getGenes(cuff,annotation(genes(cuff))[[1]])
        }
        csHeatmap(get_features(myGenes, args$features), clustering=args$clustering, labCol=args$labcol, labRow=args$labrow, border=args$border, logMode=args$log10)
    }
    else if (args$plotType == 'cluster') {
        myGenes <- getGenes(cuff, args$genes)
        csCluster(get_features(myGenes, args$features), k=args$k)
    }
    else if (args$plotType == 'dispersion') {
        dispersionPlot(genes(cuff))
    }
    else if (args$plotType == 'fpkmSCV') {
        fpkmSCVPlot(genes(cuff))
    }
    else if (args$plotType == 'scatterMatrix') {
        csScatterMatrix(genes(cuff))
    }
    else if (args$plotType == 'expressionplot') {
        myGenes <- getGenes(cuff, args$genes)
        expressionPlot(get_features(myGenes, args$features), drawSummary=args$summary, showErrorbars=args$error_bars, replicates=args$replicates)
    }
    else if (args$plotType == 'expressionbarplot') {
        myGeneId <- args$genes
        myGenes <- getGenes(cuff, myGeneId)
        expressionBarplot(get_features(myGenes, args$features), showErrorbars=args$error_bars, replicates=args$replicates)
    }
    else if (args$plotType == 'mds') {
        MDSplot(genes(cuff),replicates=args$replicates)
    }
    else if (args$plotType == 'pca') {
        PCAplot(genes(cuff),"PC1","PC2", replicates=args$replicates)
    }
    else if (args$plotType == 'maplot') {
        MAplot(genes(cuff), args$x, args$y, useCount=args$count)
    }
    else if (args$plotType == 'genetrack') {
        myGene <- getGene(cuff, args$genes)
        plotTracks(makeGeneRegionTrack(myGene))
    }
},error = function(e) {
    write(paste("Failed:", e, sep=" "), stderr())
    q("no", 1, TRUE)
})
devname = dev.off()
