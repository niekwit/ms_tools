###ASSUMPTIONS:
#data is in triplicate
#first sample is reference sample

###First make sure cell counts are entered at the bottom of the Data(corrected).csv file (first column: cell_counts)###

#script directory
script.dir <- "/home/niek/Documents/scripts/ms_tools"

#set data directory
work.dir <- "/home/niek/Desktop/2022_T-cells/AIAEXPRT.AIA"
setwd(work.dir)

#prepare data for read into R
system(paste("bash",file.path(script.dir,"prepare4metran.sh"),work.dir))

#
setwd(work.dir)

#isotopomers to use as internal control for each fragment

control.list <- list("Pyr_"="M3",
                     "Lac_"="M3",
                     "Cit_"="M6",
                     "Akg_"="M5",
                     "2HG_"="M5",
                     "Suc_"="M4",
                     "Fum_"="M4",
                     "Mal_"="M4",
                     "Ser_"="M3",
                     "Gly_"="M2",
                     "Cys_"="M3",
                     "Glu_"="M5",
                     "Gln_"="M4",
                     "Asp_"="M4",
                     "Ala_"="M3")

#read corrected data
df <- read.csv("data_corrected_4processing.csv", header = TRUE)

#remove any 293T data columns if present
if (ncol(df[-grep("293[tT]",colnames(df))]) > 0){
  df <- df[-grep("293[tT]",colnames(df))] #removes all columns with 293T controls
}

#remove theory column
df$Theory <- NULL

#check if data is in triplicate
if ((ncol(df)-1)%%3 !=0){
  print("ERROR: data not in triplicate")
} else{
  #do calculations if cell counts are entered
  if (nrow(df[grep("cell_counts",df$Ion), ]) == 1){
    #perform calculations for each fragment
    for (i in names(control.list)){
      #subset for fragment
      df.temp <- df[grepl(i, df$Ion),]
      rownames(df.temp) <- NULL
      
      #get internal control m/z
      control_ion <- control.list[[i]]
      
      #correct data for internal control
      df.corrected <- df.temp[grepl("M0", df.temp$Ion), ]
      df.corrected[2,] <- df.temp[grepl(control_ion, df.temp$Ion), ]
      df.corrected[3, 1] <- paste0("M0/",control_ion)
      df.corrected[3, 2:ncol(df.corrected)] <- df.corrected[1, 2:ncol(df.corrected)] / df.corrected[2, 2:ncol(df.corrected)]
      rownames(df.corrected) <- NULL
      
      #add cell counts
      df.corrected[4,] <- df[nrow(df),]
      rownames(df.corrected) <- NULL
      
      #correct for cell counts
      df.corrected[5,1] <- "corrected_for_cell_counts"
      df.corrected[5,2:ncol(df.corrected)] <- df.corrected[3,2:ncol(df.corrected)] / df.corrected[4,2:ncol(df.corrected)]
      
      #calculate mean of triplicates
      total.sample.number <- ncol(df.corrected) - 1
      sample.number <- total.sample.number / 3
      range.list <- vector("list",length=sample.number)
      for (j in 1:sample.number){ #determine column numbers to be grouped
        range.list[[j]] <- seq(((j*3)-1),((j*3)+1),1)
      }
      df.corrected[6,1] <- "mean_triplicates"
      for (r in range.list){
        df.corrected[6, r] <- mean(unlist(df.corrected[5, r]))
      }
      
      #sample relative to control
      df.corrected[7,1] <- "Relative_to_control"
      for (r in range.list){
        df.corrected[7, r] <- df.corrected[6, r] / df.corrected[6, range.list[[1]]]
      }
      
      #add spacer
      df.corrected[8,] <- NA
      
      #create data frame to write calculations to
      if (exists("df.out") == FALSE){
        df.out <- df.corrected
      } else{
        df.out <- rbind(df.out, df.corrected)
      }
      
    }
    
    #write to file
    write.csv(df.out, 
              file="data_corrected_analysed.csv", 
              quote=FALSE,
              na = ",",
              row.names=FALSE)
  } else {
    print("ERROR: multiple or no 'cell_count' rows found.")
  }
}




