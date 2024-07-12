categories = [
    "La fluidité et la personnalisation du parcours",
    "L’accueil et l’admission",
    "Le circuit administratif",
    "La rapidité de prise en charge et le temps d’attente",
    "L’accès au bloc",
    "La sortie de l’établissement",
    "Le suivi du patient après le séjour hospitalier",
    "Les frais supplémentaires et dépassements d’honoraires",
    "L’information et les explications",
    "L’humanité et la disponibilité des professionnels",
    "Les prises en charges médicales et paramédicales",
    "Gestion de la douleur et médicaments",
    "Maternité et pédiatrie",
    "L’accès à l’établissement",
    "Les locaux et les chambres",
    "L’intimité",
    "Le calme/volume sonore",
    "La température de la chambre",
    "Les repas et collations",
    "Les services WiFi et TV"
]
scores = {
   "class1": [],
   "class2": [],
   "syntax1": [],
   "syntax2": [],
   "element_accordance": [],
   "citation_accordance": [],
   "score_total": []
}
tone = ["positive", "negative"]
agent = ["LLM1", "LLM2"]
current_theme = "All_themes"
themes_and_categories = {
    "La fluidité et la personnalisation du parcours" : "Le circuit de prise en charge",
    "L’accueil et l’admission" : "Le circuit de prise en charge",
    "Le circuit administratif" : "Le circuit de prise en charge",
    "La rapidité de prise en charge et le temps d’attente" : "Le circuit de prise en charge",
    "L’accès au bloc" : "Le circuit de prise en charge",
    "La sortie de l’établissement" : "Le circuit de prise en charge",
    "Le suivi du patient après le séjour hospitalier" : "Le circuit de prise en charge",
    "Les frais supplémentaires et dépassements d’honoraires" : "Le circuit de prise en charge",
    "L’information et les explications" : "Le professionnalisme et la prise en charge médicale et paramédicale",
    "L’humanité et la disponibilité des professionnels" : "Le professionnalisme et la prise en charge médicale et paramédicale",
    "Les prises en charges médicales et paramédicales" : "Le professionnalisme et la prise en charge médicale et paramédicale",
    "Droits des patients" : "Le professionnalisme et la prise en charge médicale et paramédicale",
    "Gestion de la douleur et médicaments" : "Le professionnalisme et la prise en charge médicale et paramédicale",
    "Maternité et pédiatrie" : "Le professionnalisme et la prise en charge médicale et paramédicale",
    "L’accès à l’établissement" : "La qualité hôtelière",
    "Les locaux et les chambres" : "La qualité hôtelière",
    "L’intimité" : "La qualité hôtelière",
    "Le calme/volume sonore" : "La qualité hôtelière",
    "La température de la chambre" : "La qualité hôtelière",
    "Les repas et collations" : "La qualité hôtelière",
    "Les services WiFi et TV" : "La qualité hôtelière",
}
corrections = {    
"Les prises en charge médicales et paramédicales" : "Les prises en charges médicales et paramédicales",    
"Circuit administratif" : "Le circuit administratif",    
"Les frais supplémentaires et depassements d’honoraires" : "Les frais supplémentaires et dépassements d’honoraires",    
"Les frais supplementaires et depassements d’honoraires" : "Les frais supplémentaires et dépassements d’honoraires",    
"Le calme et volume sonore" : "Le calme/volume sonore",    
"La rapidite de prise en charge et le temps d’attente" : "La rapidité de prise en charge et le temps d’attente",    
"La sortie de l’etablissement" : "La sortie de l’établissement",    
"Le suivi du patient apres le sejour hospitalier" : "Le suivi du patient après le séjour hospitalier",    
"L’humanite et la disponibilite des professionnels" : "L’humanité et la disponibilité des professionnels"
}