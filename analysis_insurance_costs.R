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

# ------------------------------------------------------------
# 5. Datastädning och förberedelse
# ------------------------------------------------------------

# Jag skapar en kopia av originaldatan så att jag inte ändrar direkt i
# den ursprungliga versionen.
insurance_clean <- insurance

# ------------------------------------------------------------
# 5.1 Städa kategoriska variabler
# ------------------------------------------------------------

# Vissa kategoriska variabler hade extra mellanslag och olika stora/små
# bokstäver. Därför gör jag texten konsekvent med trimws() och tolower().

insurance_clean$sex <- tolower(trimws(insurance_clean$sex))
insurance_clean$region <- tolower(trimws(insurance_clean$region))
insurance_clean$smoker <- tolower(trimws(insurance_clean$smoker))
insurance_clean$chronic_condition <- tolower(trimws(insurance_clean$chronic_condition))
insurance_clean$exercise_level <- tolower(trimws(insurance_clean$exercise_level))
insurance_clean$plan_type <- tolower(trimws(insurance_clean$plan_type))

# Kontroll efter städning
table(insurance_clean$region)
table(insurance_clean$smoker)
table(insurance_clean$plan_type)

# Tolkning:
# Efter städningen bör samma kategori inte längre finnas i flera varianter,
# till exempel "North" och "north" eller "basic" och "basic ".

# ------------------------------------------------------------
# 5.2 Hantera saknade värden
# ------------------------------------------------------------

# Jag ersätter saknade värden i bmi med medianen.
# Medianen är rimlig här eftersom den inte påverkas lika mycket av extrema
# värden som medelvärdet.

median_bmi <- median(insurance_clean$bmi, na.rm = TRUE)
insurance_clean$bmi[is.na(insurance_clean$bmi)] <- median_bmi

# Jag ersätter saknade värden i annual_checkups med medianen.
median_checkups <- median(insurance_clean$annual_checkups, na.rm = TRUE)
insurance_clean$annual_checkups[is.na(insurance_clean$annual_checkups)] <- median_checkups

# För exercise_level skapar jag kategorin "unknown" där värden saknas.
# Jag gör inte en gissning om kundens motionsnivå, utan markerar att
# informationen saknas.

insurance_clean$exercise_level[is.na(insurance_clean$exercise_level)] <- "unknown"

# Kontrollera att saknade värden är hanterade
colSums(is.na(insurance_clean))

# ------------------------------------------------------------
# 5.3 Kontrollera och ändra datatyper
# ------------------------------------------------------------

# Kategoriska variabler görs om till factor eftersom de beskriver grupper.
insurance_clean$sex <- as.factor(insurance_clean$sex)
insurance_clean$region <- as.factor(insurance_clean$region)
insurance_clean$smoker <- as.factor(insurance_clean$smoker)
insurance_clean$chronic_condition <- as.factor(insurance_clean$chronic_condition)
insurance_clean$exercise_level <- as.factor(insurance_clean$exercise_level)
insurance_clean$plan_type <- as.factor(insurance_clean$plan_type)

# Kontrollera strukturen efter städning
str(insurance_clean)

# ------------------------------------------------------------
# 5.4 Skapa nya variabler
# ------------------------------------------------------------

# Jag skapar en åldersgrupp eftersom det kan vara lättare att jämföra
# försäkringskostnader mellan olika åldersgrupper.

insurance_clean$age_group <- cut(
  insurance_clean$age,
  breaks = c(0, 30, 45, 60, 100),
  labels = c("18-30", "31-45", "46-60", "61+"),
  right = TRUE
)

# Jag skapar en BMI-kategori eftersom BMI ofta tolkas i grupper.
insurance_clean$bmi_category <- cut(
  insurance_clean$bmi,
  breaks = c(0, 18.5, 25, 30, 100),
  labels = c("underweight", "normal", "overweight", "obese"),
  right = FALSE
)

# Jag skapar också en enkel historikvariabel genom att lägga ihop tidigare
# olyckor och tidigare claims. Det kan vara relevant eftersom tidigare
# historik kan hänga ihop med högre försäkringskostnader.

insurance_clean$history_score <- insurance_clean$prior_accidents + insurance_clean$prior_claims

# Jag grupperar historiken för att kunna jämföra kunder enklare.
insurance_clean$history_group <- ifelse(
  insurance_clean$history_score == 0,
  "none",
  ifelse(insurance_clean$history_score <= 2, "low", "high")
)

insurance_clean$history_group <- as.factor(insurance_clean$history_group)

# Kontrollera de nya variablerna
table(insurance_clean$age_group)
table(insurance_clean$bmi_category)
table(insurance_clean$history_group)

# Tolkning:
# De nya variablerna gör det lättare att jämföra grupper i den beskrivande
# analysen. De är inte nödvändiga för alla modeller, men de hjälper mig att
# förstå datat bättre.