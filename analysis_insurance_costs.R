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
insurance_clean$exercise_level <- factor(
  insurance_clean$exercise_level,
  levels = c("high", "medium", "low", "unknown")
)

insurance_clean$plan_type <- factor(
  insurance_clean$plan_type,
  levels = c("basic", "standard", "premium")
)

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

# ------------------------------------------------------------
# 6. Beskrivande analys
# ------------------------------------------------------------

# I den här delen undersöker jag hur försäkringskostnaderna är fördelade
# och vilka variabler som verkar intressanta att analysera vidare.

# Jag skapar en mapp för figurer om den inte redan finns.
if (!dir.exists("figures")) {
  dir.create("figures")
}

# ------------------------------------------------------------
# 6.1 Sammanfattning av försäkringskostnader
# ------------------------------------------------------------

charges_summary <- c(
  antal = length(insurance_clean$charges),
  min = min(insurance_clean$charges),
  median = median(insurance_clean$charges),
  mean = mean(insurance_clean$charges),
  sd = sd(insurance_clean$charges),
  max = max(insurance_clean$charges)
)

round(charges_summary, 2)

# Tolkning:
# Den här sammanfattningen visar hur försäkringskostnaderna är fördelade.
# Jag tittar särskilt på medelvärde, median och maxvärde för att se om det
# finns kunder med mycket höga kostnader.

# ------------------------------------------------------------
# 6.2 Figur 1: Fördelning av charges
# ------------------------------------------------------------

png("figures/figure1_charges_histogram.png")

hist(
  insurance_clean$charges,
  main = "Fördelning av försäkringskostnader",
  xlab = "Charges",
  ylab = "Antal kunder",
  col = "lightblue",
  border = "white"
)

dev.off()

# Tolkning:
# Figuren visar att många kunder har lägre eller medelhöga kostnader,
# medan färre kunder har mycket höga kostnader. Det tyder på att charges
# inte är helt jämnt fördelad.

# ------------------------------------------------------------
# 6.3 Tabell 1: Charges efter rökning
# ------------------------------------------------------------

smoker_table <- data.frame(
  smoker = names(table(insurance_clean$smoker)),
  antal = as.numeric(table(insurance_clean$smoker)),
  mean_charges = as.numeric(tapply(insurance_clean$charges, insurance_clean$smoker, mean)),
  median_charges = as.numeric(tapply(insurance_clean$charges, insurance_clean$smoker, median))
)

smoker_table$mean_charges <- round(smoker_table$mean_charges, 2)
smoker_table$median_charges <- round(smoker_table$median_charges, 2)

smoker_table

# Tolkning:
# Tabellen jämför försäkringskostnader mellan rökare och icke-rökare.
# Om rökare har högre medelvärde och median är smoker en intressant
# variabel att ta med i regressionsmodellen.

# ------------------------------------------------------------
# 6.4 Figur 2: Charges efter rökning
# ------------------------------------------------------------

png("figures/figure2_charges_by_smoker.png")

boxplot(
  charges ~ smoker,
  data = insurance_clean,
  main = "Försäkringskostnader efter rökning",
  xlab = "Rökare",
  ylab = "Charges",
  col = "lightgreen"
)

# Tolkning:
# Boxploten gör det lättare att se skillnader mellan grupperna.
# Om gruppen rökare ligger högre än icke-rökare tyder det på att rökning
# kan ha ett tydligt samband med högre försäkringskostnader.

# ------------------------------------------------------------
# 6.5 Tabell 2: Charges efter kronisk sjukdom
# ------------------------------------------------------------

chronic_table <- data.frame(
  chronic_condition = names(table(insurance_clean$chronic_condition)),
  antal = as.numeric(table(insurance_clean$chronic_condition)),
  mean_charges = as.numeric(tapply(insurance_clean$charges, insurance_clean$chronic_condition, mean)),
  median_charges = as.numeric(tapply(insurance_clean$charges, insurance_clean$chronic_condition, median))
)

chronic_table$mean_charges <- round(chronic_table$mean_charges, 2)
chronic_table$median_charges <- round(chronic_table$median_charges, 2)

chronic_table

# Tolkning:
# Tabellen visar om kunder med kronisk sjukdom har högre kostnader än kunder
# utan kronisk sjukdom. Detta är relevant eftersom hälsorelaterade faktorer
# kan påverka försäkringskostnader.

# ------------------------------------------------------------
# 6.6 Figur 3: BMI och charges
# ------------------------------------------------------------

png("figures/figure3_bmi_and_charges.png")

plot(
  insurance_clean$bmi,
  insurance_clean$charges,
  main = "Samband mellan BMI och försäkringskostnader",
  xlab = "BMI",
  ylab = "Charges",
  pch = 19,
  col = "darkgray"
)

dev.off()

plot(
  insurance_clean$bmi,
  insurance_clean$charges,
  main = "Samband mellan BMI och försäkringskostnader",
  xlab = "BMI",
  ylab = "Charges",
  pch = 19,
  col = "darkgray"
)

# Tolkning:
# Figuren visar om det finns ett samband mellan BMI och försäkringskostnader.
# Om punkterna tenderar att ligga högre vid högre BMI kan BMI vara en
# relevant variabel i regressionsmodellen.

# ------------------------------------------------------------
# 6.7 Tabell 3: Charges efter försäkringsplan
# ------------------------------------------------------------

plan_table <- data.frame(
  plan_type = names(table(insurance_clean$plan_type)),
  antal = as.numeric(table(insurance_clean$plan_type)),
  mean_charges = as.numeric(tapply(insurance_clean$charges, insurance_clean$plan_type, mean)),
  median_charges = as.numeric(tapply(insurance_clean$charges, insurance_clean$plan_type, median))
)

plan_table$mean_charges <- round(plan_table$mean_charges, 2)
plan_table$median_charges <- round(plan_table$median_charges, 2)

plan_table

# Tolkning:
# Tabellen visar om försäkringskostnaderna skiljer sig mellan olika
# försäkringsplaner. Det är rimligt att plan_type undersöks eftersom olika
# planer kan vara kopplade till olika nivåer av kostnad.

# ------------------------------------------------------------
# 6.8 Figur 4: Charges efter åldersgrupp
# ------------------------------------------------------------

png("figures/figure4_charges_by_age_group.png")

boxplot(
  charges ~ age_group,
  data = insurance_clean,
  main = "Försäkringskostnader efter åldersgrupp",
  xlab = "Åldersgrupp",
  ylab = "Charges",
  col = "lightyellow"
)

dev.off()

boxplot(
  charges ~ age_group,
  data = insurance_clean,
  main = "Försäkringskostnader efter åldersgrupp",
  xlab = "Åldersgrupp",
  ylab = "Charges",
  col = "lightyellow"
)

# Tolkning:
# Figuren visar om försäkringskostnaderna skiljer sig mellan åldersgrupper.
# Om äldre grupper har högre kostnader är age en viktig variabel att ta med
# i regressionsmodellen.

# ------------------------------------------------------------
# 6.9 Korrelation mellan numeriska variabler och charges
# ------------------------------------------------------------

cor_age_charges <- cor(insurance_clean$age, insurance_clean$charges)
cor_bmi_charges <- cor(insurance_clean$bmi, insurance_clean$charges)
cor_accidents_charges <- cor(insurance_clean$prior_accidents, insurance_clean$charges)
cor_claims_charges <- cor(insurance_clean$prior_claims, insurance_clean$charges)

correlations <- c(
  age = cor_age_charges,
  bmi = cor_bmi_charges,
  prior_accidents = cor_accidents_charges,
  prior_claims = cor_claims_charges
)

round(correlations, 3)

# Tolkning:
# Korrelationerna visar enkla samband mellan numeriska variabler och charges.
# Detta är inte samma sak som regression, men det hjälper mig att välja
# vilka variabler som verkar intressanta att undersöka vidare.

# ------------------------------------------------------------
# 7. Regressionsanalys
# ------------------------------------------------------------

# I den här delen bygger jag en regressionsmodell där chargess är målvariable.
# Jag använder multipel linjär regression eftersom jag vill undersöka flera
# faktorer samtiddigt.

# Jag väljer prediktorer som verkar rimliga utifrån uppgiften och den
# beskrivande analysen:
# - age: äldre kunder kan ha högre kostnader
# - bmi: högre BMI kan hänga ihop med högre kostnader
# - smoker: rökning verkar ha tydligt samband med charges
# - chronic_condition: kronisk sjukdom kan påverka kostnader
# - exercise_level: motionsnivå kan vara kopplad till hälsa och risk
# - plan_type: olika försäkringsplaner kan ha olika kostnadsnivåer
# - prior_accidents och prior_claims: tidigare historik kan påverka kostnader

model_1 <- lm(
  charges ~ age + bmi + smoker + chronic_condition + exercise_level +
    plan_type + prior_accidents + prior_claims,
  data = insurance_clean
)

# Visa resultattet från regressionsmodellen
summary(model_1)

# Tolkning:
# I summary(model_1) tittar jag framför allt på koefficienter, p-värden
# och R-squared.
#
# Koefficienterna visar hur mycket charges förväntas ändras när en variabel
# ökar eller när en kategori jämförs med referenskategorin.
#
# P-värden används för att se vilka variabler som verkar ha ett tydligt
# samband med charges i modellen.
#
# R-squared visar hur stor del av variationen i charges som modellen
# förklarar.

# ------------------------------------------------------------
# 7.1 Spara viktiga modellmått
# ------------------------------------------------------------

model_summary <- summary(model_1)

r_squared <- model_summary$r.squared
adjusted_r_squared <- model_summary$adj.r.squared

r_squared
adjusted_r_squared

# Tolkning:
# R-squared visar modellens förklaringsgrad. Adjusted R-squared är också
# viktig eftersom den tar hänsyn till att modellen har flera prediktorer.

# ------------------------------------------------------------
# 7.2 Konfidensintervall för modellen
# ------------------------------------------------------------

confint(model_1)

# Tolkning:
# Konfidensintervallen visar osäkerheten runt koefficienterna.
# Om ett intervall inte innehåller 0 kan det tyda på att variabeln har ett
# tydligare samband med charges.

# ------------------------------------------------------------
# 7.3 Modellgranskning med residualer
# ------------------------------------------------------------

# Jag granskar modellen med hjälp av residualplottar.
# Detta gör jag för att se om modellen verkar rimlig och om det finns
# mönster som modellen inte fångar.

png("figures/figure5_model_diagnostics.png", width = 1200, height = 900)

par(mfrow = c(2, 2), mar = c(4, 4, 3, 2))
plot(model_1)

dev.off()

par(mfrow = c(1, 1))

# Tolkning:
# Residualplottarna används för att bedöma om modellen fungerar rimligt.
# Om residualerna visar tydliga mönster kan det betyda att modellen inte
# fångar alla samband i datat. Detta är en begränsning med modellen.

# ------------------------------------------------------------
# 7.4 Enkel jämförelse mellan verkliga och förutsagda värden
# ------------------------------------------------------------

insurance_clean$predicted_charges <- predict(model_1, newdata = insurance_clean)

head(insurance_clean[, c("charges", "predicted_charges")])

# Jag tar bort rader där predicted_charges saknas, så att figuren kan skapas.
prediction_data <- insurance_clean[!is.na(insurance_clean$predicted_charges), ]

# Jag skapar en figur som jämför verkliga charges med modellens förutsagda
# värden.

png("figures/figure6_actual_vs_predicted.png")

plot(
  prediction_data$charges,
  prediction_data$predicted_charges,
  main = "Verkliga och förutsagda försäkringskostnader",
  xlab = "Verkliga charges",
  ylab = "Förutsagda charges",
  pch = 19,
  col = "darkgray"
)

abline(0, 1, col = "red", lwd = 2)

dev.off()


# Tolkning:
# Om punkterna ligger nära den röda linjen betyder det att modellen gör
# ganska bra förutsägelser. Om punkterna ligger långt från linjen betyder
# det att modellen har svårt att förutsäga vissa kunders kostnader.

# ------------------------------------------------------------
# 7.5 Slutsats från regressionsmodellen
# ------------------------------------------------------------

# Regressionsmodellen hjälper mig att undersöka vilka variabler som verkar
# ha tydligast samband med charges när flera faktorer kontrolleras samtidigt.
#
# Jag kommer använda resultatet från summary(model_1) i rapporten för att
# diskutera vilka variabler som verkar viktigast och vilka begränsningar
# modellen har.

# ------------------------------------------------------------
# 8. Sammanfattande slutsatser
# ------------------------------------------------------------

# I den här analysen har jag först undersökt datasetets struktur, saknade
# värden och kategoriska variabler. Därefter städade jag datat genom att
# hantera saknade värden, rätta till textvärden och skapa nya variabler.

# Den beskrivande analysen visade att försäkringskostnaderna varierar mycket
# mellan olika kunder. Vissa kunder har betydligt högre kostnader än andra.
# Detta syntes särskilt i histogrammet över charges.

# Utifrån tabeller och figurer verkar rökning, kronisk sjukdom, BMI,
# ålder, försäkringsplan och tidigare historik vara intressanta faktorer
# att undersöka vidare.

# Regressionsmodellen användes för att undersöka flera variabler samtidigt.
# Resultatet från modellen visar vilka faktorer som har tydligast samband
# med charges när andra variabler också ingår i modellen.

# De faktorer som verkar vara särskilt viktiga att diskutera i rapporten är:
# - rökning
# - kronisk sjukdom
# - ålder
# - BMI
# - försäkringsplan
# - tidigare olyckor och tidigare claims

# Modellen kan användas som ett stöd för att förstå vilka faktorer som hänger
# ihop med högre försäkringskostnader. Däremot bör modellen inte ses som en
# perfekt förutsägelsemodell. Den bygger på historiska data och fångar inte
# alla faktorer som kan påverka en kunds framtida kostnader.

# Begränsningar:
# - Modellen är linjär och kan missa mer komplicerade samband.
# - Det kan finnas andra viktiga variabler som inte finns med i datasetet.
# - Vissa saknade värden behövde ersättas, vilket kan påverka resultatet.
# - Modellen visar samband, men bevisar inte automatiskt orsakssamband.

# ------------------------------------------------------------
# 9. Självreflektion
# ------------------------------------------------------------

# Jag tycker att jag gjorde bra ifrån mig genom att arbeta steg för steg:
# först dataförståelse, sedan datastädning, beskrivande analys och till sist
# regressionsanalys. Jag har också försökt kommentera koden så att det går
# att följa hur analysen är gjord.

# Det svåraste var att tolka regressionsmodellen och förstå hur de olika
# variablerna påverkar charges när de ingår i samma modell.

# Jag tycker att inlämningen motsvarar G, eftersom jag har uppfyllt kraven
# på att läsa in data, undersöka och städa datasetet, skapa relevanta nya
# variabler, göra tabeller och figurer samt bygga och tolka en regressionsmodell.

# Jag tycker också att arbetet kan närma sig VG-nivå om rapporten tydligt
# diskuterar resultat, modellens begränsningar och varför valda variabler är
# relevanta för analysen.