##read the existing randomForest dataset or die!
source ('libs/Tool_RandomForest.R')
source ('libs/Tool_grouping.R')
load('RandomForestdistRFobject.RData')
load('norm_data.RData')
createGroups_randomForest( data.filtered, fname='RandomForest_groupings.txt')
load('RandomForestdistRFobject_genes.RData')
createGeneGroups_randomForest (  data.filtered, 10 )
release_lock (lock.name)
