#This code provides p-values to measure classifications differences between humans and GPT4 +/-CA  models 


matrix_GS = readRDS("matrix_GS.rds")
matrix_llmhf = readRDS("GPT4hf.rds")
matrix_llmsa = readRDS("matrixGPT4sa.rds")
matrix_humans = readRDS("matrix_humans.rds")


#GPT-4 standalone vs humans
contingent_table = table(as.vector(matrix_humans),as.vector(matrix_llmsa))
mcnemar.test(contingent_table)


#GPT-4 +EC vs humans
matrix_llmhf = readRDS("GPT4hf.rds")
matrix_llmhf[matrix_llmhf>=24/35] = 1
matrix_llmhf[matrix_llmhf!=1] = 0
contingent_table = table(as.vector(matrix_humans),as.vector(matrix_llmhf))
mcnemar.test(contingent_table)

#GPT-4 +IC vs humans
matrix_llmhf = readRDS("GPT4hf.rds")
matrix_llmhf[matrix_llmhf==16/35 | matrix_llmhf>=28/35] = 1
matrix_llmhf[matrix_llmhf!=1] = 0
contingent_table = table(as.vector(matrix_humans),as.vector(matrix_llmhf))
mcnemar.test(contingent_table)


#GPT-4 +CA vs humans
matrix_llmhf = readRDS("GPT4hf.rds")
matrix_llmhf[matrix_llmhf>=28/35] = 1
matrix_llmhf[matrix_llmhf!=1] = 0
contingent_table = table(as.vector(matrix_humans),as.vector(matrix_llmhf))
mcnemar.test(contingent_table)
