#   source ('~/git_Projects/SCexV/SCExV/root/R_lib/Tool_Coexpression.R')

library(corrplot)

coexpressionMatrix <- function ( dataObj ){
	if ( ! exists ( 'PCR', where =dataObj$z ) ) {
		print ( 'Wrong data type');
		return ;
	}
	if ( ! exists ( 'clusters', where =dataObj ) ) {
		print ( 'Please calculate the clusters information first');
		return ;
	}
	# data$PCR cols == genes; rows == cells
	m <- max(dataObj$clusters)
	coma <- matrix ( rep(0, m*m), ncol=m, nrow=m)
	mm <-  matrix ( rep(0,m * ncol(dataObj$z$PCR)), nrow=m)
	for ( i in 1:m ){
		## calculate the mean expression for each gene over all cells of the group
		mm[i,] <- apply( dataObj$z$PCR[which(dataObj$clusters == i ),],2,mean)
	}
	rownames(mm) <- paste('Group',1:m)
	coma <- cor(t(mm))
	dataObj$coma <- coma
	dataObj$mm <- mm
	write.table (cbind(groups = rownames(coma), coma) , file='correlation_matrix_groups.xls', sep='\t',  row.names=F,quote=F )
	colnames(mm) <- colnames(dataObj$PCR)
	write.table (cbind(groups = rownames(mm), mm) , file='mean_expression_per_groups.xls', sep='\t',  row.names=F,quote=F )
	dataObj
}

plotcoma <- function ( dataObj, fname='CorrelationPlot' ) {
	if ( ! exists ( 'coma', where =dataObj ) ) {
		if ( max(dataObj$cluster) > 1){
			dataObj <- coexpressionMatrix ( dataObj )
		}else {
			print ("I can not calculate a co-expression dataset on 1 groups!" )
			return (0)
		}
	}
	png ( file=paste(fname,'.png',sep=''), width=800, height=800 )
	corrplot(dataObj$coma, order = "hclust", method = "square", hclust.method ='single' )
	dev.off()
	if ( plotsvg == 1 ) {
		devSVG ( file=paste(fname,'.svg',sep=''), width=6, height=6 )
		corrplot(dataObj$coma, order = "hclust", method = "square", hclust.method ='single' )
		dev.off()
	}
} 

reorder_on_correlation <- function ( dataObj, order='hclust', hclust.method= 'single' ,... ) {
	if ( exists ( 'oldclusters', where=dataObj)) {
		return ( dataObj )
	}
	if ( ! exists ( 'coma', where =dataObj ) ) {
		dataObj <- coexpressionMatrix ( dataObj )
	}
	newOrder <- corrMatOrder(dataObj$coma, order=order, hclust.method=  hclust.method, ...)
	#rg <- vector('list', max(newOrder))
	#names(rg) <- 1:max(newOrder)
	dataObj$oldclusters <- dataObj$clusters
	for ( i in 1:max(dataObj$clusters) ) {
		#rg[[newOrder[i]]] <- as.vector(rownames(dataObj$PCR)[ which( dataObj$clusters == i )] )
		dataObj$clusters[ which( dataObj$oldclusters == i )] <- newOrder[i]
	}
	#regroup( dataObj, group2sample= rg )
	dataObj
}

