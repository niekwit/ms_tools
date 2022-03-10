#checks if required packages are installed (ONLY REQUIRED FOR FIRST RUN)
packages <- rownames(installed.packages())
cran.packages <- c("readxl", "xlsx")
cran.packages2install <- cran.packages[! cran.packages %in% packages]
if(length(cran.packages2install) > 0){
  for (x in cran.packages2install){install.packages(x)} 
}

#loads required package
library("readxl")
library("xlsx")

#gets directory of script
work.dir <- dirname(rstudioapi::getSourceEditorContext()$path)

#loads Excel file with data (make sure there is only one .xls file in the directory)
file.name <- Sys.glob(file.path(work.dir,"*xls*"))
if (length(file.name) == 0){
  file.name <- Sys.glob(file.path(work.dir,"*XLS*"))
}

#get names for all sheets in Excel file
sheets <- excel_sheets(file.name)
sheets <- sheets[! sheets %in% c("Component", "mdlCalcs")]

#check if results sheet is already present
if ("Results" %in% sheets){
  print("Results sheet already present in data file")
} else {
  #create list to store sheets as data frames
  df.list <- vector(mode = "list", length = length(sheets))
  
  #get number of samples
  df <- read_excel(file.name, sheet = sheets[1], skip = 4)
  df <- df[!grepl("blank", df$`Sample ID`, ignore.case = TRUE), ]
  df <- df[complete.cases(df$`Sample ID`), ]
  nrows <- nrow(df)
  
  #create output data frame
  df.out <- data.frame(matrix(ncol = length(sheets), nrow = nrows))
  names(df.out) <- sheets
  
  #read all data and store to data frame
  for (i in 1:length(sheets)){
    #read sheet
    df <- read_excel(file.name, sheet = sheets[i], skip = 4)
    #select only sample sheets
    df <- df[!grepl("blank", df$`Sample ID`, ignore.case = TRUE), ]
    #remove rows with NA in Sample ID
    df <- df[complete.cases(df$`Sample ID`), ]
    df.out[i] <- df$Area
  }
  
  #add sample id column
  df.out <-cbind(`Sample ID` = df$`Sample ID`, df.out)
  
  #append results data to original file
  write.xlsx(df.out, file.name, sheetName = "Results", append = TRUE, row.names = FALSE)
  
}




