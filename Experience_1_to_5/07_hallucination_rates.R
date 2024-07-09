# This code evaluates hallucination rates for GPT4, GPT4+ICA, GPT4+ECA and GPT4+GCA


# import data
matrix_GS = readRDS("data/gold_standard/matrix_GS.rds")
matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4_CA.rds")
matrix_GPT4_standalone = readRDS("data/GPT4/matrix_GPT4_standalone.rds")

# Store the possible agents
agent = c("1","2","3")
# Create the array squeleton
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


#GPT 4 alone
library(xlsx)
hallucination_check = read.xlsx("data/GPT4/GPT4_standalone_hallucinations_check.xlsx",sheetIndex = 1)

# establish wich error has been made by which agent.
agent1 = vector()
agent2 = vector()
agent3 = vector()
current_id = 0
current_agent = 1
for(i in 1:dim(hallucination_check)[1]){
  if(is.na(hallucination_check$id[i]))next
  print(current_id)
  if(as.numeric(hallucination_check$id[i]) < current_id){
    current_agent = current_agent+1
  }
  current_id = as.numeric(hallucination_check$id[i])
  if(current_agent ==1)agent1 = append(agent1,i)
  if(current_agent ==2)agent2 = append(agent2,i)
  if(current_agent ==3)agent3 = append(agent3,i)
}


hallucination_rate.GPT41 = round(sum(hallucination_check$hallucination[agent1])/length(which(matrix_GPT4_standalone[,,,1]==1)),2)
hallucination_rate.GPT42 = round(sum(hallucination_check$hallucination[agent2])/length(which(matrix_GPT4_standalone[,,,2]==1)),2)
hallucination_rate.GPT43 = round(sum(hallucination_check$hallucination[agent3])/length(which(matrix_GPT4_standalone[,,,3]==1)),2)
print(paste("GPTs alone :",hallucination_rate.GPT41,hallucination_rate.GPT42,hallucination_rate.GPT43,"; mean =",mean(c(hallucination_rate.GPT41,hallucination_rate.GPT42,hallucination_rate.GPT43))))



#GPT 4 + CA
library(xlsx)
hallucination_check = read.xlsx("data/GPT4/GPT4_PIC_hallucinations_check.xlsx",sheetIndex = 1)

agent = 1:6
# establish wich error has been made by which agent.
agent_id = list(agent1 = vector(),agent2 = vector(),agent3 = vector(),agent4 = vector(),agent5 = vector(),agent6 = vector())

current_id = 0
current_agent = 1
for(i in 1:dim(hallucination_check)[1]){
  if(is.na(hallucination_check$id[i]))next
  if(as.numeric(hallucination_check$id[i]) < current_id){
    current_agent = current_agent+1
  }
  current_id = as.numeric(hallucination_check$id[i])
  agent_id[[current_agent]] = c(agent_id[[current_agent]], i)
}

#GPT4+ECA
hallucinations_count = 0
for(i in 1:dim(matrix_GPT4_CA)[1]){
  for(current_category in category){
    for(current_tone in 1:2){
      for(current_slice in (1:3)){
        if(matrix_GPT4_CA[i,current_category,current_tone,current_slice]>=(24/35) & matrix_GS[i,current_category,current_tone]==0){
          current_agents_id =c(agent_id[[2*current_slice]], agent_id[[2*current_slice-1]]) 
          current_dataset= hallucination_check[current_agents_id,]
          current_hallucinations = current_dataset$hallucination[which(current_dataset$id == i & current_dataset$category == current_category & current_dataset$tone ==c("+","-")[current_tone])]
          if(sum(na.omit(as.numeric(current_hallucinations))) ==2)hallucinations_count = 1 + hallucinations_count
        }
      }
    }
  }
}

print(paste("GPT4+ECA mean =",hallucinations_count/length(which(matrix_GPT4_CA>=(24/35)))))#GPT4+ICA

# GPT4+ ICA
hallucinations_count = 0
for(i in 1:dim(matrix_GPT4_CA)[1]){
  for(current_category in category){
    for(current_tone in 1:2){
      for(current_slice in (1:3)){
        if((matrix_GPT4_CA[i,current_category,current_tone,current_slice]==(16/35) | matrix_GPT4_CA[i,current_category,current_tone,current_slice]>=(28/35))& matrix_GS[i,current_category,current_tone]==0){
          current_agents_id =c(agent_id[[2*current_slice]], agent_id[[2*current_slice-1]]) 
          current_dataset= hallucination_check[current_agents_id,]
          current_hallucinations = current_dataset$hallucination[which(current_dataset$id == i & current_dataset$category == current_category & current_dataset$tone ==c("+","-")[current_tone])]
          if(sum(na.omit(as.numeric(current_hallucinations))) == 2){
            print(i)
            print(current_slice)
            print(current_category)
            print(c("+","-")[current_tone])
            hallucinations_count = 1 + hallucinations_count
          }
        }
      }
    }
  }
}

print(paste("GPT4+ICA mean =",hallucinations_count/length(which(matrix_GPT4_CA>=(24/35)))))


# GPT4+ GCA
hallucinations_count = 0
for(i in 1:dim(matrix_GPT4_CA)[1]){
  for(current_category in category){
    for(current_tone in 1:2){
      for(current_slice in (1:3)){
        if((matrix_GPT4_CA[i,current_category,current_tone,current_slice]>=(28/35) )& matrix_GS[i,current_category,current_tone]==0){
          current_agents_id =c(agent_id[[2*current_slice]], agent_id[[2*current_slice-1]]) 
          current_dataset= hallucination_check[current_agents_id,]
          current_hallucinations = current_dataset$hallucination[which(current_dataset$id == i & current_dataset$category == current_category & current_dataset$tone ==c("+","-")[current_tone])]
          if(sum(na.omit(as.numeric(current_hallucinations))) == 2){
            print(i)
            print(current_slice)
            print(current_category)
            print(c("+","-")[current_tone])
            hallucinations_count = 1 + hallucinations_count
          }
        }
      }
    }
  }
}

print(paste("GPT4+GCA mean =",hallucinations_count/length(which(matrix_GPT4_CA>=(24/35)))))

