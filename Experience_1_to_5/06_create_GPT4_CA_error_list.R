# This code list the errors of GPT4 and GPT4+ECA, ICA and GCA to evaluate each as an hallucination or not. As the three GPT4 errors are necessarly  


# import data
matrix_GS = readRDS("data/gold_standard/matrix_GS.rds")
matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4_CA.rds")
matrix_GPT4_standalone = readRDS("data/GPT4/matrix_GPT4_standalone.rds")



#---------------------------------- GPT4 standalone ---------------------------

# Store the possible agents
agent = c("1","2","3")

errors = data.frame(id=logical(),
                         category=logical(),
                         tone=logical(),
                         justification = logical())

llm_uncleaned_folders = paste("data/GPT4/gpt4-lot",agent,"/llm_output_1/prompt_1/",sep="")

for(current_agent in 1:length(agent)){
  for(i in index){
    suppressWarnings({
      input = paste(trimws(readLines(paste(llm_uncleaned_folders[current_agent],i,"_output.txt", sep=""))))
    })
    current_category = ""
    
    # Read the input row by row
    for (row in 1:length(input)){
      
      #Check if a category is mentionned
      for(category_check in category){
        if(grepl(category_check, input[row])) current_category = category_check
      }
      if(current_category=="") next
      
      # If there is a positive tone mentionned :
      if(grepl("positive", input[row])) if(matrix_GS[i,current_category,"positive"]==0 & matrix_GPT4_standalone[i,current_category,"positive", current_agent]==1 )
      {
        errors = rbind(errors,c(i, current_category,"+",substr(input[row],nchar('"positive": "')+1,nchar(input[row])-2) ))
      }
      # If there is a negative tone mentionned :
      if(grepl("negative", input[row]))if(matrix_GS[i,current_category,"negative"]==0 & matrix_GPT4_standalone[i,current_category,"negative", current_agent]==1 )
      {
        errors = rbind(errors,c(i, current_category,"-",substr(input[row],nchar('"negative": "')+1,nchar(input[row])-2)))
      }
    }
  }
}
colnames(errors) = c("id","category","tone","justification")

library(xlsx)
write.xlsx(errors,"data/GPT4/GPT4_standalone_errors.xlsx", row.names=F)

#---------------------------------- GPT4 + PIC generation ---------------------------
# As GPT4+ECA, GPT4+ICA and GPT4+GCA use the same generated output, it is only needed to evaluate it once.

# Store the possible agents
agent = c("1","2","3","1","2","3")

errors = data.frame(id=logical(),
                         category=logical(),
                         tone=logical(),
                         justification = logical())

llm_uncleaned_folders = c(paste("data/GPT4/gpt4-lot",agent,"/llm_output_1/prompt_2/",sep=""),paste("data/GPT4/gpt4-lot",agent,"/llm_output_2/prompt_2/",sep=""))

for(current_agent in 1:length(agent)){
  for(i in index){
    suppressWarnings({
      input = paste(trimws(readLines(paste(llm_uncleaned_folders[current_agent],i,"_output.txt", sep=""))))
    })
    current_category = ""
    
    # Read the input row by row
    for (row in 1:length(input)){
      
      #Check if a category is mentionned
      for(category_check in category){
        if(grepl(category_check, input[row])) current_category = category_check
      }
      if(current_category=="") next
      
      # If there is a positive tone mentionned :
      if(grepl("positive", input[row])) if(matrix_GS[i,current_category,"positive"]==0 & matrix_GPT4_CA[i,current_category,"positive", round(current_agent/2+0.01)]>=(12/35) )
      {
        errors = rbind(errors,c(i, current_category,"+",substr(input[row],nchar('"positive": "')+1,nchar(input[row])-2) ))
      }
      # If there is a negative tone mentionned :
      if(grepl("negative", input[row]))if(matrix_GS[i,current_category,"negative"]==0 & matrix_GPT4_CA[i,current_category,"negative",  round(current_agent/2+0.01)]>=(12/35) )
      {
        errors = rbind(errors,c(i, current_category,"-",substr(input[row],nchar('"negative": "')+1,nchar(input[row])-2)))
      }
    }
  }
}
colnames(errors) = c("id","category","tone","justification")

write.xlsx(errors,"data/GPT4/GPT4_PIC_errors.xlsx", row.names=F)
