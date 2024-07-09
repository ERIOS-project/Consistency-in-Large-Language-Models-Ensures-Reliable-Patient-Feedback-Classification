# This code explore reproducibility between independant agents. The results of this computation are presented in the discussion of the article.

# import data
matrix_GS = readRDS("data/gold_standard/matrix_GS.rds")
matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4_CA.rds")
matrix_GPT4_standalone = readRDS("data/GPT4/matrix_GPT4_standalone.rds")
matrix_humans = readRDS("data/humans/matrix_humans.rds")

# Store the possible agents
agent = c("1","2","3")

library(irr)


#Compute global Krippendorff alpha for humans
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = matrix_humans[,current_category,current_tone,]
  }
}
global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha between humans :", global_K_alpha))


#Compute global Krippendorff alpha for GPT4s standalone
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = matrix_GPT4_standalone[,current_category,current_tone,]
  }
}
global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha between GPT4s standalone :", global_K_alpha))


#Compute global Krippendorff alpha for GPT4+ECA
thresholded_matrix = matrix_GPT4_CA
thresholded_matrix[thresholded_matrix>=24/35] = 1
thresholded_matrix[thresholded_matrix!=1] = 0
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = thresholded_matrix[,current_category,current_tone,]
  }
}
flatten_matrix[flatten_matrix>=(24/35)] = 1
flatten_matrix[flatten_matrix!=1] = 0

global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha for GPT4+ECA :", round(global_K_alpha,2)))


#Compute global Krippendorff alpha for GPT4+ICA
thresholded_matrix = matrix_GPT4_CA
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = thresholded_matrix[,current_category,current_tone,]
  }
}
flatten_matrix[flatten_matrix==(16/35) | flatten_matrix>=(28/35)] = 1
flatten_matrix[flatten_matrix!=1] = 0

global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha for GPT4+ICA :", round(global_K_alpha,2)))

#Compute global Krippendorff alpha for GPT4+GCA
thresholded_matrix = matrix_GPT4_CA
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = thresholded_matrix[,current_category,current_tone,]
  }
}
flatten_matrix[flatten_matrix>=(28/35)] = 1
flatten_matrix[flatten_matrix!=1] = 0

global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha for GPT4+GCA :", round(global_K_alpha,2)))

