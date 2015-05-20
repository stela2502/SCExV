source ('Tool_Pipe.R')

#read.PCR("GK_HSC2.txt")


fset <- c("/home/slang/BMC_Projects/FLUIDIGM_WEB_Tool/Shamit/GK_HSC1.txt","/home/slang/BMC_Projects/FLUIDIGM_WEB_Tool/Shamit/GK_HSC2.txt")
FACSset <- NULL

data.filtered <- createDataObj ( PCR=fset, FACS=FACSset, ref.genes= c("ref1","ref2") )

save( data.filtered, file="norm_data.RData" )

