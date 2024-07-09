# This code evaluates the performances of humans, GPT4 standalone, GPT4+ECA, GPT4+ICA, GPT4+GCA to produce results of experiences 1 to 5

# import data
matrix_GS = readRDS("data/gold_standard/matrix_GS.rds")
matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4_CA.rds")
matrix_GPT4_standalone = readRDS("data/GPT4/matrix_GPT4_standalone.rds")
matrix_humans = readRDS("data/humans/matrix_humans.rds")


#performances of humans individually :
precision = round(length(which(matrix_humans[,,,1][matrix_GS==1] ==1)) / length(which(matrix_humans[,,,1]==1)),2)
recall = round(length(which(matrix_humans[,,,1][matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
print(paste("human 1 : precision =",precision,"; recall =",recall))
precision = round(length(which(matrix_humans[,,,2][matrix_GS==1] ==1)) / length(which(matrix_humans[,,,2]==1)),2)
recall = round(length(which(matrix_humans[,,,2][matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
print(paste("human 2 : precision =",precision,"; recall =",recall))
precision = round(length(which(matrix_humans[,,,3][matrix_GS==1] ==1)) / length(which(matrix_humans[,,,3]==1)),2)
recall = round(length(which(matrix_humans[,,,3][matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
print(paste("human 3 : precision =",precision,"; recall =",recall))

#performances of GPT4s individually :
precision = round(length(which(matrix_GPT4_standalone[,,,1][matrix_GS==1] ==1)) / length(which(matrix_GPT4_standalone[,,,1]==1)),2)
recall = round(length(which(matrix_GPT4_standalone[,,,1][matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
print(paste("GPT4 1 : precision =",precision,"; recall =",recall))
precision = round(length(which(matrix_GPT4_standalone[,,,2][matrix_GS==1] ==1)) / length(which(matrix_GPT4_standalone[,,,2]==1)),2)
recall = round(length(which(matrix_GPT4_standalone[,,,2][matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
print(paste("GPT4 2 : precision =",precision,"; recall =",recall))
precision = round(length(which(matrix_GPT4_standalone[,,,3][matrix_GS==1] ==1)) / length(which(matrix_GPT4_standalone[,,,3]==1)),2)
recall = round(length(which(matrix_GPT4_standalone[,,,3][matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
print(paste("GPT4 3 : precision =",precision,"; recall =",recall))



# Store the possible agents
agent = c("1","2","3")
# Create the array squeleton to create a 4 dimensional matrix encompassing three gold standard matrices along : matrix_GS2 
matrix_GS2 = array(data=0, dim=c(
  length(index),
  length(category),
  length(tone),
  length(agent)
), 
dimnames = list(index,category,tone,agent))

matrix_GS2[,,,1] = matrix_GS
matrix_GS2[,,,2] = matrix_GS
matrix_GS2[,,,3] = matrix_GS

# The gold standard of reference is this new matrix designed to evaluate 3 agents at a time.
matrix_GS = matrix_GS2

print_results = function(){
  # humans mean performances
  errors = length(which(matrix_humans != matrix_GS))
  print(paste("humans errors :",errors))
  missing = length(which(matrix_humans[matrix_humans==0]!=matrix_GS[matrix_humans==0]))
  too_much = length(which(matrix_humans[matrix_humans==1]!=matrix_GS[matrix_humans==1]))
  print(paste("missing :",missing,"; too much :", too_much))
  precision = round(length(which(matrix_humans[matrix_GS==1] ==1)) / length(which(matrix_humans==1)),2)
  recall = round(length(which(matrix_humans[matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
  print(paste("humans : precision =",precision,"; recall =",recall))
  
  print("-----")
  # GPT 4 alone mean performances
  errors = (length(which(matrix_GPT4_standalone!= matrix_GS)))
  print(paste("GPT4 errors :",errors))
  missing = length(which(matrix_GPT4_standalone[matrix_GPT4_standalone==0]!=matrix_GS[matrix_GPT4_standalone==0]))
  too_much = length(which(matrix_GPT4_standalone[matrix_GPT4_standalone==1]!=matrix_GS[matrix_GPT4_standalone==1]))
  print(paste("missing :",missing,"; too much :", too_much))
  precision = round(length(which(matrix_GPT4_standalone[matrix_GS==1] ==1)) / length(which(matrix_GPT4_standalone==1)),2)
  recall = round(length(which(matrix_GPT4_standalone[matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
  print(paste("GPT4 alone : precision =",precision,"; recall =",recall))
  
  
  print("-----")
  # ==16/35 | >=28/35 : The results equal or superior to this score are those which fulfill Internal Consistency assessment.
  matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4_CA.rds") #as this matrix will be thresholded each time, it is necessary to reload it.
  matrix_GPT4_CA[matrix_GPT4_CA==(16/35) | matrix_GPT4_CA>=28/35] = 1
  matrix_GPT4_CA[matrix_GPT4_CA!=1] = 0
  errors = (length(which(matrix_GPT4_CA != matrix_GS)))
  print(paste("==16/35 | >=28/35 errors :",errors))
  missing = length(which(matrix_GPT4_CA[matrix_GPT4_CA==0]!=matrix_GS[matrix_GPT4_CA==0]))
  too_much = length(which(matrix_GPT4_CA[matrix_GPT4_CA==1]!=matrix_GS[matrix_GPT4_CA==1]))
  print(paste("missing :",missing,"; too much :", too_much))
  precision = round(length(which(matrix_GPT4_CA[matrix_GS==1] ==1)) / length(which(matrix_GPT4_CA==1)),2)
  recall =round(length(which(matrix_GPT4_CA[matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
  print(paste("==16/35 | >=28/35 : precision =",precision,"; recall =",recall))
  
  print("-----")
  # >=24/35 : The results equal or superior to this score are those which fulfill External Consistency assessment.
  matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4_CA.rds")
  matrix_GPT4_CA[matrix_GPT4_CA>=(24/35)] = 1
  matrix_GPT4_CA[matrix_GPT4_CA!=1] = 0
  errors = (length(which(matrix_GPT4_CA!= matrix_GS)))
  print(paste("24/35 errors :",errors))
  missing = length(which(matrix_GPT4_CA[matrix_GPT4_CA==0]!=matrix_GS[matrix_GPT4_CA==0]))
  too_much = length(which(matrix_GPT4_CA[matrix_GPT4_CA==1]!=matrix_GS[matrix_GPT4_CA==1]))
  print(paste("missing :",missing,"; too much :", too_much))
  precision = round(length(which(matrix_GPT4_CA[matrix_GS==1] ==1)) / length(which(matrix_GPT4_CA==1)),2)
  recall =round(length(which(matrix_GPT4_CA[matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
  print(paste(">=24/35 : precision =",precision,"; recall =",recall))
  matrix_ECA = matrix_GPT4_CA
  
  print("-----")
  # >=28/35 : The results equal or superior to this score are those which fulfill Global Consistency assessment.
  matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4_CA.rds")
  matrix_GPT4_CA[matrix_GPT4_CA>=(28/35)] = 1
  matrix_GPT4_CA[matrix_GPT4_CA!=1] = 0
  errors = (length(which(matrix_GPT4_CA!= matrix_GS)))
  print(paste("28/35 errors :",errors))
  missing = length(which(matrix_GPT4_CA[matrix_GPT4_CA==0]!=matrix_GS[matrix_GPT4_CA==0]))
  too_much = length(which(matrix_GPT4_CA[matrix_GPT4_CA==1]!=matrix_GS[matrix_GPT4_CA==1]))
  print(paste("missing :",missing,"; too much :", too_much))
  precision = round(length(which(matrix_GPT4_CA[matrix_GS==1] ==1)) / length(which(matrix_GPT4_CA==1)),2)
  recall =round(length(which(matrix_GPT4_CA[matrix_GS==1] ==1)) / (length(which(matrix_GS==1))),2)
  print(paste("28/35 : precision =",precision,"; recall =",recall))
  
}

print_results()

