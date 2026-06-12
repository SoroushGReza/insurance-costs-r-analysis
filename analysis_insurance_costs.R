# Individuell inlämningsuppgift - R-programmering för dataanalys
# Case: Försäkringskostnader
#
# I den här analysen undersöker jag vilka faktorer som verkar hänga ihop
# med försäkringskostnader. Målvariabeln är charges.

# ------------------------------------------------------------
# 1. Läsa in datasetet
# ------------------------------------------------------------

insurance <- read.csv("data/insurance_costs.csv", stringsAsFactors = FALSE)

# Visa de första raderna
head(insurance)

# Kontrollera antal rader och kolumner
dim(insurance)

# Kontrollera struktur och datatyper
str(insurance)

# ------------------------------------------------------------
# 2. Undersöka saknade värden
# ------------------------------------------------------------

missing_values <- colSums(is.na(insurance))
missing_values

# Jag ser här om några variabler har saknade värden.
# Det behöver jag veta innan jag går vidare med analysen.

# ------------------------------------------------------------
# 3. Kontrollera kategoriska variabler
# ------------------------------------------------------------

table(insurance$sex)
table(insurance$region)
table(insurance$smoker)
table(insurance$chronic_condition)
table(insurance$exercise_level)
table(insurance$plan_type)

# Här kontrollerar jag om kategoriska variabler innehåller inkonsekvenser,
# till exempel extra mellanslag eller olika stora och små bokstäver.

# ------------------------------------------------------------
# 4. Sammanfattning av datat
# ------------------------------------------------------------

summary(insurance)

# Sammanfattningen ger en första bild av datat, till exempel minsta värde,
# största värde, median och medelvärde för numeriska variabler.