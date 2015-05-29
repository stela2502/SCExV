library('MAST') 
library(abind)
library(reshape)
library(ggplot2)
library(boot)

SingleCellAssay_Pvalues <- function ( obj, ofile="Significant_genes.csv" ) {
	d <- obj$z$PCR
	d[which(d==-20)] <- NA
	x <- as.matrix(d)
	d[is.na(d)] <- 0
	sca <- FromMatrix('SingleCellAssay', as.matrix(d), data.frame(wellKey=rownames(d)), data.frame(primerid=colnames(d)) )
	groups <- cData(sca)$GroupName <- obj$clusters
	zlm.output <- zlm.SingleCellAssay(~ GroupName, sca, method='glm', ebayes=T)
	zlm.lr <- lrTest(zlm.output,'GroupName')
	pvalue <- ggplot(melt(zlm.lr[,,'Pr(>Chisq)']), aes(x=primerid, y=-log10(value)))+ geom_bar(stat='identity')+facet_wrap(~test.type) + coord_flip()
	png ('Analysis1.png', width=800, height=800)
	print(pvalue)
	dev.off()
	write.table( zlm.lr[,,'Pr(>Chisq)'], file=ofile, sep='\t')
	zlm.lr[,,'Pr(>Chisq)']
}

calc.lin.lang.4_list <- function ( l =list() ) {
	n = length(l)
	or <- NULL
	medians <- NULL
	groupIDs<- NULL
	weight <- NULL
	for (i in 1:n) {
		data <- l[[i]][ is.na(l[[i]]) ==F ]
		if ( length(data) == 0) {
			data <- c(0)
		}
		data.min <- min(data)
		data.max <- max(data)
		if ( data.min != data.max ) {
			or <- c( or, length(data) / length(l[[i]] ))
			weight <- c( weight,  length(l[[i]] ) )
			medians <- c( medians,  median(data) )
			groupIDs <- c( groupIDs, i )
		}
	}
	ret <- list (  'weight' = weight, medians = medians, groupIDs = groupIDs, or = or , cor = NULL)
	if( length(weight) > 2 ){
		ret$cor <- corr( cbind(or, medians), w = weight / sum(weight) )
	}
	
	ret
}


p.lin.lang <- function ( x, groups.n, clus, n=1000 ) {
	x[which( x == -20)] <- NA
	real_list <- vector ( 'list', groups.n)
	random_length <- vector ( 'numeric', groups.n)
	for( a in 1:groups.n){
		real_list[[a]]=x[which(clus == a)]
		random_length[a] = length(real_list[[a]])
		#real_list[[a]] = real_list[[a]][is.na(real_list[[a]]) == F]
	}
	## get one obj with all data
	stat_real = calc.lin.lang.4_list ( real_list )
	p_value = 1
	#print (stat_real$cor)
	if ( is.null(stat_real$cor) ) {
		stat_real$cor = 0.001
	}
	if ( is.na(stat_real$cor) ) {
		stat_real$cor = 0.001
	}
	if ( length(stat_real$cor) == 0){
		stop ( "Some crap happened!" )
	}
	
	if ( length(stat_real$weight) > 2 &&  stat_real$cor > 0.001 ){
		## bootstrap
		cmp = vector( 'numeric', n )
		medians <- vector ( 'numeric', groups.n)
		or <- vector ( 'numeric', groups.n)
		expo = 2
		for ( i in 1:n ) {
			for( gid in stat_real$groupIDs){
				tmp =sample(x,random_length[gid])
				tmp = tmp[is.na(tmp) ==F]
				or[gid] = length(tmp) / random_length[gid]
				if ( length(tmp) == 0 ){
					medians[gid] = 0
				}
				else if ( length(tmp) == 1 ){
					medians[gid] = tmp[1]
				}else {
					medians[gid] = median(tmp)
				}
			}
			cmp[i] = corr( cbind(or[stat_real$groupIDs], medians[stat_real$groupIDs]), w = stat_real$weight / sum(stat_real$weight) )
			if ( i %% 10^expo == 0 ){
			#	expo = expo + 1
				t <- boot_p_value ( cmp, stat_real$cor, i )
				#print (paste( "I check whether the p value (",t,") is already saturated",i))
				if ( t > 20/i ) {
					
					break
				}
			}
			if (is.na(cmp[i]) ){
				cmp[i]=1/n
			}
		} 
		#hist( cmp )
		#abline(v=stat_real$cor, col='red')
		stat_real$bootstrapedcor = cmp
		p_value <- boot_p_value ( cmp, stat_real$cor, sum( cmp != 0 ) )
		#print ( paste('Final p value = ',p_value, 'Using stat real cor =',stat_real$cor,"and n =",sum( cmp != 0 ),"values"))
	}
	else {
		p_value = 1 
	}
	stat_real$p_value = p_value
	stat_real
}

boot_p_value <- function (cmp, real_val, i ) {
	a <- length(which(cmp > real_val))
	if ( a == 0 ) { a<-1}
	p_value = a / i
	p_value
}

create_p_values <- function ( obj, boot = 1000, lin_lang_file='lin_lang_stats.xls', sca_ofile="Significant_genes.csv" ) {
	stat_res = try ( SingleCellAssay_Pvalues ( obj, sca_ofile ))
	if ( exists('obj$FACS') ){
		ma <- cbind( obj$z$PCR,  obj$z$FACS) 
	}else {
		ma <- obj$z$PCR
	}
	
	groups.n = max(as.vector(obj$clusters))
	ma <- t(ma)
	n <- rownames(ma)
	cols = rainbow( groups.n )
	ma[which( ma == -20)] <- NA
	obj$stats <- vector('list', length=nrow( ma ))
	names(obj$stats) = rownames(ma)
	for ( i in 1:nrow( ma ) ) {
		obj$stats[[i]] = p.lin.lang ( ma[i,], groups.n, obj$clusters, n=boot )
	}
	obj$lin_lang <- write.stats( obj$stats, file=lin_lang_file )
	write.table( cbind( stat_res, 'linear_model' = unlist( lapply( obj$stats, function(x) { x$p_value } ))) , file='Summary_Stat_Outfile.xls' ,  sep='\t',quote=F )
	obj
}

write.stats <- function ( stats = NULL, file='lin_lang_stats.xls' ){
	
	groupL <- function(x) {
		if ( ! is.vector(x$medians)){ x$medians = c(-1,-2) }
		if ( ! is.vector(x$groupIDs)){ x$groupIDs = c(-1,-2) }
		if ( ! is.vector(x$weight)){ x$weight = c(-1,-2) }
		c( x$cor, x$p_value, 
				paste(x$groupIDs[order(x$medians)], collapse =', '), 
				paste(x$medians[order(x$medians)], collapse =', '), 
				paste(x$weight[order(x$medians)], collapse =', ') 
		) }
	ma <- NULL
	if ( ! is.null(stats) ) {
		ma <- t(as.data.frame(lapply(stats, groupL )))
		rownames(ma) <- names(stats)
		colnames(ma)<- c('Correlation', 'p value', 'groups in order', 'median expression in group', 'weight of group' )
		write.table( ma, file=file ,  sep='\t',quote=F ) 
	}
	else {
		print ( "No starts to print!" )
	}
	ma
}