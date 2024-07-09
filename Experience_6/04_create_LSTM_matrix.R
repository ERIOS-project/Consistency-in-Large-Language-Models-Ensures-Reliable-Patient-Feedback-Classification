#This code trains and evaluates Long short term memory in a 10 fold cross validation.

# Create the array squeleton for the classification
matrix_LSTM = array(data=NA, dim=c(
  length(index),
  length(category),
  length(tone)
), 
dimnames = list(index,category,tone))


# Create a vector of preprocessed verbatims from the previous analysis
verbatims = corpus$content

library(dplyr)
library(keras)
library(tensorflow)

# Set seed for reproducibility
set.seed(456)

# Tokenize the text
tokenizer <- text_tokenizer()
fit_text_tokenizer(tokenizer, verbatims)
# Convert the text to sequences
sequences <- texts_to_sequences(tokenizer, verbatims)
# Pad sequences to ensure equal length
verbatims =  pad_sequences(sequences)
# Verbatims is now a matrix representing the sequence of each verbatim
# Its dim are 1170 rows (one for each verbatim), 
# for 158 columns (max length for any verbatim in this set)


# The 10-folds takes about 3 days on a i7 processor.

for(i in 1:ncol(folds)){
  print("-----------------------------------------------------------------------------------------------------")
  print(paste("Beginning fold",i))
  print("-----------------------------------------------------------------------------------------------------")
  current_fold = which(index %in% as.vector(na.omit(folds[,i])))
  other_folds = which(index %in% as.vector(na.omit(as.vector(folds[,-i]))))
  
  for(current_category in 1:length(category)){
    for(current_tone in 1:length(tone)){
      
      if(file.exists("data/LSTM/matrix_LSTM.rds")){
        matrix_LSTM = readRDS("data/LSTM/matrix_LSTM.rds")
      }
      
      print(paste("Beginning category",current_category,":",category[current_category], ",",tone[current_tone]))
            
      # Prepare the 1 million parameters model
      model = keras_model_sequential() %>%
        layer_embedding(input_dim = max(unlist(verbatims)) + 1, 
                        output_dim = 100, 
                        input_length = ncol(verbatims)) %>%
        layer_lstm(units = 100, return_sequences = TRUE) %>%
        layer_lstm(units = 100, return_sequences = TRUE) %>%
        # Adding two hidden LSTM layers
        layer_lstm(units = 50, return_sequences = TRUE) %>%
        layer_lstm(units = 50, return_sequences = FALSE) %>%
        # Output layer for binary classification
        layer_dense(units = 1, activation = 'sigmoid')
            
      suppressWarnings({
        # Compile the model
        model %>% compile(
          loss = 'binary_crossentropy',
          optimizer = 'adam',
          metrics = c('accuracy'),
          run_eagerly = TRUE
        )
      })
       
      # Convert matrixGS to categorical labels
      target = matrixGS[,current_category,current_tone]
      
      if(length(table(target)) ==1){
        print(paste("warning : Gold standard has only 1 value for this current_category and current_tone :",category[current_category],tone[current_tone], ". 1's effectives =", length(which(matrixGS[other_folds,current_category,current_tone]==1))))        
        output = matrixGS[,current_category,current_tone]
      }else{
        
        class_weight = list(
          `0` = 1,        # For majority class
          `1` = 20        # Adjust this ratio based on the estimated prevalence (here 5% so 1/20) 
        )
              
        # Train the model
        history = model %>% keras::fit(
          x=verbatims[other_folds,], y=target[other_folds],
          epochs = 10,
          batch_size = 32,
          class_weight = class_weight
        )
              
        # Predict
        output = model %>% predict(verbatims[current_fold,])
      }
      matrix_LSTM[current_fold,current_category,current_tone] = output
      saveRDS(matrix_LSTM, "data/LSTM/matrix_LSTM.rds")
      
      # Save progress into a log in case of intercurrent issue.
      write.table(paste(Sys.time()," : current_fold :",i,"; current_category :",current_category,"; current_tone :",current_tone,"; done"),"data/LSTM/log.txt",append=TRUE)
    }
  }
}

