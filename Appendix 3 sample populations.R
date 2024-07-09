
# check the active directory is the main directory of the repository.
getwd()

# Select the table to display.
# Set to 1 to display the main sample tables
# Set to 2 to display the benchmark sample tables
table_to_display = 1


library(openxlsx)
# The index, R object vector containing all feedback identification keys must have been created prior to the following line (useful only for benchmark) 
index = readRDS("Experiences_6/data/sample/index.rds") 
# Import the meta data 
metadata1 = openxlsx::read.xlsx("Experiences_1_to_5/data/sample/metadonnees.xlsx")
metadata2 = openxlsx::read.xlsx("Experiences_6/data/sample/metadonnees.xlsx")

# extracting useful informations for sources tables : clinical wards and method of feedback obtention
library(table1)
if(table_to_display==1) data = metadata1[,c("Pole","Source")]
if(table_to_display==2) data = metadata2[,c("Pole","Source")]

# Adapting the wording to represent clinical ward than administrative poles
colnames(data) = c("Specialty","Source")
table(data$Specialty)
data$Specialty[data$Specialty=="BIOLOGIE-PATHOLOGIE"] = "Biology & anatomopathology"
data$Specialty[data$Specialty=="CLINIQUES MEDICALES"] = "Other medical specialties"
data$Specialty[data$Specialty=="CŒUR-POUMONS"]        = "Cardiology & pulmonology"
data$Specialty[data$Specialty=="DIGESTIF"]            = "Digestive"
data$Specialty[data$Specialty=="EMMBRUN"]             = "Other medical specialties"
data$Specialty[data$Specialty=="FME"]                 = "Pediatrics gynecology & obstetrics"
data$Specialty[data$Specialty=="GERONTOLOGIE"]        = "Gerontology"
data$Specialty[data$Specialty=="NSTC"]                = "Neurosciences, head and neck"
data$Specialty[data$Specialty=="OS ET ARTICULATIONS"] = "Bones and joints"
data$Specialty[data$Specialty=="URGENCES"]            = "Emergencies"
data$Specialty[data$Specialty=="PSYCHIATRIE"]         = "Psychiatry"

# Convert to factor for display purpose

# Meaning of the terms :
# Other medical specialties : Dermatology, Pain, Hematology, Infectious diseases, Internal Medicine, Addictology, Vascular Diseases, Oncology & Palliative care,
# Endocrinology, Metabolic Diseases, Burns, Kidney, Urology & Nephrology


# Labelling
data$Specialty = factor(data$Specialty, levels=c("Neurosciences, head and neck","Cardiology & pulmonology","Bones and joints","Pediatrics gynecology & obstetrics","Digestive","Biology & anatomopathology","Gerontology","Emergencies","Other medical specialties" ))
label(data$Specialty)="Medical Specialty"
data$Source[data$Source=="e-satis MCO 48H"] = "Acute care >48h"
data$Source[data$Source=="e-satis MCOCA"] = "Outpatient surgery"
data$Source[data$Source=="e-satis SSR"] = "Follow-up care and rehabilitation"
data$Source[data$Source=="CHU de Montpellier - Registre Réclamation"] = "Reclamations"
data$Source[data$Source=="CHU de Montpellier - Satisfaction Restauration"] = "Hospital satisfaction forms"
data$Source[data$Source=="CHU Montpellier - Satisfaction patient HC-HS"] = "Hospital satisfaction forms"
data$Source[data$Source=="CHU Montpellier - Satisfaction patient PSY"] = "Hospital satisfaction forms"
data$Source[data$Source=="CHU Montpellier - Satisfaction UCAA"] = "Hospital satisfaction forms"
data$Source[data$Source=="e-satis MCO48H"] = "Acute care >48h"
label(data$Source)  = "Source"
data$Source = factor(data$Source, levels = c("Acute care >48h","Outpatient surgery","Follow-up care and rehabilitation", "Hospital satisfaction forms","Reclamations"))


#Print the source table (metadatas)
table1(~ Specialty  | Source, data=data)


# Import the Gold standard to display the table of classifications of reference

if(table_to_display==1)matrixGS =  readRDS("Experience_1_to_5/data/gold_standard/matrix_GS.rds")
if(table_to_display==2)matrixGS =  readRDS("Experience_6/data/gold_standard/matrix_GS.rds")

# Construct the table empty skeleton
GS_data = data.frame(row.names = 1:(length(category)*length(tone)),
                     category = rep(category,each=length(tone)),
                     tone = rep(tone, times = length(category)),
                     effective = NA
                     )
# Compute the table
for(i in 1:dim(GS_data)[1]){
  current_category= GS_data[i,1]
  current_tone = GS_data[i,2]
  GS_data$effective[i] = sum(matrixGS[,current_category,current_tone])
}

# Transform the table in flat format
GS_data.flat = data.frame(
  Category = rep(GS_data$category, times=GS_data$effective),
  Tone = rep(GS_data$tone, times=GS_data$effective)
)
GS_data.flat$Tone = factor(GS_data.flat$Tone, levels = tone)
for(i in 1:length(category)){
  GS_data.flat$Category[GS_data.flat$Category==category[i]] = category.en[i]
}
GS_data.flat$Category = factor(GS_data.flat$Category, levels = category.en)


#Sort the table by decreasing order
GS_data.flat$Category = factor(GS_data.flat$Category, levels = names(sort(table(GS_data.flat$Category), decreasing = T)))

# Print the table
table1(data = GS_data.flat, ~  Category|Tone)

