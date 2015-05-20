
group_1D <- function (dataObj, gene, ranges){
	userGroups <- group_1D_worker ( dataObj$PCR, gene, ranges)
	if ( max(userGroups$groupID) == 0 ){
		userGroups <- group_1D_worker ( dataObj$FACS, gene, ranges)
	}
	userGroups <- checkGrouping ( userGroups, dataObj )
	userGroups
}


group_1D_worker <- function (ma, gene, ranges ) {
	
	position <- which ( colnames(ma) == gene )
	
	userGroups <- data.frame( cellName = rownames(ma), userInput = rep.int(0, nrow(ma)), groupID = rep.int(0, nrow(ma)) )
	
	if ( length(position) > 0 ){
		min <- min(ma[,position])
		max <- max(ma[,position])+1
		
		ranges = ranges[order(ranges)]
		minor = 0
		now <- as.vector( which( ma[,position] >= min & ma[,position] < ranges[1] ))
		userGroups$userInput[now] = paste ('min <= x <',ranges[1] )
		userGroups$groupID[now] = 1
		for ( i in 2:length(ranges) ) {
			now <- as.vector( which( ma[,position] >= ranges[i-1] & ma[,position] < ranges[i] ))
			userGroups$userInput[now] = paste(ranges[i-1],'<= x <',ranges[i])
			if ( length(now) > 0 ){
				userGroups$groupID[now] = i
			}
			else {
				minor = minor + 1
			}
		}
		now <- as.vector( which( ma[,position] >= ranges[length(ranges)] & ma[,position] < max ))
		userGroups$userInput[now] = paste(ranges[length(ranges)],'<= x < max')
		userGroups$groupID[now] = length(ranges) +1
		userGroups <- checkGrouping ( userGroups )
	}
	
	userGroups
}

checkGrouping <- function ( userGroups,  data=NULL ){
	if ( !is.null(data) ){
		if ( length(rownames(data$PCR)) != nrow(userGroups) ) {
			### CRAP - rebuilt the grouping information - the data files have been re-created!
			rn <- rownames(data$PCR)
			for ( i in 1:length(rn) ){
				rownames(userGroups) <- userGroups[,1]
				userGroups2 <- as.matrix(userGroups[ rownames(data$PCR), ])
				missing <- which(is.na(userGroups2[,1]))
				userGroups2[missing,1] <- rn[missing]
				userGroups2[missing,2] <- 'previousely dropped'
				userGroups2[missing,3] <- 0
				userGroups2[, 3] <- as.numeric(as.vector(userGroups2[, 3])) +1
				userGroups2 <- as.data.frame(userGroups2)
				userGroups2[,3] <- as.numeric(userGroups2[,3])
				userGroups <- userGroups2
			} 
		}
	}else {
		userGroups$groupID <- as.vector( as.numeric( userGroups$groupID ))
		if ( length(which(userGroups$groupID == 0)) > 0 ){
			userGroups$groupID = userGroups$groupID + 1
		}
		ta <-table(userGroups$groupID)
		exp <- 1:max(as.numeric(userGroups$groupID))
		miss <- exp[(exp %in% names(ta)) == F]
		for ( i in 1:length(miss) ){
			miss[i] = miss[i] -(i -1)
			userGroups$groupID[which(userGroups$groupID > miss[i] )] = userGroups$groupID[which(userGroups$groupID > miss[i] )] -1 
			
		}
	}
	userGroups
}

regroup <- function ( dataObj, group2sample = list ( '1' = c( 'Sample1', 'Sample2' ) ) ) {
	userGroups <-  data.frame( cellName = rownames(dataObj$PCR), userInput = rep.int(0, nrow(dataObj$PCR)), groupID = rep.int(0, nrow(dataObj$PCR)) )
	n <- names(group2sample)
	n <- n[order( n )]
	minor = 0
	for ( i in 1:length(n) ){
		if ( sum(is.na(match(group2sample[[i]], userGroups$cellName))==F) == 0 ){
			minor = minor +1
		}
		else {
			userGroups[ match(group2sample[[i]], userGroups$cellName),3] = i - minor
		}
	}
	if ( length(which(userGroups[,3] == 0)) > 0 ){
		userGroups[,3]
		system (paste('echo "', length(which(userGroups[,3] == 0)),"cells were not grouped using the updated grouping' > Grouping_R_Error.txt", collaps=" ") )
	}
	checkGrouping ( userGroups, dataObj )
}


group_on_strings <- function (dataObj, strings = c() ) {
	userGroups <-  data.frame( cellName = rownames(dataObj$PCR), userInput = rep.int(0, nrow(dataObj$PCR)), groupID = rep.int(0, nrow(dataObj$PCR)) )
	minor = 0	
	for ( i in 1:length(strings) ) {
		g <- grep(strings[i], userGroups$cellName)
		if ( length(g) == 0 ){
			system (paste ('echo "The group name',strings[i] ,'did not match to any sample" > Grouping_R_Error.txt', collaps=" ") )
			minor = minor +1
		}
		else {
			userGroups[g ,3] = i - minor
			userGroups[g ,2] = strings[i]
		}
	}
	checkGrouping ( userGroups, dataObj )
}


createGroups_randomForest <- function (dataObj, fname='RandomForest_groupings.txt' ) {
	## load('RandomForestdistRFobject.RData') <- this has to be done before calling this function!!
	persistingCells <- rownames( dataObj$PCR )
	if ( exists('distRF') ) {
		expected_groupings <- unique(scan ( fname ))
		for ( i in 1:length(expected_groupings) ) {
			res = pamNew(distRF$cl1, expected_groupings[i] )
			N <- names( res )
			## probably some cells have been kicked in the meantime - I need to kick them too
			N <- intersect( persistingCells, N )
			userGroups <- matrix(ncol=3, nrow=0)
			for ( a in 1:length(N) ){
				userGroups <- rbind (userGroups, c( N[a], 'no info', as.numeric(res[[N[a]]]) ) )
			}
			colnames(userGroups) <- c('cellName', 'userInput',  'groupID' )
			## write this information into a file that can be used as group
			userGroups = data.frame( userGroups)
			save ( userGroups , file= paste("forest_group_n", expected_groupings[i],'.RData', sep=''))
			
			fileConn<-file(paste("Grouping.randomForest.n",expected_groupings[i],".txt", sep="") )
			writeLines(c(paste("load('forest_group_n",expected_groupings[i],".RData')",sep=""),
							"userGroups <- checkGrouping ( userGroups[is.na(match(userGroups$cellName, rownames(data.filtered$PCR) ))==F, ], data.filtered )" 
						), fileConn)
			close(fileConn)
		}
	}
}

createGeneGroups_randomForest <- function (dataObj, expected_grouping=10 ) {
	## load('RandomForestdistRFobject_genes.RData') <- this has to be done before calling this function!!
	persistingGenes <- colnames( dataObj$PCR )
	if ( round(length(persistingGenes)/4) < expected_grouping ){
		expected_grouping <- round(length(persistingGenes)/4)
	}
	if (expected_grouping < 2 ){
		expected_grouping <- 2
	}
	if ( exists('distRF') ) {
			res = pamNew(distRF$cl1, expected_grouping )
			N <- names( res )
			## probably some cells have been kicked in the meantime - I need to kick them too
			N <- intersect( persistingGenes , N )
			geneGroups <- matrix(ncol=3, nrow=0)
			for ( a in 1:length(N) ){
				geneGroups <- rbind (geneGroups, c( N[a], 'no info', as.numeric(res[[N[a]]]) ) )
			}
			colnames(geneGroups) <- c('geneName', 'userInput',  'groupID' )
			## write this information into a file that can be used as group
			geneGroups = data.frame( geneGroups)
			save ( geneGroups , file= paste("forest_gene_group_n", expected_grouping,'.RData', sep=''))
			
			fileConn<-file(paste("Gene_grouping.randomForest.txt", sep="") )
			writeLines(c(paste("load('forest_gene_group_n",expected_grouping,".RData')",sep=""),
							"geneGroups <- checkGrouping ( geneGroups[is.na(match(geneGroups$geneName, colnames(data.filtered$PCR) ))==F, ] )",
							"write.table( geneGroups[order(geneGroups[,3]),], file='GeneClusters.xls' , row.names=F, sep='\t',quote=F )"
					), fileConn)
			close(fileConn)
		
	}
}

