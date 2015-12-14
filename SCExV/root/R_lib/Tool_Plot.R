library(gplots)
options(rgl.useNULL=TRUE)

library(rgl)
library(RDRToolbox)
library(vioplot)
library(beanplot)

library(RSvgDevice)


FACS.heatmap <- function ( dataObj, ofile, title='Heatmap', nmax=500, hc.row=NA, ColSideColors=NA, RowSideColors=NA,
		width=6, height=6, margins = c(15, 10), hclustfun = function(c){hclust( c, method='ward')}, distfun = function (x) as.dist( 1- cor(t(x), method='pearson') ), ... ) {
	##plot the heatmap as svg image
	if ( nrow(dataObj$data) > nmax ) {
		stop (paste('No plotting for file ',ofile,'- too many genes selected (',nrow(dataObj$data),')' ))
	}
	if( nrow(dataObj$data) > 2 ){
		for ( i in 1:2 ){
			rownames( dataObj$data ) <- paste( dataObj$genes, dataObj$names)
			if ( i == 1 && plotsvg == 1 ) {
				devSVG( file=paste(ofile,'_Heatmap.svg',sep='') , width=width, height=height)
			}
			else {
				png( file=paste(ofile,'_Heatmap.png',sep='') , width=width*150, height=nrow( dataObj$data ) * 15 + 400 )
			}
			if ( is.na(hc.row) ){
				
				hc.row <- hclustfun(distfun(dataObj$data)) #hclust( as.dist( 1- cor(t(dataObj$data), method='spearman')), method='ward')
			}
			ma <- dataObj$data[hc.row$order,]
			if ( ! is.na(RowSideColors) ) {
				RowSideColors <- RowSideColors[ hc.row$order ]
			} 
			if ( ! is.na(ColSideColors) ) {
				if ( ! is.na(RowSideColors)) {
					heatmap.2(as.matrix(ma), col=bluered, Rowv=F,  key=F, symkey=FALSE,
							trace='none', cexRow=2,cexCol=0.7, main=title,margins = margins, 
							ColSideColors=ColSideColors, RowSideColors=RowSideColors, hclustfun = hclustfun, distfun = distfun,dendrogram='both', ... )
				}
				else {
					heatmap.2(as.matrix(ma), col=bluered, Rowv=T,  key=F, symkey=FALSE,
							trace='none', cexRow=2,cexCol=0.7, main=title,margins = margins, 
							ColSideColors=ColSideColors, hclustfun = hclustfun, distfun = distfun,dendrogram='both',... )
				}
			}
			else {
				heatmap.2(as.matrix(ma), col=bluered, Rowv=F,  key=F, symkey=FALSE,
						trace='none', cexRow=2,cexCol=0.7, main=title,margins = margins,
						hclustfun = hclustfun, distfun = distfun, ... )
			}
			dev.off()
		}
		write.table( cbind ( 'GeneSymbol' = rownames(ma), 'groupsID' = hc.row$order[hc.row$order], ma),file= paste(ofile,'_data4Genesis.txt', sep=''),sep='\t', row.names=F, sep="\t",quote=F  )
		write ( rownames(ma),file= paste(ofile,'_Genes_in_order.txt',sep='') ,ncolumns = 1 )
	}
	else {
		print ( paste( 'You have less than two genes for the histogram (',nrow(ma),', ',ofile,') '))
	}
	hc.row
}

collapsData <- function ( dataObj, method='median' ) {
	ret <- matrix ( ncol= max(dataObj$clusters),nrow= ncol(data$z$PCR))
	colnames(ret) <- paste('Cluster', 1:ncol(ret))
	rownames(ret) <- colnames(dataObj$z$PCR)
	for ( genecol in 1:nrow(ret) ) { ## genes
		for ( cluster in 1:ncol(ret) ){
			if ( method == 'median' ){
				ret[genecol,cluster] = median(dataObj$z$PCR[which(dataObj$clusters == cluster),genecol ] )
			}else if ( method == 'mean' ){
				ret[genecol,cluster] = mean(dataObj$z$PCR[which(dataObj$clusters == cluster),genecol ] )
			}else if ( method == 'var' ){
				ret[genecol,cluster] = var(dataObj$z$PCR[which(dataObj$clusters == cluster),genecol ] )
			}else if ( method == 'quantile70' ){
				ret[genecol,cluster] = as.vector(quantile(dataObj$z$PCR[which(dataObj$clusters == cluster),genecol ],0.7 ))
			}
			
			else{
				stop('method not implemented!')
			}
			
		}
	}
	if ( length( which(apply(ret,1,var) == 0))> 0 ){
		ret <- ret[-which(apply(ret,1,var) == 0),]
	}
	ret
}

collapsed_heatmaps <- function ( dataObj, what='PCR', functions = c('median', 'mean', 'var', 'quantile70' ) ) {
	if ( ! is.vector(functions) ){
		functions = c( functions )
	}
	data <- NULL
	if ( what == 'PCR' ){
		data = dataObj$z$PCR
	}else if ( what =='FACS' ){
		data = dataObj$FACS
	}else {
		stop('collapsed_heatmaps can only collaps PCR or FACS data' )
	}
	if ( !is.null(data)){
		for( i in 1:length(functions)) {
			reduced.filtered <- collapsData( data ,method=functions[i])
			PCR.heatmap ( dataObj= list( data= reduced.filtered, genes= rownames(reduced.filtered)), ofile=paste(what,functions[i],sep="_") , margins=c(3,10),ColSideColors=rainbow(max(data$clusters)), Colv=F, Rowv=F, title=functions[i],RowSideColors=1)
		}
	}
}

PCR.heatmap <- function ( dataObj, ofile, title='Heatmap', nmax=500, hc.row=NA, ColSideColors=NA, RowSideColors=F,
		width=6, height=6, margins = c(1,11) ,lwid = c( 1,6), lhei=c(1,5), hclustfun = function(c){hclust( c, method='ward.D')}, distfun = function (x) as.dist( 1- cor(t(x), method='pearson') ), Rowv=T, ... ) {
	##plot the heatmap as svg image
	if ( nrow(dataObj$data) > nmax ) {
		stop (paste('No plooting for file ',ofile,'- too many genes selected (',nrow(dataObj$data),')' ))
	}
	if( nrow(dataObj$data) > 2 ){
		brks <- as.vector(c(-20,quantile(dataObj$data[which(dataObj$data!= -20)],seq(0,1,by=0.1)),max(dataObj$data)))
		#rownames( dataObj$data ) <- paste( dataObj$genes, dataObj$names)
		if ( is.na(hc.row) ){
			hc.row <- hclustfun(distfun(dataObj$data)) #hclust( as.dist( 1- cor(t(dataObj$data), method='spearman')), method='ward')
		}
		dendrogram='both'
		if ( length(grep ('color_groups', ofile)) == 0 ) {
			ma <- dataObj$data[hc.row$order,]
			dendrogram='both'
		}
		else {
			ma <- dataObj$data
			dendrogram='row'
		}
		if ( ! RowSideColors==F ) {
			ma <- ma[match(geneGroups[order(geneGroups[,3]),1],rownames(ma)),]
			if ( dendrogram=='both'){
				dendrogram='col'
			}else {
				dendrogram='none'
			}
		}
		if (  plotsvg == 1) {
			devSVG( file=paste(ofile,'_Heatmap.svg',sep='') , width=width, height=height)
			if ( ! is.na(ColSideColors) ) {
				if ( RowSideColors != F) {
					heatmap.2(as.matrix(ma), breaks=brks,col=c("darkgrey",bluered(length(brks)-2)), key=F, symkey=FALSE,trace='none', 
							cexRow=0.7,cexCol=0.7, main=title,margins = margins, ColSideColors=ColSideColors, RowSideColors=RowSideColors, Rowv=F,dendrogram=dendrogram,lwid = lwid, lhei=lhei, ... )
				}
				else {
					heatmap.2(as.matrix(ma), breaks=brks,col=c("darkgrey",bluered(length(brks)-2)), key=F, symkey=FALSE,
							trace='none', cexRow=0.7,cexCol=0.7, main=title,margins = margins, 
							ColSideColors=ColSideColors, hclustfun = hclustfun, distfun = distfun, Rowv=T,dendrogram=dendrogram,lwid = lwid, lhei=lhei, ...)
				}
			}
			else {
				heatmap.2(as.matrix(ma), breaks=brks,col=c("darkgrey",bluered(length(brks)-2)), Rowv=F,  key=F, symkey=FALSE,
						trace='none', cexRow=0.7,cexCol=0.7, main=title,margins = margins,
						hclustfun = hclustfun, distfun = distfun, dendrogram=dendrogram,lwid = lwid, lhei=lhei )
			}
			dev.off()
		}
		if ( nrow(dataObj$data) > 50 ) {
			png( file=paste(ofile,'_Heatmap.png',sep='') , width=width*150, height=height*250 )
		}
		else {
			png( file=paste(ofile,'_Heatmap.png',sep='') , width=width*150, height=height*200 )
		}
		if ( ! is.na(ColSideColors) ) {
			if ( RowSideColors != F) {
				heatmap.2(as.matrix(ma), breaks=brks,col=c("darkgrey",bluered(length(brks)-2)), key=F, symkey=FALSE,trace='none', 
						cexRow=2,cexCol=0.7, main=title,margins = margins, ColSideColors=ColSideColors, RowSideColors=RowSideColors, Rowv=F,dendrogram=dendrogram,lwid = lwid, lhei=lhei, ... )
			}
			else {
				heatmap.2(as.matrix(ma), breaks=brks,col=c("darkgrey",bluered(length(brks)-2)), key=F, symkey=FALSE,
						trace='none', cexRow=2,cexCol=0.7, main=title,margins = margins, 
						ColSideColors=ColSideColors, hclustfun = hclustfun, distfun = distfun, Rowv=T,dendrogram=dendrogram,lwid = lwid, lhei=lhei, ...)
			}
		}
		else {
			heatmap.2(as.matrix(ma), breaks=brks,col=c("darkgrey",bluered(length(brks)-2)), Rowv=F,  key=F, symkey=FALSE,
					trace='none', cexRow=2,cexCol=0.7, main=title,margins = margins,
					hclustfun = hclustfun, distfun = distfun, dendrogram=dendrogram,lwid = lwid, lhei=lhei )
		}
		dev.off()
		write.table( cbind ( 'GeneSymbol' = rownames(ma), 'groupsID' = hc.row$order[hc.row$order], ma),file= paste(ofile,'_data4Genesis.xls', sep=''),sep='\t' )
		write ( rownames(ma),file= paste(ofile,'_Genes_in_order.txt',sep='') ,ncolumns = 1 )
	}
	else {
		print ( paste( 'You have less than two genes for the histogram (',nrow(ma),', ',ofile,') '))
	}
	hc.row
}



vioplot <-function (x, ..., range = 1.5, h = NULL, ylim = NULL, names = NULL, 
		horizontal = FALSE, col = 'magenta', border = 'black', lty = 1, 
		lwd = 1, rectCol = 'black', colMed = 'white', pchMed = 19, 
		at, add = FALSE, wex = 1, drawRect = TRUE, main=NULL, cex.axis=1, neg=NULL) 
{
	datas <- list(x, ...)
	n <- length(datas)
	if (missing(at)) 
		at <- 1:n
	upper <- vector(mode = 'numeric', length = n)
	lower <- vector(mode = 'numeric', length = n)
	q1 <- vector(mode = 'numeric', length = n)
	q3 <- vector(mode = 'numeric', length = n)
	med <- vector(mode = 'numeric', length = n)
	base <- vector(mode = 'list', length = n)
	height <- vector(mode = 'list', length = n)
	baserange <- c(Inf, -Inf)
	args <- list(display = 'none')
	if (!(is.null(h))) 
		args <- c(args, h = h)
	names.2 <- NULL
	for (i in 1:n) {
		data <- datas[[i]][ is.na(datas[[i]]) ==F ]
		if ( ! is.null(neg)) {
			names.2 <- c ( names.2, paste( length(which( datas[[i]] != neg )),"/",length(data),sep='') )
		}else {
			names.2 <- c ( names.2, paste( length(data),"/",length(datas[[i]]),sep='') )
		}
		if ( length(data) == 0) {
			data <- c(0)
		}
		data.min <- min(data)
		data.max <- max(data)
		
		if ( data.min == data.max ) {
			next;
		}
		q1[i] <- quantile(data, 0.25)
		q3[i] <- quantile(data, 0.75)
		med[i] <- median(data)
		
		iqd <- q3[i] - q1[i]
		upper[i] <- min(q3[i] + range * iqd, data.max)
		lower[i] <- max(q1[i] - range * iqd, data.min)
		est.xlim <- c(min(lower[i], data.min), max(upper[i], 
						data.max))
		smout <- do.call('sm.density', c(list(data, xlim = est.xlim), 
						args))
		hscale <- 0.4/max(smout$estimate) * wex
		base[[i]] <- smout$eval.points
		height[[i]] <- smout$estimate * hscale
		t <- range(base[[i]])
		baserange[1] <- min(baserange[1], t[1])
		baserange[2] <- max(baserange[2], t[2])
	}
	if (!add) {
		xlim <- if (n == 1) 
					at + c(-0.5, 0.5)
				else range(at) + min(diff(at))/2 * c(-1, 1)
		if (is.null(ylim)) {
			ylim <- baserange
		}
	}
	if ( ! is.null(names)) {
		label <- names
	}
	else if (is.null(names.2)) {
		label <- 1:n
	}
	else {
		label <- names.2
	}
	boxwidth <- 0.05 * wex
	if ( length( col ) == 1 ){
		col = rep(col,n)
	}
	if ( length(col ) < n ) {
		stop(paste(length(col),'colors are too view to color',n,'data sets'))
	} 
	if (!add) 
		plot.new()
	if (!horizontal) {
		if (!add) {
			plot.window(xlim = xlim, ylim = ylim)
			axis(2, cex.axis=cex.axis)
			axis(1, at = at, label = label, cex.axis=cex.axis)
		}
		box()
		for (i in 1:n) {
			polygon(c(at[i] - height[[i]], rev(at[i] + height[[i]])), 
					c(base[[i]], rev(base[[i]])), col = col[i], border = border, 
					lty = lty, lwd = lwd)
			if (drawRect) {
				lines(at[c(i, i)], c(lower[i], upper[i]), lwd = lwd, 
						lty = lty)
				rect(at[i] - boxwidth/2, q1[i], at[i] + boxwidth/2, 
						q3[i], col = rectCol)
				points(at[i], med[i], pch = pchMed, col = colMed)
			}
			else{
				lines(at[c(i, i)], c(lower[i], upper[i]), lwd = lwd, 
						lty = lty)
				lines(c(at[i]- boxwidth/2, at[i] + boxwidth/2), c(lower[i], lower[i]), lwd = lwd, 
						lty = lty)
				lines( c(at[i]- boxwidth/2, at[i] + boxwidth/2), c(upper[i], upper[i]), lwd = lwd, 
						lty = lty)
				points(at[i], med[i], pch = pchMed, col = colMed, cex=2)
			}
		}
		
	}
	else {
		if (!add) {
			plot.window(xlim = ylim, ylim = xlim)
			axis(1,cex.axis =cex.axis)
			axis(2, at = at, label = label, cex.axis=cex.axis)
		}
		box()
		for (i in 1:n) {
			polygon(c(base[[i]], rev(base[[i]])), c(at[i] - height[[i]], 
							rev(at[i] + height[[i]])), col = col[i], border = border, 
					lty = lty, lwd = lwd)
			if (drawRect) {
				lines(c(lower[i], upper[i]), at[c(i, i)], lwd = lwd, 
						lty = lty)
				rect(q1[i], at[i] - boxwidth/2, q3[i], at[i] + 
								boxwidth/2, col = rectCol)
				points(med[i], at[i], pch = pchMed, col = colMed)
			}
		}
	}
	if ( ! is.null(main) ){
		title( main, cex.main = 2)
	}
	invisible(list(upper = upper, lower = lower, median = med, 
					q1 = q1, q3 = q3))
}

calc.ann <- function (x, groups ) {
	a <- min(TukeyHSD(aov(formula = as.vector(x) ~ as.factor(groups)))$"as.factor(groups)"[,4] )
	if ( a < 1e-26 ) {
		a = 1e-26
	}
	a
}
get.GOI <- function ( ma, group, exclude = NULL ) {
	d <- apply( ma, 2, calc.ann, groups=group )
	d <- d*ncol(ma) * max(group)
	ret <- d[which(d< 0.05 )]
	ret
}
mds.and.clus <-function(dataObj,clusterby="raw",mds.type="PCA", groups.n, LLEK=2, cmethod='ward.D', ctype='hierarchical clust',onwhat="Expression",... ) {
	if(onwhat=="Expression"){
		tab <- dataObj$z$PCR
	} 
	else {
		print ( paste ( "I work on the FACS data!" ) )
		tab <- dataObj$FACS
	}
	mds.proj <- NULL
	pr <- NULL
	system ( 'rm  loadings.png' )
	if(mds.type == "PCA"){
		pr <- prcomp(tab)
		mds.proj <- pr$x[,1:3]
		png ( file='loadings.png', width=1000, height=1000 )
		plot (  pr$rotation[,1:2] , col='white' );
		text( pr$rotation[,1:2], labels= rownames(pr$rotation), cex=1.5 )
		dev.off()
		write.table( cbind( Genes = rownames(pr$rotation), pr$rotation[,1:2] ), file='gene_loadings.xls' , row.names=F, sep='\t',quote=F )
	#	mds.trans <- prcomp(t(tab))$x[,1:3]
	} else if ( mds.type == "LLE"){
		mds.proj <- LLE( tab, dim = 3, k = as.numeric(LLEK) )
	#	mds.trans <- LLE( t(tab), dim = 3, k = as.numeric(LLEK) )
	}else if ( mds.type == "ISOMAP"){
		mds.proj <- Isomap( tab, dim = 3, k = as.numeric(LLEK) )$dim3
	#	mds.trans <- Isomap( t(tab), dim = 3, k = as.numeric(LLEK) )$dim3
	}
	else {
		print( paste("Sory I can not work on the option",mds.type) )
	}
	
	geneC <- NULL
	if ( exists('geneGroups') ) {
		geneC <- geneGroups$groupID
	}
	dataObj$mds.coord <- mds.proj
	dataObj$geneC <- geneC
	dataObj <- clusters ( dataObj, onwhat=onwhat, clusterby=clusterby, mds.proj =  mds.proj, groups.n = groups.n, ctype = ctype, cmethod=cmethod )
	
	dataObj
}

## cclusters calculates all possible clusters on the dataset
## supported are hclust cclust and tclust with there respective options
clusters <- function(dataObj,clusterby="raw", mds.proj=NULL,groups.n = 3, ctype='hierarchical clust',onwhat="Expression", cmethod='ward.D', tc_restr="eigen", tc_alpha=0.05, tc_nstart=50, tc_iter.max=20, tc_restr.fact=20 ){
		## custering	
	clusters <- NULL
	hc <- NULL
	if(onwhat=="Expression"){
		tab <- dataObj$z$PCR
	} 
	else {
		print ( paste ( "I work on the FACS data!" ) )
		tab <- dataObj$FACS
	}
	if ( exists('userGroups') ) {
		clusters <- userGroups$groupID
	}else if(clusterby=="MDS"){
		if ( ctype=='hierarchical clust'){
			hc <- hclust(dist( mds.proj ),method = cmethod)
			clusters <- cutree(hc,k=groups.n)
		}else if (  ctype=='kmeans' ) {
			hc <- hclust(dist( mds.proj ),method = cmethod)
			clusters <- kmeans( mds.proj ,centers=groups.n)$cluster
		}
	}
	else{#...do mds on tab
		if ( ctype=='hierarchical clust'){
			hc <- hclust(as.dist( 1- cor(t(tab), method='pearson') ),method = cmethod)
			clusters <- cutree(hc,k=groups.n)
		}else if (  ctype=='kmeans' ) {
			hc <- hclust(as.dist( 1- cor(t(tab), method='pearson') ),method = cmethod)
			clusters <- kmeans( mds.proj ,centers=groups.n)$cluster
		}
	}
	if ( ! exists('userGroups') ){
		png ( file='hc_checkup_main_clustering_function.png', width=1600, height=800 )
		plot ( hc);
		dev.off()
	}
	dataObj$clusters <- clusters
	dataObj$hc <- hc
#	dataObj <- reorder_on_correlation ( dataObj )
#	print (cbind ( old= as.vector(dataObj$oldclusters), new=as.vector(dataObj$clusters)))
	dataObj
}

difference <- function ( x, obj ) {
	ret = 0 
	for ( i in 1:groups.n  ) {
		a <- x[which( obj$clusters == i)]
		a <- a[- (is.na(a))==F]
		if ( length(a) > 1 ) {  ret = ret + sum( (a- mean(a) )^2 ) }
	}
	ret
}

quality_of_fit <- function ( obj ) {
	test <- obj$z$PCR
	test[which(test ==  -20 ) ] = NA
	ret <- list ( 'per_expression' = apply(test,2, difference, obj ) )
	ret$Expression = round(sum(ret$per_expression))
	if ( exists('obj$FACS') ) {
		test <- obj$FACS
		ret$per_FACS = apply(test,2, difference, obj ) 
		ret$FACS = round(sum(ret$per_FACS))
	}
	else {
		ret$per_FACS <- NA
		ret$FACS <- NA
	}
	ret
}

col4bean <- function(x, tic='black'){
	ret <- list()
	for ( i in 1:length(x) ){
		ret[[i]] <- c(x[i], tic )
	}
	ret
}


## plot.violines or plot.beans ( ma, groups.n, clus, boot, plot.neg, mv )
## the min value (mv) has to be set to the mv in the data otherwise the factions in the plots will not work
## the plot.neg value determines whether neg values should be included in the plot or not
plot.beans <- function ( ma, groups.n, clus, boot = 1000, plot.neg=TRUE, mv=-20 ) {
	ma <- t(ma)
	n <- rownames(ma)
	cols = col4bean(rainbow( groups.n ))
	for ( i in 1:nrow( ma ) ) {
		print (paste( 'plot.beans working on gene', n[i] ) )
		png( file=paste(n[i],'.png',sep=''), width=800,height=800)
		lila <- vector('list', groups.n)
		lila$names <- NULL
		for( a in 1:groups.n){
			lila[[a]]=ma[i,which(clus == a)]
			lila$names <- c( lila$names, paste(length(which(lila[[a]] != mv)), length(lila[[a]]) ,sep='/' ) )
			if ( ! plot.neg ){
				lila[[a]][which(lila[[a]] == mv)] <- NA
			}
		}
		lila$main <- n[i]
		lila$what <- c(1,1,0,1) ## not plot medain line
		lila$col <- cols
		try(do.call(beanplot,lila), silent=F )
		dev.off()
		if ( plotsvg == 1 ) {
			devSVG( file=paste(n[i],'.svg',sep=''), width=6,height=6)
			lila$cex.axis=0.5
			try(do.call(beanplot,lila), silent=F )
			dev.off()
		}
	}
}


plot.violines <- function ( ma, groups.n, clus, boot = 1000, plot.neg=FALSE, mv=-20) {
	ma <- t(ma)
	n <- rownames(ma)
	cols = rainbow( groups.n )
	for ( i in 1:nrow( ma ) ) {
		print (paste( 'plot.violines working on gene', n[i] ) )
		png( file=paste(n[i],'.png',sep=''), width=800,height=800)
		#create color info
		lila <- vector('list', groups.n)
		lila$names <- NULL
		for( a in 1:groups.n){
			lila[[a]]=ma[i,which(clus == a)]
			lila$names <- c( lila$names, paste(length(which(lila[[a]] != mv)), length(lila[[a]]) ,sep='/' ) )
			if ( ! plot.neg ){
				lila[[a]][which(lila[[a]] == mv)] <- NA
			}
		}
		names(lila)[1]= 'x'
		lila$col= cols
		lila$main=n[i]
		if ( ! plot.neg ) {
			lila$neg = mv
		}else{
			lila$neg = NULL
		}
		
		lila$h = 0.3
		if ( ! is.null(plot.neg) ){
			lila$drawRect = FALSE
		}
		try(do.call(vioplot,lila), silent=F )
		dev.off()
		if ( plotsvg == 1 ) {
			devSVG( file=paste(n[i],'.svg',sep=''), width=6,height=6)
			lila$cex.axis=0.5
			try(do.call(vioplot,lila), silent=F )
			dev.off()
		}
	}
}

analyse.data <- function(obj,onwhat='Expression',groups.n, cmethod, clusterby='MDS', 
		ctype='hierarchical clust', beanplots=TRUE, move.neg = FALSE, plot.neg=TRUE, ...){
	
	if ( exists( 'userGroups' )) {
		userGroups <- checkGrouping(userGroups, obj)
	}
	cols = rainbow( groups.n )
	
	if ( is.null(obj$FACS)) {
		onwhat="Expression"
	} else if ( ncol(obj$FACS)< 4 ) {
		onwhat="Expression"
	}
	obj <- mds.and.clus(obj,onwhat= onwhat,groups.n = groups.n, cmethod, clusterby=clusterby,ctype=ctype, ...)
	
	plotcoma(obj)
	if ( length(which(obj$clusters == 0)) > 0 ){
		obj$clusters <- obj$clusters + 1
	}
	obj$colors <- apply( t(col2rgb( cols ) ), 1, paste,collapse=' ')[obj$clusters]
	
	## plot the mds data
	try(plotDR( obj$mds.coord[order(obj$clusters),], col=cols, labels=obj$clusters[order(obj$clusters)], cex=par3d('cex'=0.01)),silent=F)
	try(writeWebGL( width=470, height=470 ),silent=F)
	png(file='./webGL/MDS_2D.png', width=800,height=800)
	plotDR( obj$mds.coord[order(obj$clusters),1:2], col=cols, labels=obj$clusters[order(obj$clusters)], cex=par3d('cex'=0.01))
	dev.off()
	save( obj, file='clusters.RData')
	write.table (obj$mds.coord[order(obj$clusters),1:2], file = './2D_data.xls' )
	sample.cols.rgb <-t(col2rgb( cols[obj$clusters[order(obj$clusters)]]))
	sample.cols.rgb <- cbind(sample.cols.rgb,  colorname = cols[obj$clusters[order(obj$clusters)]] )
	rownames(sample.cols.rgb) <- rownames(obj$PCR)[order(obj$clusters)]
	write.table ( sample.cols.rgb , file = './2D_data_color.xls' )
	write.table (cbind( names = cols, t(col2rgb( cols))), file='./webGL/MDS_2D.png.cols', sep='\\t',  row.names=F,quote=F )
	
	obj$quality_of_fit = quality_of_fit(obj)
#	browser()
	RowV = TRUE
	RowSideColors = FALSE
	
	if ( exists ('geneGroups') ){
		geneGroups$groupID = as.vector(geneGroups$groupID)
		if ( is.vector(as.vector(geneGroups$groupID)) ) {
			t <- obj
			obj$z$PCR <- obj$z$PCR[, order(geneGroups$groupID)]
			RowV = FALSE
			RowSideColors=c(gray.colors(max(geneGroups$groupID),start = 0.3, end = 0.9))[as.numeric(geneGroups$groupID[order(geneGroups$groupID)])]
		}
	}
	## plot the heatmaps
	
	try( PCR.heatmap ( list( data= t(obj$z$PCR)[,order(obj$clusters)], genes = colnames(obj$z$PCR)), 
					'./PCR_color_groups', 
					title='PCR data', 
					ColSideColors=cols[obj$clusters][order(obj$clusters)],
					RowSideColors=RowSideColors,
					width=12,
					height=6, 
					margins = c(1,11), 
					lwid = c( 1,6), lhei=c(1,5),
					Rowv=RowV,
					Colv=F,
					hclustfun = function(c){hclust( c, method=cmethod)}
			), silent=T)
	
#	try( collapsed_heatmaps (obj, what='PCR', functions = c('median', 'mean', 'var', 'quantile70' )), silent=T)
#	try( collapsed_heatmaps (obj, what='FACS', functions = c('median', 'mean', 'var', 'quantile70' )), silent=T)
	try( PCR.heatmap ( list( data= t(obj$z$PCR), genes = colnames(obj$z$PCR)), 
					'./PCR', 
					title='PCR data', 
					ColSideColors=cols[obj$clusters],
					width=12,
					height=6, 
					margins = c(1,11), 
					lwid = c( 1,6), lhei=c(1,5),
					hclustfun = function(c){hclust( c, method=cmethod)}
			), silent=T)
	try( FACS.heatmap ( list( data= t(obj$FACS), genes = colnames(obj$FACS)), 
					'./facs', 
					title='FACS data', 
					ColSideColors=cols[obj$clusters],
					width=12,
					height=6, 
					hc.col= obj$hc,
					margins = c(1,11), 
					lwid = c( 1,6), lhei=c(1,5),
					hclustfun = function(c){hclust( c, method=cmethod)}
			), silent=T)
	
	try( FACS.heatmap ( list( data= t(obj$FACS)[,order(obj$clusters)], genes = colnames(obj$FACS)), 
					'./facs_color_groups', 
					title='FACS data', 
					ColSideColors=cols[obj$clusters][order(obj$clusters)],
					width=12,
					height=6, 
					hc.col= obj$hc,
					margins = c(1,11), 
					lwid = c( 1,6), lhei=c(1,5),
					Colv=F,
					hclustfun = function(c){hclust( c, method=cmethod)}
			), silent=T)
	
	ma  <- NULL
	mv <- NULL
	if ( zscoredVioplot == 1 ){
		ma <- obj$z$PCR
		mv <- -20
	}else {
		ma <- obj$PCR
		mv <- 0
	}
	
	if ( move.neg ){
		neg <- which(ma == mv )
		m <- min(ma[-neg])
		mv <- m -1
		ma[neg] = mv
	}
	if ( beanplots ) {
		plot.funct <-  plot.beans
	}else{
		plot.funct <-  plot.violines
	}

	## plot the violoines
	if ( ! is.null(obj$FACS)){
		plot.funct( obj$FACS, groups.n, clus =  obj$clusters, boot = 1000, plot.neg=plot.neg, mv=mv )
	}
	print ( paste( 'plot.funct( ma , groups.n, clus =  obj$clusters, boot = 1000, plot.neg =',plot.neg,', mv =', mv))
	plot.funct( ma , groups.n, clus =  obj$clusters, boot = 1000, plot.neg=plot.neg, mv = mv  )

	obj
}





