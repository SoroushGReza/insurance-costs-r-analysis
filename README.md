# Insurance Costs R Analysis

Detta projekt är en individuell inlämningsuppgift i R-programmering för dataanalys.

Syftet är att analysera vilka faktorer som verkar hänga ihop med försäkringskostnader och att bygga en regressionsmodell där `charges` används som målvariabel.

## Dataset

Datasetet heter:

```text
insurance_costs.csv
```

Filen ligger i mappen:

```text
data/insurance_costs.csv
```

Datasetet innehåller information om bland annat:

* ålder
* kön
* region
* BMI
* antal barn
* rökning
* kronisk sjukdom
* motionsnivå
* försäkringsplan
* tidigare olyckor
* tidigare claims
* hälsokontroller
* försäkringskostnad (`charges`)

## Projektstruktur

```text
insurance-costs-r-analysis/
│
├── data/
│   └── insurance_costs.csv
│
├── figures/
│   ├── figure1_charges_histogram.png
│   ├── figure2_charges_by_smoker.png
│   ├── figure3_bmi_and_charges.png
│   ├── figure4_charges_by_age_group.png
│   ├── figure5_model_diagnostics.png
│   └── figure6_actual_vs_predicted.png
│
├── analysis_insurance_costs.R
├── report.md
├── README.md
├── .gitignore
└── insurance-costs-r-analysis.Rproj
```

## Filer

* `analysis_insurance_costs.R` innehåller kod för inläsning, datastädning, beskrivande analys, visualiseringar och regressionsanalys.
* `report.md` innehåller den skriftliga rapporten.
* `figures/` innehåller figurer som skapas från analysen.
* `data/insurance_costs.csv` innehåller datasetet.

## Paket

Analysen använder endast base R. Därför behöver inga extra R-paket installeras.

## Så körs analysen

1. Öppna projektet i RStudio genom att öppna filen:

```text
insurance-costs-r-analysis.Rproj
```

2. Kontrollera att datasetet ligger i:

```text
data/insurance_costs.csv
```

3. Öppna filen:

```text
analysis_insurance_costs.R
```

4. Kör hela filen i RStudio genom att markera all kod och trycka:

```text
Ctrl + A
Ctrl + Enter
```

5. Resultat visas i Console och figurer sparas i mappen:

```text
figures/
```

## Kort sammanfattning

Analysen visar att försäkringskostnader verkar hänga ihop med flera faktorer, särskilt rökning, kronisk sjukdom, ålder, BMI, försäkringsplan och tidigare historik.

En multipel linjär regressionsmodell används för att undersöka sambanden mellan dessa variabler och `charges`.
