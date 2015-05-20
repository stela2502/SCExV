source ('Tool_Plot.R')
load( 'norm_data.RData')

data <- analyse.data ( data.filtered, groups.n=3, onwhat='mds', mds.type="PCA", cmethod='ward' )

save( data, file="analysis.RData" )


library('SingleCellAssay') 
library(abind)
library(reshape)
library(ggplot2)

d <- data.filtered$z$PCR
d[which(d==-20)] <- NA
x <- as.matrix(d)
d[is.na(d)] <- 0
sca <- FromMatrix('SingleCellAssay', as.matrix(d), data.frame(wellKey=rownames(d)), data.frame(primerid=colnames(d)) )
groupings <- read.delim('2D_data_color.xls', sep=' ')
groupings$groupID <- as.integer(as.factor(groupings$colorname))
groupings$groupID <- paste( 'A', groupings$groupID )
groups <- cData(sca)$GroupName <- groupings$groupID[match(cData(sca)$wellKey, rownames(groupings))]
cData(sca)$Plate <- NULL
cData(sca)$Plate[grep ("P0",cData(sca)$wellKey)] <- 'P0'
cData(sca)$Plate[grep ("P1",cData(sca)$wellKey)] <- 'P1'
cData(sca)$Plate[grep ("P2",cData(sca)$wellKey)] <- 'P2'
cData(sca)$Plate[grep ("P3",cData(sca)$wellKey)] <- 'P3'

zlm.output <- zlm.SingleCellAssay(~ GroupName, sca, method='glm', ebayes=T)
coefAndCI <- summary(zlm.output, logFC=FALSE)
coefAndCI <- coefAndCI[contrast != '(Intercept)',]
coefAndCI[,contrast:=abbreviate(contrast)]
zlm.lr <- lrTest(zlm.output,'GroupName')
pvalue <- ggplot(melt(zlm.lr[,,'Pr(>Chisq)']), aes(x=primerid, y=-log10(value)))+ geom_bar(stat='identity')+facet_wrap(~test.type) + coord_flip()
png ('Analysis1.png', width=800, height=800)
print(pvalue)
dev.off()


write.table( zlm.lr[,,'Pr(>Chisq)'], file="Significant_genes.csv", sep='\t')

## get the patched violin plot function
source('~/workspace/HTpcrA-0.60/root/R_lib/Tool_Plot.R')
plot.violines( x, max(groups), clus = groups)

l <- lapply(data$stats, function(x) {if ( !is.null(x[[2]]) ) {x[[2]]}else{ NA } } )
Statsistics <-  data.frame( gene = as.vector(names(l)), lincor = as.vector(unlist(l)))

for ( i in 1:nrow(GOI) ){
	Statsistics[which(Statsistics[,'gene'] == rownames(GOI)[i]),'anova'] =  GOI[i,'GOI']
}       
Statsistics[is.na(Statsistics[,2]),2] <- 0
Statsistics[which(Statsistics[,2] > 0.1 & Statsistics[,3] < 1e-5 ),]
plottable <- zlm.lr[,,'Pr(>Chisq)']
plottable <- cbind( plottable, Statsistics[,2])
colnames(plottable)[4] <- 'Lang_Lin'

#pvalue <- ggplot(melt(plottable), aes(x=primerid, y=-log10(value)))+ geom_bar(stat='identity')+facet_wrap(~colnames(plottable)) + coord_flip()
#print(pvalue)
