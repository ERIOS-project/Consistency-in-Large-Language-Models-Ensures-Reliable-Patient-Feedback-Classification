# This code create the three dimensional array to describe the human classifications from the multiple xlsx tables filled by each agent.

# Define the correspondance between the files
epl_folder  = "data/humans/01_Classification_epl/"
sg_folder   = "data/humans/01_Classification_sg/"
xd_folder = "data/humans/01_Classification_xd/"

# Store the possible humans agents
agent = c("EPL","SG","XD")

#The data frame files_correspondance represent the correspondance between the files of the different classifications.
files_correspondance = data.frame(
  EPL  = vector(),
  SG   = vector(),
  XD = vector()
)

# Feed files_correspondance with the 100 verbatims from e-satis

for(i in 0:99){
  new_file = c(
    paste(epl_folder,i,"_output_tas_EPL.xlsx", sep=""),
    paste(sg_folder,i,"_output_tas_SG.xlsx", sep=""),
    paste(xd_folder,i,"_output_tas_XD.xlsx", sep="")
  )
  files_correspondance[nrow(files_correspondance)+1,] = new_file
}

# Create the matrix_GS that gather the classification of the 3 experts :
# store the verbatims indices :
index = 1:100


# Create the array squeleton
matrix_humans = array(data=NA, dim=c(
  length(index),
  length(category),
  length(tone),
  length(agent)
), 
dimnames = list(index,category,tone,agent))

# Feed the array for each verbatim
library(xlsx)


for(i in 1:length(index)){ # iterates through verbatims
  for(current_agent in agent){ # iterates through agents
    file_path = files_correspondance[
      i,which(colnames(files_correspondance)==current_agent)]
    
    #read the xlsx file corresponding to the current_agent and the verbatim i
    input = read.xlsx(file = file_path, sheetIndex = 2)
    current_tones = trimws(input[,5])
    
    #Humans select information only if they identify a category/tone
    # tone == "positive"
    current_positives = trimws(input[which(
      current_tones=="Positif" |
        current_tones=="positif"
    ),3])
    if(length(current_positives>0)) matrix_humans[i,which(category %in% current_positives),tone=="positive",agent=current_agent] = 1
    # tone == "negative"
    current_negatives = trimws(input[which(
      current_tones=="Négatif" |
        current_tones=="négatif" |
        current_tones=="Negatif" |
        current_tones=="negatif" 
    ),3])
    if(length(current_negatives>0)) matrix_humans[i,which(category %in% current_negatives),tone=="negative",agent=current_agent] = 1
  }
}
# Replace the NA with zeros
matrix_humans[is.na(matrix_humans)]=0

saveRDS(matrix_humans, "data/humans/matrix_humans.rds")
