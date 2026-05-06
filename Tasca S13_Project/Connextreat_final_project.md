<div style="text-align:center; padding:24px; border-bottom:3px solid #1f77b4; font-family: 'Courier New'">
    <h1 style="margin-bottom:8px;">Connextreat - Connecting treatment across EU</h1>
    <p style="font-size:18px; margin:0;"><strong>Presenter:</strong> Alexei Levițchi</p>
    <p style="font-size:18px; margin:0;">PhD Genetics, data analyst</p>
</div>
<div style="text-align:center; padding:24px; border-bottom:3px solid #1f77b4; font-family: 'Courier New'">    
    <p style="font-size:18px; margin:0;"><strong>Mentor:</strong> Joan Gasull Jolis</p>
    <p style="font-size:15px; color:gray; margin-top:6px;">16 April 2026 · Barcelona</p>
</div>

![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/c92f745a0f533e42e7c89df15a494937e148d36f/Tasca%20S13_Project/Connextreat_problem_definition_small.png "Connextreat Logo")

## Problem 
Patients, clinicians, and support staff currently have to navigate multiple national portals, reimbursement rules, and insurer-specific exceptions. That creates a high-friction process that is especially difficult for chronic conditions (but not only), and other cases where continuous treatment matters and medicine access varies widely between EU countries.
Currently, EU citizens migrate frequently between European countries, which creates a burden to their health if a prescribed drug treatment is not available. National Health Insurance companies publish the lists of such drug treatments, but these services are not user-friendly, requiring extra skills and knowledge to identify and access the necessary information.

## Question
How can a citizen identify if prescribed drug treatment is available in another EU country when there are so many manufacturers, various drug names, variations in dosage and treatment rules for different health conditions?

One of the main nomenclatures applied is the so-called Anatomical Therapeutic Chemical Classification System, which uses ATC codes comprising several levels of definition, as exemplified below:
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/c92f745a0f533e42e7c89df15a494937e148d36f/Tasca%20S13_Project/atc_code_explained.png "atc_code definition")
[Fisher L, Wood C, MacKenna B. Classifying and measuring medicines usage with the ATC/DDD system. Bennett Institute for Applied Data Science, University of Oxford. 2025. https://www.bennett.ox.ac.uk/blog/2025/07/classifying-and-measuring-medicines-usage-with-the-atc/ddd-system/ doi:10.53764/oph.3t4q2llxbo
](https://www.bennett.ox.ac.uk/blog/2025/07/classifying-and-measuring-medicines-usage-with-the-atc/ddd-system/)

Thus, it ensures the link between anatomical part, therapeutic and chemical subgroups of the drug and it's active compound. Still, there are situations when the same drug is used in several health conditions, as shown in:
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/c92f745a0f533e42e7c89df15a494937e148d36f/Tasca%20S13_Project/atc_code_example_prednisolone_white.png "Multiple_atc_codes")
[Fisher L, Wood C, MacKenna B. Classifying and measuring medicines usage with the ATC/DDD system. Bennett Institute for Applied Data Science, University of Oxford. 2025. https://www.bennett.ox.ac.uk/blog/2025/07/classifying-and-measuring-medicines-usage-with-the-atc/ddd-system/ doi:10.53764/oph.3t4q2llxbo
](https://www.bennett.ox.ac.uk/blog/2025/07/classifying-and-measuring-medicines-usage-with-the-atc/ddd-system/)

So, the same drug has different ATC codes. In most of the cases, a citizen may know a drug's commercial name, or Latin name, the dose and for which condition it was prescribed. __But, definitely, not the ATC code!__

## Solution

### Goal
Design a proof-of-concept service for matching drug names between two countries

### Tasks
- [ ] Identify data sources of published drug lists in Moldova and Spain
- [ ] Implement ETL
- [ ] Analyse the data
- [ ] Build an MVP of drug matching service

### Infrastructure
#### Data sources
    - https://cnam.md
    - https://cima.aemps.es
    - https://www.sanidad.gob.es

#### Instruments
    - Python v 3.14.0
        * os
        * pandas
        * numpy
        * rapidfuzz
        * unidecode
        * re
        * warnings
        * circlify
        * matplotlib
        * pathlib
        * IPython
    - Python v 3.11
        * streamlit [streamlit.io]
        * supabase [https://supabase.com/]
        * dotenv

### Implementation
#### Data Extraction
Information on drugs, the national drug coding system, ATC codes, commercial names, treatments, health conditions and their coverage, manufacturers, and countries of drug production was available in the sources. The data were provided in downloadable .xls or .csv files. At the same time, https://www.sanidad.gob.es offers web-based access to information on drug treatment coverage by drug name, so scraping was implemented.
At this stage, it was necessary to clean column names of leading and trailing blank spaces. Data from the Moldavian national medical insurance company was split into several categories, and labels regarding patient type (is_child) and level of treatment coverage (coverage_type) were added.

#### Data Transformation
All records were cleaned for possible leading and trailing blank spaces, and work out empty records.
Two mapping dictionaries were applied:
    * to convert between different writings of 'yes'/'no' to Boolean True/False correspondingly,
    * to convert various notations of compensation availability to Boolean True/False.
Further, the tables were merged for each Country source. It was necessary to analyse the content in various columns to match the values. Several guiding columns were selected because no unique identifier was clearly determined from the extracted data. So, it was decided to refuse the implementation of the normalisation step at this stage.

#### Data Loading
Only fields relevant for drug names matching and information regarding coverage were used at this step.
The dataset from Moldova included 1467 records with the following description:
| # |  Column            |  Non-Null Count | Dtype |
|---|  ------            |  -------------- | ----- |
| 0 |  dci_code          |  1265 non-null  | object|
| 1 |  dci_name          |  1467 non-null  | object|
| 2 |  dci_code_sec      |  591 non-null   | object|
| 3 |  dci_name_sec      |  41 non-null    | object|
| 4 |  dc_code_prim      |  1265 non-null  | object|
| 5 |  dc_code_sec       |  590 non-null   | object|
| 6 |  dc_name           |  1467 non-null  | object|
| 7 |  atc_code          |  1467 non-null   | object|
| 8 |  coverage_level    |  1467 non-null   | object|
| 9 |  disease_group     |  1467 non-null  | object|
| 10|  manufacturer_name |  1467 non-null  | object|
| 11|  manufacturer_label|  1467 non-null   | object|
| 12|  country           |  1467 non-null  | object|
| 13|  is_covered        |  1467 non-null  | bool |

where:
* _dci_ - is an international commercial name (INN)
* _dc_ - is a commercial name (may vary between countries)
* _ _prim_ and _ _sec_ - mark alternatives of INNs and commercial names noted only in this dataset
* _atc_code_ - is the code assigned to a drug according to ATC nomenclature
* _coverage_level_ - shows whether insurance cover **Full** or **Partial** the costs of a drug treatment
* _disease_group_ - characterises the health condition for which the drug is described.
* _manufacturer_name_ - name of the pharma company providing the drug
* _manufacturer_label_ - is used to label different departments or branches of a manufacturer
* _country_ - is the country of drug production or distribution
* _is_covered_ - is a Boolean True/False marking whether a drug is covered or not by national health insurance.
____
The dataset from Spain included 52735 records with the following description:
| # |  Column            |  Non-Null Count | Dtype |
|---|  ------            |  -------------- | ----- |
| 0 |  national_code     |  50737 non-null | object|
| 1 |  atc_code          | 52735 non-null  | object|
| 2 |  is_covered        |  19451 non-null | object|
| 3 |  dci_name          |  52735 non-null | object|
| 4 |  nr_act_compounds  |  52735 non-null | object|
| 5 |  dc_name           |  52735 non-null | object|
| 6 |  manufacturer_name |  52735 non-null | object|
| 7 |  manufacturer_label|  52735 non-null | object|
| 8 |  country           |  52703 non-null | object|

where:
* _national_code_ - is the code assigned to a drug according to the Spanish nomenclature
* _atc_code_ - is the code assigned to a drug according to ATC nomenclature
* _is_covered_ - is a Boolean True/False marking whether a drug is covered or not by national health insurance
* _dci_ - is an international commercial name (INN)
* _nr_act_compounds_ - shows the number of active compounds included in the drug
* _dc_ - is a commercial name (may vary between countries)
* _manufacturer_name_ - name of the pharma company providing the drug
* _manufacturer_label_ - is used to label different departments or branches of a manufacturer
* _country_ - is the country of drug production or distribution

#### Fuzzy matching
The major identified difficulty was related to the compound's Latin name in the Moldavian dataset, while those in the dataset from Spain were in Spanish. A set of rules was elaborated:
* "acidum": "acido",
* "acetylcysteinum": "acetilcisteina",
* "amiodaronum": "amiodarona",
* "acidum valproicum": "acido valproico",
* "acidum valproicum": "valproico acido",
* "cysteinum$": "cisteina"
* "acetyl": "acetil"
* "onum$": "ona",
* "inum$": "ina",
* "ium$": "io",
* "icum$": "ico",
* "um$": "o".

Such normalisation allows an increase in the fuzzy matching score. Still, due to a low score, the algorithm may return a null, so an ATC code check was also implemented. In case no corresponding drug name or ATC code was identified, the algorithm returns a corresponding message.
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/c92f745a0f533e42e7c89df15a494937e148d36f/Tasca%20S13_Project/fuzzy_matching_scheme.png "fuzzy matching scheme")

If the result is multiple, the first identified result is used for the purpose of MVP testing. Thus, 1396 drugs from 1467 in the Moldavian dataset were identified.
| match_status |	count |
|--------------|--------|
| atc_exact_best_score |	1396 |
| no_candidates	| 69 |
| atc_prefix_best_score |	2 |

So, a mapping rate of __> 95 %__ was achieved.

Next, the top 10 countries of drug manufacturers providing their products in Moldova and Spain were identified
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/c92f745a0f533e42e7c89df15a494937e148d36f/Tasca%20S13_Project/reporting/top10_moldova_spain_drug_origins.png "Top10 manufacturers")

Two countries, Germany and Slovenia, sell drugs covered by national insurance in both Moldova and Spain. 

At the same time, each country has a very different level of drug production.
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/c92f745a0f533e42e7c89df15a494937e148d36f/Tasca%20S13_Project/reporting/shared_drugs.png "Country drug production")

Clustering analysis of the ATC codes (level 1) defining major health conditions in Spanish dataset revelead the majority of these drugs were from "Nervous system" group (5518 units), "Cardiovascular" group (3287 units) and a mixt group of "Antiinfectives", "Alimentary tract", "Blood" and "Antineoplastic" entities (1927, 1908, 1895, and 1695 units, correspondingly).
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/c92f745a0f533e42e7c89df15a494937e148d36f/Tasca%20S13_Project/reporting/atc_l1_country_heatmaps/es_atc_l1_clustered_heatmap.png "Number of drugs by Health condition ES")

A similar approach for the Moldavian dataset identified that the majority of these drugs were from "Cardiovascular" and "Musculoskeletal" groups (258 and 257 units, respectively), followed by the "Nervous system" group (226 units).
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/c92f745a0f533e42e7c89df15a494937e148d36f/Tasca%20S13_Project/reporting/atc_l1_country_heatmaps/md_atc_l1_clustered_heatmap.png "Number of drugs by Health condition MD")

__Drugs attributed to the "Nervous system" and "Cardiovascular" groups were prevalent in both countries.__

#### MVP
The *user* is a person from Moldova who checks the availability of a drug treatment for a chronic condition in Spain and whether the treatment is covered by national health insurance.
The service was developed using Streamlit and Supabase. It is called __Drug Treatment Coverage Checker__ and is located at (https://connextreat.streamlit.app/).
At this stage, the interface represents a simple combination of 4 fields to be filled in:
- Enter drug name (DCI)
- Your age
- Country of origin or Ethnicity
- Your sex by birth
- 
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/be8ed68a02c972158acd0bc535504952366946e0/Tasca%20S13_Project/connextreat_interface.PNG "ConnexTreat interface")

There are four scenarios implemented:
* "❌ Drug not found in matching database" - no drug name was found in the Spanish dataset.
* "⚠️ No coverage information found" - the drug was identified in the Spanish dataset, but it is not clear if it is covered or not by the national health insurance.
* "✅ Equivalent treatment is available and covered by insurance" - the drug was identified in the Spanish dataset, and confirmation of the coverage by the national health insurance is available.
* "⚠️ A similar treatment might not be available right now. Consult your family doctor." - the drug was identified in the Spanish dataset, and confirmation of lack of coverage by the national health insurance is available.


<table style="border: none; border-collapse: collapse;">
  <tr style="border: none;">
    <td style="border: none;" valign="top"><img src="https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/be8ed68a02c972158acd0bc535504952366946e0/Tasca%20S13_Project/connextreat_search.PNG" width="100%"></td>
    <td style="border: none;" valign="top"><img src="https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/be8ed68a02c972158acd0bc535504952366946e0/Tasca%20S13_Project/connextreat_result.PNG" width="100%"></td>
  </tr>
</table>

__Drug Treatment Coverage Checker__ uses two tables stored on Supabase to perform matching and checking treatment availability
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/3f77adfffb6c43a970f8630f34a353ce6280f395/Tasca%20S13_Project/supabase_connextreat.PNG "ConnexTreat Supabase")
<img src="https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/3f77adfffb6c43a970f8630f34a353ce6280f395/Tasca%20S13_Project/supabase_connextreat.PNG" width="100%">

The service is collecting a log of users' search and stores it for further analysis for the purpose of user experience and demands determination, as well as users' stratification parameters.
![alt text](https://github.com/LEValexSci/Data_Analytics_2025-2026/blob/be8ed68a02c972158acd0bc535504952366946e0/Tasca%20S13_Project/supabase_connextreat_log.PNG "ConnexTreat log")