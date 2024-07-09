# This code takes in entry llm txt output, clean them and store the Llama3 +/-CA in R object matrices


# -------------------------------------------------------------------------------------------------------------
# Step 1 : clean Llama3 output
# -------------------------------------------------------------------------------------------------------------

# The next parts need that a layer of themes are indicated. However, the name and repartition of the themes are irrelevant.
# Thus we store all categories in a single theme named "All_themes".
current_theme = "All_themes"
new_json = list()
for(current_category in category){
  # Create a new list with the wanted categories
  assign(current_category, list(
    `positive`= "",
    `negative`= "",
    `neutral`= "",
    `not mentioned`= ""
  ))
  # Append the new category to the main new_json
  new_json[[current_theme]][[current_category]] <- get(current_category)
}

llm_uncleaned_folder_1 = "data/Llama3/llm_output_1/prompt_2/"
llm_uncleaned_folder_2 = "data/Llama3/llm_output_2/prompt_2/"
clean_folder_1 = "data/Llama3/Llama3_clean_output_1/"
clean_folder_2 = "data/Llama3/Llama3_clean_output_2/"

for(folder in 1:2){
  
  if (folder ==1) uncleaned_folder = llm_uncleaned_folder_1
  if (folder ==2) uncleaned_folder = llm_uncleaned_folder_2
  
  # Iterates for each verbatim
  for(i in index){
    
    current_json = new_json
    
    suppressWarnings({
      input = paste(trimws(readLines(paste(uncleaned_folder,i,"_output.txt", sep=""))))#,collapse=" ")
    })
    current_category = ""
    
    # Read the input row by row
    for (row in 1:length(input)){
      
      #Check if a category is mentionned
      for(category_check in category){
        if(grepl(category_check, input[row])) current_category = category_check
      }
      
      # If there is a positive tone mentionned :
      if(grepl("positive", input[row])
      ){
        current_json[[current_theme]][[current_category]]$`positive` = substr(input[row],nchar('"positive": "')+1,nchar(input[row])-2)
      }
      # If there is a negative tone mentionned :
      if(grepl("negative", input[row])
      ){
        current_json[[current_theme]][[current_category]]$`negative` = substr(input[row],nchar('"negative": "')+1,nchar(input[row])-2)
      }
      # If there is a Incertain tone mentionned :
      if(grepl("neutral", input[row])
      ){
        current_json[[current_theme]][[current_category]]$`neutral` = substr(input[row],nchar('"neutral": "')+1,nchar(input[row])-2)
      }
      # If there is a not mentioned tone mentionned :
      if(grepl("not mentioned", input[row])
      ){
        current_json[[current_theme]][[current_category]]$`not mentioned` = substr(input[row],nchar('"not mentioned": "')+1,nchar(input[row])-1)
      }
    }
    # Save the json in the new folder
    if (folder ==1) json_path = paste(clean_folder_1,i,"_output.json", sep="")
    if (folder ==2) json_path = paste(clean_folder_2,i,"_output.json", sep="")
    jsonlite::write_json(current_json, json_path, pretty = T)
  } 
}

# -------------------------------------------------------------------------------------------------------------
#step 2 : gather the confidence scores
# -------------------------------------------------------------------------------------------------------------

# Store the possible agents
agent = c("LLM1","LLM2")

# Create the file_correspondance
file_correspondance = data.frame(
  index = index,
  LLM1 = paste(clean_folder_1,index,"_output.json",sep=""),
  LLM2 = paste(clean_folder_2,index,"_output.json",sep="")
)

# Create the array squeleton for the classification
matrix_class = array(data=NA, dim=c(
  length(index),
  length(category),
  length(tone),
  length(agent)
), 
dimnames = list(index,category,tone,agent))

# Create the array squeleton for the justification
matrix_justif = array(data=NA, dim=c(
  length(index),
  length(category),
  length(tone),
  length(agent)
), 
dimnames = list(index,category,tone,agent))


for(i in 1:length(index)){
  
  # Gather the LLM classification :
  for(current_agent in agent){
    suppressWarnings({
      input = paste(trimws(readLines(file_correspondance[[current_agent]][i])),collapse=" ")
    })
    input = jsonlite::fromJSON(input)
    
    # erase the themes, keep the categories
    input_2 = list() # json data, but without themes
    themes = ls(input)
    for(current_theme in themes){
      input_2 = append(input_2, input[[current_theme]])
    }
    names(input_2) = trimws(names(input_2)) # Avoid white spaces added by LLM
    
    
    
    # Feed the matrix_class and matrix_justif
    for( current_category in category){
      for(current_tone in tone){
        if(current_tone=="positive" & 
           input_2[[current_category]][[1]]!=""){ 
          # [[1]] corresponds to the positive. Avoid typos added by LLM
          matrix_class[i,which(category %in% current_category),tone=="positive",
                       agent=current_agent] = 1
          matrix_justif[i,which(category %in% current_category),tone=="positive",
                        agent=current_agent] = input_2[[current_category]][[1]]
        }
        if(current_tone=="negative" & 
           input_2[[current_category]][[2]]!=""){
          # [[2]] corresponds to the negative row. Avoid typos added by LLM
          matrix_class[i,which(category %in% current_category),tone=="negative",
                       agent=current_agent] = 1
          matrix_justif[i,which(category %in% current_category),tone=="negative",
                        agent=current_agent] = input_2[[current_category]][[2]]
        }
      }
    }
  }
}
# Replace the NA with zeros in matrix_class
matrix_class[is.na(matrix_class)]=0
# Replace the NA with "" in matrix_justif
matrix_justif[is.na(matrix_justif)]=""


matrix_cross_selection = (matrix_class[,,,"LLM1"] + matrix_class[,,,"LLM2"])/2
matrix_1 = matrix_class[,,,"LLM1"]
saveRDS(matrix_1,"data/Llama3/matrixLlama3_wo_postprod.rds" )


# The justification follows the given syntax :
# " element | citation "
# The confidence in the classification is scored according to the following facts about the justification :
# - classification 1 is positive +12
# - classification 2 is positive +12
# - syntax 1 is correct +4
# - syntax 2 is correct +4
# - the two elements are in accordance +2
# - the two citations are in accordance +1

# The score goes from 0 to 35. 
# There is bijection between score and situation (considering classification 1 and 2 are equivalent).

# As typos may be corrected between the verbatim and the citation, the presence of the citation is not considered in the evaluation of the syntax.

scores = c("class1",
           "class2",
           "syntax1",
           "syntax2",
           "element_accordance",
           "citation_accordance",
           "score_total"
)

#create confidence score matrix 
matrix_confidence = array(data=0, dim=c(
  length(index),
  length(category),
  length(tone),
  length(scores)
), 
dimnames = list(index,category,tone,scores))


# We need to read the classification rules in order to clean unjustified classifications
suppressWarnings({
  input = paste(trimws(
    readLines("../Appendix 1 operationnal scope of categories.json")),collapse=" ")
})
input = jsonlite::fromJSON(input)
# Erase the themes, keep the categories
classification_rules = list() # json data, but without themes
themes = ls(input)
for(current_theme in themes){
  classification_rules = append(classification_rules, input[[current_theme]])
}
names(classification_rules) = trimws(names(classification_rules)) 
# convert into a list of strings of elements
for(current_category in ls(classification_rules)){
  elements = vector()
  for(current_element in ls(classification_rules[[current_category]])){
    elements = append(elements, classification_rules[[current_category]][[current_element]])
  }
  classification_rules[[current_category]] = trimws(elements)
}

# Feed the confidence matrix :
for(i in 1:length(index)){
  for(current_category in category){
    for(current_tone in tone){
      
      current_justification1 = matrix_justif[i,category==current_category,tone==current_tone,agent=="LLM1"]
      current_justification2 = matrix_justif[i,category==current_category,tone==current_tone,agent=="LLM2"]
      
      # sep_char_position "|"
      sep_char_position1 = gregexpr("\\|",current_justification1)[[1]][1] 
      sep_char_position2 = gregexpr("\\|",current_justification2)[[1]][1]
      
      # element
      element1 = trimws(substr(current_justification1,
                               1,sep_char_position1-1))
      element2 = trimws(substr(current_justification2,
                               1,sep_char_position2-1))
      
      # citation
      citation1 = trimws(substr(current_justification1,
                                sep_char_position1+1,nchar(current_justification1)))
      citation2 = trimws(substr(current_justification2,
                                sep_char_position2+1,nchar(current_justification2)))
      
      
      # score : class1
      if(matrix_class[i,category==current_category,tone==current_tone,agent=="LLM1"]==1){
        matrix_confidence[i,category==current_category,tone==current_tone,scores=="class1"] = 1
      }
      # score : class2
      if(matrix_class[i,category==current_category,tone==current_tone,agent=="LLM2"]==1){
        matrix_confidence[i,category==current_category,tone==current_tone,scores=="class2"] = 1
      }
      # score : syntax1
      if(element1 %in% classification_rules[[current_category]] &
         nchar(citation1)>0 ){
        matrix_confidence[i,category==current_category,tone==current_tone,scores=="syntax1"] = 1
      }
      # score : syntax2
      if(element2 %in% classification_rules[[current_category]] &
         nchar(citation2)>0 ){
        matrix_confidence[i,category==current_category,tone==current_tone,scores=="syntax2"] = 1
      }
      # score : element_accordance
      if(nchar(element1)>0 & nchar(element2)>0 & element1==element2){
        matrix_confidence[i,category==current_category,tone==current_tone,scores=="element_accordance"] = 1
      }
      # score : citation_accordance 
      if(nchar(citation1)>0 & nchar(citation2)>0 & (grepl(citation1,citation2, fixed = T) | grepl(citation2,citation1, fixed = T)) ){
        matrix_confidence[i,category==current_category,tone==current_tone,scores=="citation_accordance"] = 1
      }
      matrix_confidence[i,category==current_category,tone==current_tone,scores=="score_total"] =
        12 * matrix_confidence[i,category==current_category,tone==current_tone,scores=="class1"] +
        12 * matrix_confidence[i,category==current_category,tone==current_tone,scores=="class2"] +
        4 * matrix_confidence[i,category==current_category,tone==current_tone,scores=="syntax1"] +
        4 * matrix_confidence[i,category==current_category,tone==current_tone,scores=="syntax2"] +
        2 * matrix_confidence[i,category==current_category,tone==current_tone,scores=="element_accordance"] +
        1 * matrix_confidence[i,category==current_category,tone==current_tone,scores=="citation_accordance"] 
      
    }
  }
}
matrix_confidence = matrix_confidence[,,,scores=="score_total"]
matrix_confidence = matrix_confidence/35


saveRDS(matrix_confidence,"data/Llama3/matrix_Llama3.rds")
