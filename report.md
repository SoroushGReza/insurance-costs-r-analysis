# Rapport: Försäkringskostnader – analys i R

## Syfte

Syftet med den här uppgiften var att analysera vilka faktorer som verkar hänga ihop med försäkringskostnader. Datasetet innehåller information om kunder, till exempel ålder, kön, region, BMI, antal barn, rökning, kronisk sjukdom, motionsnivå, försäkringsplan, tidigare olyckor, tidigare claims, hälsokontroller och försäkringskostnad.

Målvariabeln i analysen var `charges`, eftersom den visar försäkringskostnaden. Målet var att först förstå och städa datat, sedan göra en beskrivande analys och till sist bygga en regressionsmodell.

## Metod

Jag började med att läsa in datasetet i R med `read.csv()`. Därefter undersökte jag datats storlek, struktur och variabeltyper med bland annat `dim()`, `str()` och `summary()`.

Datasetet innehöll 1100 rader och 14 kolumner. Det fanns både numeriska variabler och kategoriska variabler. Exempel på numeriska variabler var `age`, `bmi`, `children`, `prior_accidents`, `prior_claims`, `annual_checkups` och `charges`. Exempel på kategoriska variabler var `sex`, `region`, `smoker`, `chronic_condition`, `exercise_level` och `plan_type`.

Jag kontrollerade också saknade värden med `colSums(is.na())`. Det fanns saknade värden i `bmi`, `exercise_level` och `annual_checkups`. Saknade värden i `bmi` och `annual_checkups` ersattes med medianen. För `exercise_level` skapade jag kategorin `unknown`, eftersom jag inte ville gissa kundens motionsnivå.

Jag städade också kategoriska variabler genom att ta bort extra mellanslag och göra texten konsekvent med små bokstäver. Detta behövdes eftersom vissa kategorier fanns i flera varianter, till exempel olika stavning eller extra mellanslag.

Jag skapade även nya variabler:

* `age_group`, för att kunna jämföra försäkringskostnader mellan olika åldersgrupper.
* `bmi_category`, eftersom BMI ofta tolkas i kategorier.
* `history_score`, där tidigare olyckor och tidigare claims lades ihop.
* `history_group`, för att kunna jämföra kunder med ingen, låg eller hög tidigare historik.

Dessa variabler skapades för att göra den beskrivande analysen tydligare och lättare att tolka.

## Beskrivande analys

I den beskrivande analysen undersökte jag hur `charges` var fördelad och vilka variabler som verkade intressanta att analysera vidare.

Sammanfattningen av `charges` visade att försäkringskostnaderna varierade mycket mellan kunder. Det lägsta värdet var ungefär 1203,51 och det högsta värdet var ungefär 32559,28. Medelvärdet var ungefär 10060,49 och medianen var ungefär 9124,31. Att maxvärdet var mycket högre än medianen visar att vissa kunder hade betydligt högre kostnader än de flesta andra.

Histogrammet över `charges` visade att många kunder hade lägre eller medelhöga kostnader, medan färre kunder hade mycket höga kostnader. Det betyder att fördelningen inte var helt jämn.

När jag jämförde rökare och icke-rökare såg jag en tydlig skillnad. Icke-rökare hade en genomsnittlig kostnad på ungefär 8585,89, medan rökare hade en genomsnittlig kostnad på ungefär 16537,15. Detta gjorde `smoker` till en viktig variabel att undersöka vidare i regressionsmodellen.

Jag såg också att kunder med kronisk sjukdom hade högre kostnader än kunder utan kronisk sjukdom. Kunder utan kronisk sjukdom hade en genomsnittlig kostnad på ungefär 8928,97, medan kunder med kronisk sjukdom hade en genomsnittlig kostnad på ungefär 13573,25.

Försäkringsplanen verkade också spela roll. Basic-planen hade lägst genomsnittlig kostnad, standard låg högre och premium hade högst genomsnittlig kostnad. Detta är rimligt eftersom olika försäkringsplaner kan vara kopplade till olika kostnadsnivåer.

Ålder och BMI verkade också ha samband med `charges`. Äldre åldersgrupper hade i genomsnitt högre kostnader än yngre grupper, och kunder med högre BMI hade ofta högre kostnader än kunder med lägre BMI.

## Regressionsanalys

Jag byggde en multipel linjär regressionsmodell med `charges` som målvariabel. Modellen innehöll följande prediktorer:

* `age`
* `bmi`
* `smoker`
* `chronic_condition`
* `exercise_level`
* `plan_type`
* `prior_accidents`
* `prior_claims`

Jag valde dessa variabler eftersom de är relevanta utifrån uppgiftens case och eftersom den beskrivande analysen visade att flera av dem verkade ha samband med försäkringskostnader.

Modellen visade att flera variabler hade tydliga samband med `charges`. Rökning var en av de starkaste faktorerna. I modellen hade rökare betydligt högre förväntade försäkringskostnader än icke-rökare, när övriga variabler hölls konstanta.

Kronisk sjukdom hade också ett tydligt positivt samband med `charges`. Det innebär att kunder med kronisk sjukdom i modellen hade högre förväntade kostnader än kunder utan kronisk sjukdom.

Även ålder och BMI hade positiva samband med `charges`. Det betyder att högre ålder och högre BMI var kopplade till högre förväntade försäkringskostnader i modellen.

Tidigare olyckor och tidigare claims hade också positiva samband med `charges`. Det är rimligt eftersom tidigare historik kan säga något om risk och framtida kostnader.

Försäkringsplanen spelade också roll. Premium-planen hade högre förväntade kostnader än basic-planen. Även standard-planen låg högre än basic.

Modellens R-squared var ungefär 0,746. Det betyder att modellen förklarade ungefär 74,6 procent av variationen i `charges`. Det är en relativt hög förklaringsgrad för en enkel multipel linjär regressionsmodell.

## Slutsatser

Analysen visar att flera faktorer verkar hänga ihop med försäkringskostnader. De tydligaste faktorerna var:

* rökning
* kronisk sjukdom
* ålder
* BMI
* försäkringsplan
* tidigare olyckor
* tidigare claims

Rökning och kronisk sjukdom verkade ha särskilt starka samband med högre kostnader. Detta verkar rimligt eftersom dessa faktorer kan vara kopplade till högre hälsorisk. Även tidigare historik, som olyckor och claims, var relevant eftersom tidigare händelser kan säga något om risknivå.

Regressionsmodellen kan användas som ett stöd för att förstå vilka variabler som påverkar kostnader mest. Däremot bör den inte användas ensam som beslutsunderlag för prissättning.

## Begränsningar

Det finns flera begränsningar i analysen. För det första är modellen linjär, vilket betyder att den kanske inte fångar mer komplicerade samband mellan variablerna. För det andra visar modellen samband, men den bevisar inte automatiskt orsakssamband.

En annan begränsning är att vissa saknade värden behövde hanteras. Jag ersatte saknade numeriska värden med medianen och skapade kategorin `unknown` för saknad motionsnivå. Det är rimliga metoder, men de kan ändå påverka resultatet.

Det kan också finnas andra viktiga faktorer som påverkar försäkringskostnader, men som inte finns med i datasetet. Exempel kan vara mer detaljerad sjukdomshistorik, inkomst, yrke eller andra riskfaktorer.

## Självreflektion

Jag tycker att jag gjorde bra ifrån mig genom att arbeta strukturerat från början till slut. Jag började med att förstå datat, sedan städade jag variablerna, skapade nya relevanta variabler, gjorde tabeller och figurer och byggde till sist en regressionsmodell.

Det svåraste var att tolka regressionsmodellen, särskilt eftersom flera variabler ingår samtidigt. Jag behövde tänka på att koefficienterna visar samband när de andra variablerna i modellen också ingår.

Jag tycker att inlämningen motsvarar G, eftersom jag har uppfyllt kraven på att läsa in och undersöka data, städa datasetet, skapa relevanta nya variabler, göra statistiska sammanfattningar och vissualiseringar, bygga en regressionsmodell och tolka resultatet.

Jag tycker också att arbetet kan närma sig VG-nivå eftersom jag har gjort en hel analysprocess och även diskuterat modellens styrkor, svagheter och begränsningar.
Men jag vet att jag inte kan få VG då jag lämnar in som "Omprövning". 