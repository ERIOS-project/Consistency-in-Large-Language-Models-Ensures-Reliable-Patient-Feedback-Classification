# Checkk if the active directory is "Experience 6". This code define cateegories and feedback(verbatims) identification key
getwd()
library(xlsx)

# store the categories names :
category = c(
  "La fluidité et la personnalisation du parcours",
  "L’accueil et l’admission",
  "Le circuit administratif" ,
  "La rapidité de prise en charge et le temps d’attente" ,
  "L’accès au bloc" ,
  "La sortie de l’établissement" ,
  "Le suivi du patient après le séjour hospitalier" ,
  "Les frais supplémentaires et dépassements d’honoraires" ,
  "L’information et les explications" ,
  "L’humanité et la disponibilité des professionnels" ,
  "Les prises en charges médicales et paramédicales", 
  "Gestion de la douleur et médicaments" ,
  "Maternité et pédiatrie" ,
  "L’accès à l’établissement" ,
  "Les locaux et les chambres" ,
  "L’intimité" ,
  "Le calme/volume sonore" ,
  "La température de la chambre" ,
  "Les repas et collations" ,
  "Les services WiFi et TV",
  "Droits des patients"
)
category.en = c(
  "Fluidity and personalization of the care pathway",
  "Reception and admission",
  "Administrative process",
  "Speed of care and waiting time",
  "Access to the operating room",
  "Discharge from the facility",
  "Follow-up care after hospital stay",
  "Additional costs and extra fees",
  "Information and explanations",
  "Humanity and availability of professionals",
  "Medical and paramedical care",
  "Pain management and medication",
  "Maternity and pediatrics",
  "Access to the facility",
  "Facilities and rooms",
  "Privacy",
  "Calm/noise level",
  "Room temperature",
  "Meals and snacks",
  "WiFi and TV services",
  "Patient rights"
)

tone = c("positive","negative")


index = readRDS("data/sample/index.rds")
matrixGS = readRDS("data/gold_standard/matrixGS.rds")
