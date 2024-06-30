Company Layoffs Data Cleaning and Standardization

Overview
This project involves cleaning and standardizing a dataset of company layoffs from 2022 (https://www.kaggle.com/datasets/swaptr/layoffs-2022). The goal is to prepare the data for analysis by removing duplicates, handling missing values, and ensuring consistency across all fields. The project demonstrates the use of SQL for data cleaning and transformation.

Dataset
The dataset used in this project is sourced from Kaggle: Layoffs 2022 (https://www.kaggle.com/datasets/swaptr/layoffs-2022). It contains information about layoffs from various companies, including the company name, location, industry, number of employees laid off, and other relevant details.

Steps
1. Remove Duplicates
Duplicates were identified and removed based on multiple columns such as company, location, industry, total laid off, percentage laid off, date, stage, country, and funds raised.

2. Standardize the Data
Standardization involved trimming whitespace, normalizing industry names, and converting date formats.

3. Handle Null or Blank Values
Null or blank values were addressed by setting default values, filling missing data from other records, or removing records with insufficient information.

4. Remove Unnecessary Columns
Columns that were not required for analysis were removed to streamline the dataset.
