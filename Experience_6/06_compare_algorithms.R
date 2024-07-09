matrix_Regex = readRDS("data/regex/matrix_Regex.rds")
matrix_NB = readRDS("data/NB/matrix_NB.rds")
matrix_LSTM = readRDS("data/LSTM/matrix_LSTM.rds")
matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4.rds")
matrix_GS = readRDS("data/gold_standard/matrix_GS.rds")
matrix_Llama3_CA = readRDS("data/06_Llama3/matrix_Llama3.rds")
# matrix_GPT4_CA without post production
matrix_GPT4_standalone = readRDS("data/02_GPT4/matrix_GPT4_standalone.rds")
matrix_Llama3_standalone = readRDS("data/06_Llama3/matrix_Llama3_standalone.rds")

# To provide custom sub-group results
# matrix_Regex = matrix_Regex[,,tone=="positive"]
# matrix_NB = matrix_NB[,,tone=="positive"]
# matrix_LSTM = matrix_LSTM[,,tone=="positive"]
# matrix_GPT4_CA = matrix_GPT4_CA[,,tone=="positive"]
# matrix_GS = matrix_GS[,,tone=="positive"]
# matrix_Llama3_CA = matrix_Llama3_CA[,,tone=="positive"]


# ----------------- pr-curves computation -----------------

# Define a sequence of threshold levels
thresholds = seq(0.01,1,length.out=70)

# precision and recall curve computation for regex
pr_regex = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(matrix_Regex[matrix_GS==1]>=i)) / length(which(matrix_Regex>=i))
  if(i!= thresholds[1]) if(precision < max(pr_regex[,"precision"]))precision =  max(pr_regex[,"precision"])
  recall = length(which(matrix_Regex[matrix_GS==1]>=i)) / length(which(matrix_GS==1))
  pr_regex = rbind(pr_regex, c(precision,recall))
}
pr_regex = rbind(c(0,max(pr_regex[,"recall"])+0.0001),pr_regex,c(max(pr_regex[,"precision"]),0))

# precision and recall curve computation for NB
pr_nb = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(matrix_NB[matrix_GS==1]>=i)) / length(which(matrix_NB>=i))
  if(i!= thresholds[1]) if(precision < max(pr_nb[,"precision"]))precision =  max(pr_nb[,"precision"])
  recall = length(which(matrix_NB[matrix_GS==1]>=i)) / length(which(matrix_GS==1))
  pr_nb = rbind(pr_nb, c(precision,recall))
}
pr_nb = rbind(c(0,max(pr_nb[,"recall"])+0.0001),pr_nb,c(max(pr_nb[,"precision"]),0))

# precision and recall curve computation for LSTM
pr_lstm = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(matrix_LSTM[matrix_GS==1]>=i)) / length(which(matrix_LSTM>=i))
  if(i!= thresholds[1]) if(!is.na(precision)) if(precision < max(pr_lstm[,"precision"]))precision =  max(pr_lstm[,"precision"])
  recall = length(which(matrix_LSTM[matrix_GS==1]>=i)) / length(which(matrix_GS==1))
  pr_lstm = rbind(pr_lstm, c(precision,recall))
}
pr_lstm[,"precision"][is.na(pr_lstm[,"precision"])] = max(pr_lstm[,"precision"], na.rm=T)
pr_lstm[,"recall"][is.na(pr_lstm[,"recall"])] = max(pr_lstm[,"recall"], na.rm=T)
pr_lstm = rbind(c(0,max(pr_lstm[,"recall"])+0.0001),pr_lstm,c(max(pr_lstm[,"precision"]),0))

# precision and recall curve computation for GPT4 + CA
pr_gpt4_CA = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(matrix_GPT4_CA[matrix_GS==1]>=i)) / length(which(matrix_GPT4_CA>=i))
  if(i!= thresholds[1]) if(precision < max(pr_gpt4_CA[,"precision"]))precision =  max(pr_gpt4_CA[,"precision"])
  recall = length(which(matrix_GPT4_CA[matrix_GS==1]>=i)) / length(which(matrix_GS==1))
  pr_gpt4_CA = rbind(pr_gpt4_CA, c(precision,recall))
}
pr_gpt4_CA = rbind(c(0,max(pr_gpt4_CA[,"recall"])+0.0001),pr_gpt4_CA,c(max(pr_gpt4_CA[,"precision"]),0))

# precision and recall curve computation for Llama3
pr_Llama3_CA = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(matrix_Llama3_CA[matrix_GS==1]>=i)) / length(which(matrix_Llama3_CA>=i))
  if(i!= thresholds[1]) if(precision < max(pr_Llama3_CA[,"precision"]))precision =  max(pr_Llama3_CA[,"precision"])
  recall = length(which(matrix_Llama3_CA[matrix_GS==1]>=i)) / length(which(matrix_GS==1))
  pr_Llama3_CA = rbind(pr_Llama3_CA, c(precision,recall))
}
pr_Llama3_CA = rbind(c(0,max(pr_Llama3_CA[,"recall"])+0.0001),pr_Llama3_CA,c(max(pr_Llama3_CA[,"precision"]),0))


# precision and recall curve computation for GPT4 wopp
pr_gpt4_standalone = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(matrix_GPT4_standalone[matrix_GS==1]>=i)) / length(which(matrix_GPT4_standalone>=i))
  if(i!= thresholds[1]) if(precision < max(pr_gpt4_standalone[,"precision"]))precision =  max(pr_gpt4_standalone[,"precision"])
  recall = length(which(matrix_GPT4_standalone[matrix_GS==1]>=i)) / length(which(matrix_GS==1))
  pr_gpt4_standalone = rbind(pr_gpt4_standalone, c(precision,recall))
}
pr_gpt4_standalone = rbind(c(0,max(pr_gpt4_standalone[,"recall"])+0.0001),pr_gpt4_standalone,c(max(pr_gpt4_standalone[,"precision"]),0))

# precision and recall curve computation for Llama3 wopp
pr_Llama3_standalone = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(matrix_Llama3_standalone[matrix_GS==1]>=i)) / length(which(matrix_Llama3_standalone>=i))
  if(i!= thresholds[1]) if(!is.na(precision)) if(precision < max(pr_Llama3_standalone[,"precision"]))precision =  max(pr_Llama3_standalone[,"precision"])
  recall = length(which(matrix_Llama3_standalone[matrix_GS==1]>=i)) / length(which(matrix_GS==1))
  pr_Llama3_standalone = rbind(pr_Llama3_standalone, c(precision,recall))
}
pr_Llama3_standalone[,"precision"][is.na(pr_Llama3_standalone[,"precision"])] = max(pr_Llama3_standalone[,"precision"], na.rm=T)
pr_Llama3_standalone[,"recall"][is.na(pr_Llama3_standalone[,"recall"])] = max(pr_Llama3_standalone[,"recall"], na.rm=T)
pr_Llama3_standalone = rbind(c(0,max(pr_Llama3_standalone[,"recall"])+0.0001),pr_Llama3_standalone,c(max(pr_Llama3_standalone[,"precision"]),0))


# ----------------- Print max( precision * recall ) to identify the best threshold possible without hypothesis valuating precision or recall. -----------------
pr_table = matrix(data = NA, nrow = 2, ncol=7)
rownames(pr_table) = c("precision","recall")
colnames(pr_table) = c("NB", "Llama-3 alone","LSTM","Regex", "Llama-3 + HF", "GPT-4 alone","GPT-4 + HF")

max_value = 0
max_threshold = 0
for(i in 1:dim(pr_nb)[1]){
  current_value = pr_nb[i,1] * pr_nb[i,2]
  if(current_value>max_value) {
    max_value = current_value
    max_threshold = i
  }
}
pr_table[1,1] = round(pr_nb[max_threshold,1],2)
pr_table[2,1] = round(pr_nb[max_threshold,2],2)

max_value = 0
max_threshold = 0
for(i in 1:dim(pr_Llama3_standalone)[1]){
  current_value = pr_Llama3_standalone[i,1] * pr_Llama3_standalone[i,2]
  if(current_value>max_value) {
    max_value = current_value
    max_threshold = i
  }
}
pr_table[1,2] = round(pr_Llama3_standalone[max_threshold,1],2)
pr_table[2,2] = round(pr_Llama3_standalone[max_threshold,2],2)

max_value = 0
max_threshold = 0
for(i in 1:dim(pr_lstm)[1]){
  current_value = pr_lstm[i,1] * pr_lstm[i,2]
  if(current_value>max_value) {
    max_value = current_value
    max_threshold = i
  }
}
pr_table[1,3] = round(pr_lstm[max_threshold,1],2)
pr_table[2,3] = round(pr_lstm[max_threshold,2],2)

max_value = 0
max_threshold = 0
for(i in 1:dim(pr_regex)[1]){
  current_value = pr_regex[i,1] * pr_regex[i,2]
  if(current_value>max_value) {
    max_value = current_value
    max_threshold = i
  }
}
pr_table[1,4] = round(pr_regex[max_threshold,1],2)
pr_table[2,4] = round(pr_regex[max_threshold,2],2)

# Llama 3 and GPT-4 have to select the threshold that filter all hallucinations (with a score at least >=28/35) to avoid hallucinations
pr_table[1,5] = round(pr_Llama3_CA[length(thresholds) - length(which(thresholds>=(28/35)))+1,1],2)
pr_table[2,5] = round(pr_Llama3_CA[length(thresholds) - length(which(thresholds>=(28/35)))+1,2],2)

max_value = 0
max_threshold = 0
for(i in 1:dim(pr_gpt4_standalone)[1]){
  current_value = pr_gpt4_standalone[i,1] * pr_gpt4_standalone[i,2]
  if(current_value>max_value) {
    max_value = current_value
    max_threshold = i
  }
}
pr_table[1,6] = round(pr_gpt4_standalone[max_threshold,1],2)
pr_table[2,6] = round(pr_gpt4_standalone[max_threshold,2],2)

# Llama 3 and GPT-4 have to select the threshold that filter all hallucinations (with a score at least >=32/35)
pr_table[1,7] = round(pr_gpt4_CA[length(thresholds) - length(which(thresholds>=(28/35)))+1,1],2)
pr_table[2,7] = round(pr_gpt4_CA[length(thresholds) - length(which(thresholds>=(28/35)))+1,2],2)

print(pr_table)





#----------------- Plot the pr-curves-----------------


library(ggplot2)



# Creating a dataframe for ggplot
df_regex <- data.frame(Recall = pr_regex[,"recall"], Precision = pr_regex[,"precision"], Model = 'Regex')
df_nb <- data.frame(Recall = pr_nb[,"recall"], Precision = pr_nb[,"precision"], Model = 'Naive Bayes')
df_lstm <- data.frame(Recall = pr_lstm[,"recall"], Precision = pr_lstm[,"precision"], Model = 'LSTM')
df_gpt4_CA <- data.frame(Recall = pr_gpt4_CA[,"recall"], Precision = pr_gpt4_CA[,"precision"], Model = 'GPT-4')
df_Llama3_CA <- data.frame(Recall = pr_Llama3_CA[,"recall"], Precision = pr_Llama3_CA[,"precision"], Model = 'Llama-3')
df_gpt4_standalone <- data.frame(Recall = pr_gpt4_standalone[,"recall"], Precision = pr_gpt4_standalone[,"precision"], Model = 'GPT-4_wopp')
df_Llama3_standalone <- data.frame(Recall = pr_Llama3_standalone[,"recall"], Precision = pr_Llama3_standalone[,"precision"], Model = 'Llama-3_wopp')


# Combining all data frames into one
pr_data <- rbind(df_regex,df_nb, df_lstm, df_gpt4_CA,df_Llama3_CA,df_gpt4_standalone,df_Llama3_standalone)
library(dplyr)
pr_data = pr_data%>%
  arrange(Recall)

# AUC APPROXIMATION computation
AUC_regex = 0
for(i in 2:dim(df_regex)[1]){
  AUC_regex = AUC_regex + ((df_regex$Recall[i-1] - df_regex$Recall[i]) * ((df_regex$Precision[i-1] + df_regex$Precision[i])/2)   )
}
AUC_nb = 0
for(i in 2:dim(df_nb)[1]){
  AUC_nb = AUC_nb + ((df_nb$Recall[i-1] - df_nb$Recall[i]) * ((df_nb$Precision[i-1] + df_nb$Precision[i])/2)   )
}
AUC_lstm = 0
for(i in 2:dim(df_lstm)[1]){
  AUC_lstm = AUC_lstm + ((df_lstm$Recall[i-1] - df_lstm$Recall[i]) * ((df_lstm$Precision[i-1] + df_lstm$Precision[i])/2)   )
}
AUC_gpt4 = 0
for(i in 2:dim(df_gpt4_CA)[1]){
  AUC_gpt4 = AUC_gpt4 + ((df_gpt4_CA$Recall[i-1] - df_gpt4_CA$Recall[i]) * ((df_gpt4_CA$Precision[i-1] + df_gpt4_CA$Precision[i])/2)   )
}
AUC_Llama3 = 0
for(i in 2:dim(df_Llama3_CA)[1]){
  AUC_Llama3 = AUC_Llama3 + ((df_Llama3_CA$Recall[i-1] - df_Llama3_CA$Recall[i]) * ((df_Llama3_CA$Precision[i-1] + df_Llama3_CA$Precision[i])/2)   )
}
AUC_gpt4_wopp = 0
for(i in 2:dim(df_gpt4_standalone)[1]){
  AUC_gpt4_wopp = AUC_gpt4_wopp + ((df_gpt4_standalone$Recall[i-1] - df_gpt4_standalone$Recall[i]) * ((df_gpt4_standalone$Precision[i-1] + df_gpt4_standalone$Precision[i])/2)   )
}
AUC_Llama3_wopp = 0
for(i in 2:dim(df_Llama3_standalone)[1]){
  AUC_Llama3_wopp = AUC_Llama3_wopp + ((df_Llama3_standalone$Recall[i-1] - df_Llama3_standalone$Recall[i]) * ((df_Llama3_standalone$Precision[i-1] + df_Llama3_standalone$Precision[i])/2)   )
}


pr_data$Model[pr_data$Model=="GPT-4"] = paste(      "GPT-4 + GCA   : ",round(AUC_gpt4,2)," ± ",round(1.96*(AUC_gpt4)*(1-AUC_gpt4)/sqrt(length(index) * length(category) * length(tone)),4)*1000,"e-4",sep="")
pr_data$Model[pr_data$Model=="Llama-3"] = paste(    "Llama 3  + GCA   : ",round(AUC_Llama3,2)," ± ",round(1.96*(AUC_Llama3)*(1-AUC_Llama3)/sqrt(length(index) * length(category) * length(tone)),4)*1000,"e-4",sep="")
pr_data$Model[pr_data$Model=="GPT-4_wopp"] = paste(      "GPT 4 standalone   : ",round(AUC_gpt4_wopp,2)," ± ",round(1.96*(AUC_gpt4_wopp)*(1-AUC_gpt4_wopp)/sqrt(length(index) * length(category) * length(tone)),4)*1000,"e-4",sep="")
pr_data$Model[pr_data$Model=="Llama-3_wopp"] = paste(    "Llama 3 standalone   : ",round(AUC_Llama3_wopp,2)," ± ",round(1.96*(AUC_Llama3_wopp)*(1-AUC_Llama3_wopp)/sqrt(length(index) * length(category) * length(tone)),4)*1000,"e-4",sep="")
pr_data$Model[pr_data$Model=="LSTM"] = paste(       "LSTM   : ",round(AUC_lstm,2)," ± ",round(1.96*(AUC_lstm)*(1-AUC_lstm)/sqrt(length(index) * length(category) * length(tone)),4)*1000,"e-4",sep="")
pr_data$Model[pr_data$Model=="Naive Bayes"] = paste("NB   : ",round(AUC_nb,2)," ± ",round(1.96*(AUC_nb)*(1-AUC_nb)/sqrt(length(index) * length(category) * length(tone)),4)*1000,"e-4",sep="")
pr_data$Model[pr_data$Model=="Regex"] = paste(      "Regex   : ",round(AUC_regex,2)," ± ",round(1.96*(AUC_regex)*(1-AUC_regex)/sqrt(length(index) * length(category) * length(tone)),4)*1000,"e-4",sep="")
colnames(pr_data)[3] = "Model : pr-AUC"

pr_data$`Model : pr-AUC` = factor(pr_data$`Model : pr-AUC`, levels=names(table(pr_data$`Model : pr-AUC`))[c(6,5,7,4,3,2,1)])


# We need to add a dot at the coordinates of confidence score of 32/35 (threshold from which there is no hallucinations left)

threshold_28 = length(which(thresholds<(28/35)))+1
gpt4_x = pr_gpt4_CA[threshold_28,2]
gpt4_y = pr_gpt4_CA[threshold_28,1]
llama3_x = pr_Llama3_CA[threshold_28,2]
llama3_y = pr_Llama3_CA[threshold_28,1]

# Plotting with ggplot2
plot = ggplot(pr_data, aes(x = Recall, y = Precision, color = `Model : pr-AUC`)) +
  geom_path(cex=2) +
  labs(title = "",
       x = "Recall",
       y = "Precision") +
  theme(
    panel.grid.major = element_blank(), # Remove major grid lines
    panel.grid.minor = element_blank(), # Remove minor grid lines
    axis.line = element_line(color = "black"), # Add axis lines
    panel.background = element_rect(fill = "white", color = NA),  # Set panel background to white
    plot.background = element_rect(fill = "white", color = NA),  # Set plot background to white
    legend.background = element_rect(fill = "white", color = NA),  # Set legend background to white
    legend.key = element_rect(fill = "white", color = NA)  # Set legend key background to white
  ) +
  ylim(-0.001,1.001)+
  xlim(-0.001,1.001)+
  scale_color_manual(values = c("pink", "lightgreen","lightblue","#E6E6FA","purple", "#FFDAB9","orange"))+
  geom_point(aes(x = gpt4_x, y = gpt4_y), color = "black", size = 5) +
  geom_point(aes(x = llama3_x, y = llama3_y), color = "black", size = 5)
print(plot)






# ----------------- Sub groups analysis -----------------

plots = list()
AUCs = data.frame(
  Categorie_tone = vector(),
  absolute_and_proportion_frequency = vector(),
  AUC_regex = vector(),
  AUC_nb = vector(),
  AUC_lstm = vector(),
  AUC_gpt4 = vector(),
  AUC_Llama3 = vector(),
  AUC_gpt4_CA = vector(),
  AUC_Llama3_CA = vector()
)

for(current_category in category){
  for(current_tone in tone){
    matrix_Regex = readRDS("data/regex/matrix_Regex.rds")
    matrix_NB = readRDS("data/NB/matrix_NB.rds")
    matrix_LSTM = readRDS("data/LSTM/matrix_LSTM.rds")
    matrix_GPT4_standalone = readRDS("data/GPT4/matrix_GPT4_standalone.rds")
    matrix_Llama3_standalone = readRDS("data/Llama3/matrix_Llama3_CA_standalone.rds")
    matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4_CA.rds")
    matrix_Llama3_CA = readRDS("data/Llama3/matrix_Llama3_CA.rds")
    matrix_GS = readRDS("data/gold_standard/matrix_GS.rds")
    
    matrix_Regex = matrix_Regex[,current_category,current_tone]
    matrix_NB = matrix_NB[,current_category,current_tone]
    matrix_LSTM = matrix_LSTM[,current_category,current_tone]
    matrix_GPT4_standalone = matrix_GPT4_standalone[,current_category,current_tone]
    matrix_Llama3_standalone = matrix_Llama3_standalone[,current_category,current_tone]
    matrix_GPT4_CA = matrix_GPT4_CA[,current_category,current_tone]
    matrix_Llama3_CA = matrix_Llama3_CA[,current_category,current_tone]
    matrix_GS = matrix_GS[,current_category,current_tone]
    
    # Define a sequence of threshold levels
    thresholds = seq(0.001,0.999,length.out=1000)
    
    # precision and recall curve computation for regex
    pr_regex = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
    for(i in thresholds){
      if(length(which(matrix_Regex>=i)) >0)precision = length(which(matrix_Regex[matrix_GS==1]>=i)) / length(which(matrix_Regex>=i)) else precision=0
      if(length(which(matrix_GS==1)))recall = length(which(matrix_Regex[matrix_GS==1]>=i)) / length(which(matrix_GS==1))else recall = 0
      pr_regex = rbind(pr_regex, c(precision,recall))
    }
    pr_regex = rbind(c(0,max(pr_regex[,"recall"])+0.0001),pr_regex,c(max(pr_regex[,"precision"]),0))
    
    # precision and recall curve computation for NB
    pr_nb = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
    for(i in thresholds){
      if(length(which(matrix_NB>=i)) >0)precision = length(which(matrix_NB[matrix_GS==1]>=i)) / length(which(matrix_NB>=i)) else precision=0
      if(length(which(matrix_GS==1)))recall = length(which(matrix_NB[matrix_GS==1]>=i)) / length(which(matrix_GS==1))else recall = 0
      pr_nb = rbind(pr_nb, c(precision,recall))
    }
    pr_nb = rbind(c(0,max(pr_nb[,"recall"])+0.0001),pr_nb,c(max(pr_nb[,"precision"]),0))
    
    # precision and recall curve computation for LSTM
    pr_lstm = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
    for(i in thresholds){
      if(length(which(matrix_LSTM>=i)) >0)precision = length(which(matrix_LSTM[matrix_GS==1]>=i)) / length(which(matrix_LSTM>=i)) else precision=0
      if(length(which(matrix_GS==1)))recall = length(which(matrix_LSTM[matrix_GS==1]>=i)) / length(which(matrix_GS==1))else recall = 0
      pr_lstm = rbind(pr_lstm, c(precision,recall))
    }
    pr_lstm[,"precision"][is.na(pr_lstm[,"precision"])] = max(pr_lstm[,"precision"], na.rm=T)
    pr_lstm[,"recall"][is.na(pr_lstm[,"recall"])] = max(pr_lstm[,"recall"], na.rm=T)
    pr_lstm = rbind(c(0,max(pr_lstm[,"recall"])+0.0001),pr_lstm,c(max(pr_lstm[,"precision"]),0))
    
    # precision and recall curve computation for GPT4 standalone
    pr_gpt4_CA = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
    for(i in thresholds){
      if(length(which(matrix_GPT4_standalone>=i)) >0) precision = length(which(matrix_GPT4_standalone[matrix_GS==1]>=i)) / length(which(matrix_GPT4_standalone>=i)) else precision=0
      if(length(which(matrix_GS==1))) recall = length(which(matrix_GPT4_standalone[matrix_GS==1]>=i)) / length(which(matrix_GS==1)) else recall = 0
      pr_gpt4_CA = rbind(pr_gpt4_CA, c(precision,recall))
    }
    pr_gpt4_CA = rbind(c(0,max(pr_gpt4_CA[,"recall"])+0.0001),pr_gpt4_CA,c(max(pr_gpt4_CA[,"precision"]),0))
    
    # precision and recall curve computation for Llama3 standalone
    pr_Llama3_CA = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
    for(i in thresholds){
      if(length(which(matrix_Llama3_standalone>=i)) >0) precision = length(which(matrix_Llama3_standalone[matrix_GS==1]>=i)) / length(which(matrix_Llama3_standalone>=i)) else precision=0
      if(length(which(matrix_GS==1))) recall = length(which(matrix_Llama3_standalone[matrix_GS==1]>=i)) / length(which(matrix_GS==1)) else recall = 0
      pr_Llama3_CA = rbind(pr_Llama3_CA, c(precision,recall))
    }
    pr_Llama3_CA = rbind(c(0,max(pr_Llama3_CA[,"recall"])+0.0001),pr_Llama3_CA,c(max(pr_Llama3_CA[,"precision"]),0))
    
    # precision and recall curve computation for GPT4_CA
    pr_gpt4_CA_CA = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
    for(i in thresholds){
      if(length(which(matrix_GPT4_CA>=i)) >0) precision = length(which(matrix_GPT4_CA[matrix_GS==1]>=i)) / length(which(matrix_GPT4_CA>=i)) else precision=0
      if(length(which(matrix_GS==1))) recall = length(which(matrix_GPT4_CA[matrix_GS==1]>=i)) / length(which(matrix_GS==1)) else recall = 0
      pr_gpt4_CA_CA = rbind(pr_gpt4_CA_CA, c(precision,recall))
    }
    pr_gpt4_CA_CA = rbind(c(0,max(pr_gpt4_CA_CA[,"recall"])+0.0001),pr_gpt4_CA_CA,c(max(pr_gpt4_CA_CA[,"precision"]),0))
    
    # precision and recall curve computation for Llama3_CA
    pr_Llama3_CA_CA = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
    for(i in thresholds){
      if(length(which(matrix_Llama3_CA>=i)) >0) precision = length(which(matrix_Llama3_CA[matrix_GS==1]>=i)) / length(which(matrix_Llama3_CA>=i)) else precision=0
      if(length(which(matrix_GS==1))) recall = length(which(matrix_Llama3_CA[matrix_GS==1]>=i)) / length(which(matrix_GS==1)) else recall = 0
      pr_Llama3_CA_CA = rbind(pr_Llama3_CA_CA, c(precision,recall))
    }
    pr_Llama3_CA_CA = rbind(c(0,max(pr_Llama3_CA_CA[,"recall"])+0.0001),pr_Llama3_CA_CA,c(max(pr_Llama3_CA_CA[,"precision"]),0))
    
    # library(ggplot2)
    
    # Creating a dataframe for ggplot
    df_regex <- data.frame(Recall = c(max(pr_regex[,"recall"], na.rm = T),pr_regex[,"recall"],0), Precision = c(0,pr_regex[,"precision"],max(pr_regex[,"precision"], na.rm = T)), Model = 'Regex')
    df_nb <- data.frame(Recall = c(max(pr_nb[,"recall"], na.rm = T),pr_nb[,"recall"],0), Precision = c(0,pr_nb[,"precision"],max(pr_nb[,"precision"], na.rm = T)), Model = 'Naive Bayes')
    df_lstm <- data.frame(Recall = c(max(pr_lstm[,"recall"], na.rm = T),pr_lstm[,"recall"],0), Precision = c(0,pr_lstm[,"precision"],max(pr_lstm[,"precision"], na.rm = T)), Model = 'LSTM')
    df_gpt4_CA <- data.frame(Recall = c(max(pr_gpt4_CA[,"recall"], na.rm = T),pr_gpt4_CA[,"recall"],0), Precision = c(0,pr_gpt4_CA[,"precision"],max(pr_gpt4_CA[,"precision"], na.rm = T)), Model = 'GPT-4')
    df_Llama3_CA <- data.frame(Recall = c(max(pr_Llama3_CA[,"recall"], na.rm = T),pr_Llama3_CA[,"recall"],0), Precision = c(0,pr_Llama3_CA[,"precision"],max(pr_Llama3_CA[,"precision"], na.rm = T)), Model = 'Llama-3')
    df_gpt4_CA_CA <- data.frame(Recall = c(max(pr_gpt4_CA_CA[,"recall"], na.rm = T),pr_gpt4_CA_CA[,"recall"],0), Precision = c(0,pr_gpt4_CA_CA[,"precision"],max(pr_gpt4_CA_CA[,"precision"], na.rm = T)), Model = 'GPT-4_CA')
    df_Llama3_CA_CA <- data.frame(Recall = c(max(pr_Llama3_CA_CA[,"recall"], na.rm = T),pr_Llama3_CA_CA[,"recall"],0), Precision = c(0,pr_Llama3_CA_CA[,"precision"],max(pr_Llama3_CA_CA[,"precision"], na.rm = T)), Model = 'Llama-3_CA')
    
    
    
    # Smooth the lines
    for(i in 2:dim(df_regex)[1]){
      if(df_regex$Recall[i] >= df_regex$Recall[i-1] | is.na(df_regex$Recall[i])) df_regex$Recall[i] = df_regex$Recall[i-1]- 0.00001
      if(df_regex$Precision[i] <= df_regex$Precision[i-1]| is.na(df_regex$Precision[i])) df_regex$Precision[i] = df_regex$Precision[i-1]+ 0.00001
    }
    for(i in 2:dim(df_nb)[1]){
      if(df_nb$Recall[i] >= df_nb$Recall[i-1] | is.na(df_nb$Recall[i])) df_nb$Recall[i] = df_nb$Recall[i-1]- 0.00001
      if(df_nb$Precision[i] <= df_nb$Precision[i-1]| is.na(df_nb$Precision[i])) df_nb$Precision[i] = df_nb$Precision[i-1]+ 0.00001
    }
    for(i in 2:dim(df_lstm)[1]){
      if(df_lstm$Recall[i] >= df_lstm$Recall[i-1]| is.na(df_lstm$Recall[i])) df_lstm$Recall[i] = df_lstm$Recall[i-1]- 0.00001
      if(df_lstm$Precision[i] <= df_lstm$Precision[i-1]| is.na(df_lstm$Precision[i])) df_lstm$Precision[i] = df_lstm$Precision[i-1]+ 0.00001
    }
    for(i in 2:dim(df_gpt4_CA)[1]){
      if(df_gpt4_CA$Recall[i] >= df_gpt4_CA$Recall[i-1]| is.na(df_gpt4_CA$Recall[i])) df_gpt4_CA$Recall[i] = df_gpt4_CA$Recall[i-1]- 0.00001
      if(df_gpt4_CA$Precision[i] <= df_gpt4_CA$Precision[i-1]| is.na(df_gpt4_CA$Precision[i])) df_gpt4_CA$Precision[i] = df_gpt4_CA$Precision[i-1]+ 0.00001
    }
    for(i in 2:dim(df_Llama3_CA)[1]){
      if(df_Llama3_CA$Recall[i] >= df_Llama3_CA$Recall[i-1]| is.na(df_Llama3_CA$Recall[i])) df_Llama3_CA$Recall[i] = df_Llama3_CA$Recall[i-1]- 0.00001
      if(df_Llama3_CA$Precision[i] <= df_Llama3_CA$Precision[i-1]| is.na(df_Llama3_CA$Precision[i])) df_Llama3_CA$Precision[i] = df_Llama3_CA$Precision[i-1]+ 0.00001
    }
    for(i in 2:dim(df_gpt4_CA_CA)[1]){
      if(df_gpt4_CA_CA$Recall[i] >= df_gpt4_CA_CA$Recall[i-1]| is.na(df_gpt4_CA_CA$Recall[i])) df_gpt4_CA_CA$Recall[i] = df_gpt4_CA_CA$Recall[i-1]- 0.00001
      if(df_gpt4_CA_CA$Precision[i] <= df_gpt4_CA_CA$Precision[i-1]| is.na(df_gpt4_CA_CA$Precision[i])) df_gpt4_CA_CA$Precision[i] = df_gpt4_CA_CA$Precision[i-1]+ 0.00001
    }
    for(i in 2:dim(df_Llama3_CA_CA)[1]){
      if(df_Llama3_CA_CA$Recall[i] >= df_Llama3_CA_CA$Recall[i-1]| is.na(df_Llama3_CA_CA$Recall[i])) df_Llama3_CA_CA$Recall[i] = df_Llama3_CA_CA$Recall[i-1]- 0.00001
      if(df_Llama3_CA_CA$Precision[i] <= df_Llama3_CA_CA$Precision[i-1]| is.na(df_Llama3_CA_CA$Precision[i])) df_Llama3_CA_CA$Precision[i] = df_Llama3_CA_CA$Precision[i-1]+ 0.00001
    }
    
    
    # AUC APPROXIMATION computation
    AUC_regex = 0
    for(i in 2:dim(df_regex)[1]){
      AUC_regex = AUC_regex + ((df_regex$Recall[i-1] - df_regex$Recall[i]) * ((df_regex$Precision[i-1] + df_regex$Precision[i])/2)   )
    }
    AUC_nb = 0
    for(i in 2:dim(df_nb)[1]){
      AUC_nb = AUC_nb + ((df_nb$Recall[i-1] - df_nb$Recall[i]) * ((df_nb$Precision[i-1] + df_nb$Precision[i])/2)   )
    }
    AUC_lstm = 0
    for(i in 2:dim(df_lstm)[1]){
      AUC_lstm = AUC_lstm + ((df_lstm$Recall[i-1] - df_lstm$Recall[i]) * ((df_lstm$Precision[i-1] + df_lstm$Precision[i])/2)   )
    }
    AUC_gpt4 = 0
    for(i in 2:dim(df_gpt4_CA)[1]){
      AUC_gpt4 = AUC_gpt4 + ((df_gpt4_CA$Recall[i-1] - df_gpt4_CA$Recall[i]) * ((df_gpt4_CA$Precision[i-1] + df_gpt4_CA$Precision[i])/2)   )
    }
    AUC_Llama3 = 0
    for(i in 2:dim(df_Llama3_CA)[1]){
      AUC_Llama3 = AUC_Llama3 + ((df_Llama3_CA$Recall[i-1] - df_Llama3_CA$Recall[i]) * ((df_Llama3_CA$Precision[i-1] + df_Llama3_CA$Precision[i])/2)   )
    }
    AUC_gpt4_CA = 0
    for(i in 2:dim(df_gpt4_CA_CA)[1]){
      AUC_gpt4_CA = AUC_gpt4_CA + ((df_gpt4_CA_CA$Recall[i-1] - df_gpt4_CA_CA$Recall[i]) * ((df_gpt4_CA_CA$Precision[i-1] + df_gpt4_CA_CA$Precision[i])/2)   )
    }
    AUC_Llama3_CA = 0
    for(i in 2:dim(df_Llama3_CA_CA)[1]){
      AUC_Llama3_CA = AUC_Llama3_CA + ((df_Llama3_CA_CA$Recall[i-1] - df_Llama3_CA_CA$Recall[i]) * ((df_Llama3_CA_CA$Precision[i-1] + df_Llama3_CA_CA$Precision[i])/2)   )
    }
    
    
    # compute absolute and proportion effectives from the gold standard for each subgroup
    absolute = sum(matrix_GS)
    proportion = round(absolute/length(index),2)
    current_frequency = paste(absolute," (",proportion,")",sep="")
    
    current_AUC = data.frame(
      Categorie_tone = paste(current_category,"-",current_tone),
      absolute_and_proportion_frequency = current_frequency,
      AUC_regex = AUC_regex,
      AUC_nb = AUC_nb,
      AUC_lstm = AUC_lstm,
      AUC_gpt4 = AUC_gpt4,
      AUC_Llama3 = AUC_Llama3,
      AUC_gpt4_CA = AUC_gpt4_CA,
      AUC_Llama3_CA = AUC_Llama3_CA
    )
    
    AUCs = rbind(AUCs, current_AUC)
    
  }
}


AUCs2 = AUCs
  
AUCs2$AUC_regex =  paste( round(AUCs$AUC_regex,2) , "±", round(1.96*(AUCs$AUC_regex)*(1-AUCs$AUC_regex)/sqrt(length(index)),2) )
AUCs2$AUC_nb =  paste( round(AUCs$AUC_nb,2) , "±", round(1.96*(AUCs$AUC_nb)*(1-AUCs$AUC_nb)/sqrt(length(index)),2) )
AUCs2$AUC_lstm =  paste( round(AUCs$AUC_lstm,2) , "±", round(1.96*(AUCs$AUC_lstm)*(1-AUCs$AUC_lstm)/sqrt(length(index)),2) )
AUCs2$AUC_gpt4 =  paste( round(AUCs$AUC_gpt4,2) , "±", round(1.96*(AUCs$AUC_gpt4)*(1-AUCs$AUC_gpt4)/sqrt(length(index)),2) )
AUCs2$AUC_Llama3 =  paste( round(AUCs$AUC_Llama3,2) , "±", round(1.96*(AUCs$AUC_Llama3)*(1-AUCs$AUC_Llama3)/sqrt(length(index)),2) )
AUCs2$AUC_gpt4_CA =  paste( round(AUCs$AUC_gpt4_CA,2) , "±", round(1.96*(AUCs$AUC_gpt4_CA)*(1-AUCs$AUC_gpt4_CA)/sqrt(length(index)),2) )
AUCs2$AUC_Llama3_CA =  paste( round(AUCs$AUC_Llama3_CA,2) , "±", round(1.96*(AUCs$AUC_Llama3_CA)*(1-AUCs$AUC_Llama3_CA)/sqrt(length(index)),2) )

AUCs$AUC_regex[AUCs$AUC_regex>1] = 1
AUCs$AUC_nb[AUCs$AUC_nb>1] = 1
AUCs$AUC_lstm[AUCs$AUC_lstm>1] = 1
AUCs$AUC_gpt4[AUCs$AUC_gpt4>1] = 1
AUCs$AUC_Llama3[AUCs$AUC_Llama3>1] = 1
AUCs$AUC_gpt4_CA[AUCs$AUC_gpt4_CA>1] = 1
AUCs$AUC_Llama3_CA[AUCs$AUC_Llama3_CA>1] = 1

AUCs$AUC_regex = round(AUCs$AUC_regex,3)
AUCs$AUC_nb = round(AUCs$AUC_nb,3)
AUCs$AUC_lstm = round(AUCs$AUC_lstm,3)
AUCs$AUC_gpt4 = round(AUCs$AUC_gpt4,3)
AUCs$AUC_Llama3 = round(AUCs$AUC_Llama3,3)
AUCs$AUC_gpt4_CA = round(AUCs$AUC_gpt4_CA,3)
AUCs$AUC_Llama3_CA = round(AUCs$AUC_Llama3_CA,3)

library(xlsx)


for(current_category in 1:length(category)){
  for (i in 1:dim(AUCs)[1]){
    gsub(category[current_category],category.en[current_category], AUCs$Categorie_tone[i])
  }
}



write.xlsx(AUCs, "Sub_groups_AUCs_numeric.xlsx")
write.xlsx(AUCs2, "Sub_groups_AUCs_character.xlsx")

library(formattable)

colnames(AUCs) = c("Categories - tones","Frequency do identify","Regex AUC","Naive Bayes AUC", "LSTM AUC", "GPT-4 AUC", "Llama-3 AUC","GPT-4 CA AUC", "Llama-3 CA AUC")

#Translation of the categories in english
for(current_category in 1:length(category)){
  for (i in 1:dim(AUCs)[1]){
    AUCs$`Categories - tones`[i] = gsub(category[current_category],category.en[current_category], AUCs$`Categories - tones`[i])
  }
}


# Create a formattable object with custom formatting
pretty_table <- formattable(AUCs, list(
  `Regex AUC` = color_tile("white", "lightgreen"),
  `Naive Bayes AUC` = color_tile("white", "lightgreen"),
  `LSTM AUC` = color_tile("white", "lightgreen"),
  `GPT-4 AUC` = color_tile("white", "lightgreen"),
  `Llama-3 AUC` = color_tile("white", "lightgreen"),
  `GPT-4 CA AUC` = color_tile("white", "lightgreen"),
  `Llama-3 CA AUC` = color_tile("white", "lightgreen")
))

# Print the table
pretty_table

library(webshot)
library(htmlwidgets)
# Use webshot to capture the HTML file saved by hand as an image
webshot("Table sub group analysis.html", "Table sub group analysis.png", delay = 3)
