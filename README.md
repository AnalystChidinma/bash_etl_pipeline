# ETL Pipeline Project - using the Financial & Competitor (Parch & Posey) Datasets

## Overview

This project demonstrates a complete ETL (Extract, Transform, Load) pipeline using Bash scripting, PostgreSQL, and Linux automation.
The purpose of this project is to automate data ingestion, transformation, and loading processes using Linux commands, cron scheduling, and structured scripting practices.

The ETL pipeline is a practical exercise to understand how Bash scripts can be leveraged for end-to-end data operations.

## Project Objectives

  - Automate the ingestion of CSV datasets from external sources.

  - Transform raw data into a clean, structured format for analysis.

  - Load processed data into a PostgreSQL database.

  - Schedule and manage the pipeline execution using cron jobs.

  - Implement file handling and management using Bash scripting.

## Project Structure
- draw.io diagram showing the project Structure 
<img width="324" height="554" alt="image" src="https://github.com/user-attachments/assets/e07caf26-24bc-49d1-ae7c-b2766fc77fa7" />

## Tools used
- Linux - for Automation and scripting
- PostgreSQL - Database used for storing the Parch and posey data 
- Cron job - scheduling automated ETL runs
- Git and Github  - version control and documentation
- csv - for data cleaning and formating the financial dataset using (awk function)

## Dataset used for this Project
1. Annual Enterprise Survey financial dataset. source:[Downlaod here](https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv)
2. Parch & Posey dataset. Source:[Download here](https://github.com/tirthshah147/Parch-and-Posey-Database-for-SQL)

## Project Workflow
- ### ETL Process (Bash Only)
  - Extracted raw financial data from the Annual Enterprise Survey 2023 CSV file.
  - Applied data transformation using Bash :
      - Renamed columns.
      - Selected key attributes (year, value, units, variable_code).
      - Filtered data to include only records for 2023.
  - saved cleaned file as  **/finance_2023.csv**.
    
- ### Scheduling Cron Job (Automation)
  Configured a cron job to automatically execute the ETL pipeline daily at 12:30 AM.
  using this command ***crontab -e***
  
- ### File management Script
  To maintain an organized data flow, a file movement system was implemented through the **move_json_csv.sh script**.
    - Bash script was created that :
      - Moves all .csv and .json files from raw to **json_and_CSV** directory.
      - create a timestamped subfolder in the format: **json_and_CSV/YYYYMMDD_HHMMSS/**.
    - Generates a manifest.txt file containing:
      - Archive timestamp
      - Source and Destination directories
      - List of moved files
    - draw.io diagram showing the structure breakdown :  
      <img width="191" height="203" alt="image" src="https://github.com/user-attachments/assets/63e53e29-9345-409b-bde8-a72e61a9ee1f" />
      
- ### Competitor Data (Parch & Posey)
    This involved extracting, transforming, and loading the Parch & Posey dataset into PostgreSQL to simulate competitor analysis.
    - The Parch & Posey dataset was used to simulate competitor data analysis.
    - Data was stored in **data/parch_posey/**.
    - The dataset can later be used for comparative analytics or visualization in tools like Power BI or PostgreSQL queries.
         ## *HOW I CARRIED OUT THE PARCH & POSEY TASK*
  1. clone the parch & posey dataset git repo using git clone
  2. install your postgre inside the terminal using ***sudo apt install postgresql postgresql-contrib -y***
  3. Ensure your postgres is running locally
  4. create a database called ***posey_dec***
  5. navigate to the project directory using ***cd the project name***
  6. make your script executable using ***chmod +x the realpath of the script***
  7. run the ETL pipeline using  ***./scripts/bash/run_etl.sh***
  8. Successfully loaded the Parch & Posey dataset inside the database
       - accounts.csv
       - orders.csv
       - region.csv
       - sales_reps.csv
       - web_events.csv
         
## Key Takeaway
- Automated an end-to-end ETL pipeline using Bash and PostgreSQL.
- Implemented Cron Jobs for daily execution and pipeline scheduling.
- Practiced data transformation, logging, and idempotent load operations.
- Handled competitor dataset integration for analytical comparison.
- Strengthened Linux command-line proficiency and data pipeline orchestration skills.

## AUTHOR
# ***Chidinma Okeh***
# Data professional | Building Scalable Data Pipeline
[Linkedln Profile](https://www.linkedin.com/in/chidinma-okeh/)












