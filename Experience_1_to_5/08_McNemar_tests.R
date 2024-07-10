#This code provides p-values to measure classifications differences between humans and GPT4 +/-CA  models 


matrix_GS = readRDS("data/gold_standard/matrix_GS.rds")
matrix_GPT4_CA = readRDS("data/GPT4/matrix_GPT4_CA.rds")
matrix_GPT4_standalone = readRDS("data/GPT4/matrix_GPT4_standalone.rds")
matrix_humans = readRDS("data/humans/matrix_humans.rds")


#GPT-4 standalone vs humans
contingent_table = table(as.vector(matrix_humans),as.vector(matrix_GPT4_standalone))
mcnemar.test(contingent_table)


#GPT-4 +EC vs humans
matrix_GPT4_CA = readRDS("matrix_GPT4_CA.rds")
matrix_GPT4_CA[matrix_GPT4_CA>=24/35] = 1
matrix_GPT4_CA[matrix_GPT4_CA!=1] = 0
contingent_table = table(as.vector(matrix_humans),as.vector(matrix_GPT4_CA))
mcnemar.test(contingent_table)

#GPT-4 +IC vs humans
matrix_GPT4_CA = readRDS("matrix_GPT4_CA.rds")
matrix_GPT4_CA[matrix_GPT4_CA==16/35 | matrix_GPT4_CA>=28/35] = 1
matrix_GPT4_CA[matrix_GPT4_CA!=1] = 0
contingent_table = table(as.vector(matrix_humans),as.vector(matrix_GPT4_CA))
mcnemar.test(contingent_table)


#GPT-4 +CA vs humans
matrix_GPT4_CA = readRDS("matrix_GPT4_CA.rds")
matrix_GPT4_CA[matrix_GPT4_CA>=28/35] = 1
matrix_GPT4_CA[matrix_GPT4_CA!=1] = 0
contingent_table = table(as.vector(matrix_humans),as.vector(matrix_GPT4_CA))
mcnemar.test(contingent_table)
