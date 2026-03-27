# CyberSecurity, DBA, Data Engineering & Automation Portfolio

**Welcome to my professional portfolio!** I am a Database Administrator with a passion for solving complex business problems through data automation, robust API integrations, and efficient ETL pipelines. I am currently transitioning into the CyberSecurity field actively applying security hardening & least privilage principles within a real live production environment.

This repository serves as a showcase of my technical skills, coding practices, and ability to design end-to-end data architectures with security in mind.

## Core Competencies
* **Languages:** Python, SQL (T-SQL), JavaScript, Windows Batch/PowerShell
* **Data Integration:** ETL/ELT Pipelines, RESTful APIs, Dynamic Pagination, Data Modeling, Intermediate Secrets Handling/CyberSecurity Principles.
* **Tools & Frameworks:** Postman/Newman, SQL Server, Pandas, Pyodbc, Windows System Tools
* **Practices:** Secure Credential Management, Automated Error Handling, Task Scheduling, Project Management Documentation

---

## Featured Project: 3rd-Party Vendor ETL Pipeline

**Directory:** Automation Projects

### Overview
Our institution lacked a native integration to retrieve critical student life session information from a third-party vendor's software. To solve this, I designed and developed a secure, automated ETL pipeline from scratch to extract this data, transform it according to our business rules, and load it into our internal databases all while maintaining idempotency principles.

### Tech Stack
* **Extraction:** Postman / Newman (API Interaction)
* **Orchestration:** Windows Batch Scripting & Task Scheduler
* **Transformation:** Python (JSON parsing, datetime logic, collection management)
* **Loading:** SQL Server (via pyodbc)

### Key Highlights
* **Dynamic API Pagination:** Developed JavaScript pre/post-request scripts within Postman to dynamically navigate and concatenate paginated API responses (Housing, Meal Plan, and Occupancy data), ensuring zero data loss.
* **Automated Data Transformation:** Built a Python script that actively sanitizes incoming JSON data. It drops expired student records based on end_date logic and enriches the data by generating unique sequential room_slot_ids based on composite keys (building_id + room_id).
* **High-Performance Database Loading:** Implemented executemany bulk insert techniques in Python to efficiently push transformed records to a local SQL Server staging environment.
* **Robust Orchestration & Error Handling:** Connected the entire workflow using Windows Batch scripting with strict error-level checking. If an API pull fails, the script safely halts execution to prevent bad data from reaching the database.


* **Security First:** Secret redaction of environment variables, API keys, and database credentials from the codebase, secured via administrative-level OS environment variables.
    **Security Implementation:**
      **Credential Isolation:** Utilized Windows OS-level environment variables to prevent cleartext exposure.
      **Input Sanitization:** Python-based logic to validate JSON schema before SQL injection-safe bulk loading.
      **Least Privilege:** Configured Task Scheduler to run via a dedicated Service Account with restricted filesystem and DB permissions.
      **Data Masking:** Utilized static data masking principles to ensure confidentiality.
      **HIPAA Compliance:** Ensured HIPAA compliance with all custodial assets.

---

## Repository Structure


Portfolio-main

 ┣  Automation Projects       # Contains the fully featured ETL Pipeline project
 
 ┃ ┣ PostmanCollection.js     # JavaScript logic for API pagination
 
 ┃ ┣ run_pipeline.bat         # Batch script orchestrating the workflow
 
 ┃ ┣ load_to_sql.py           # Python data transformation and SQL loading script
 
 ┃ ┗ README.md                # Detailed documentation for the ETL project
 
 ┣  ProjectManagement         # Highlights documentation/templates for implementing departmental standards
 
 ┃ ┣ Documentation Standards  # Standards for naming conventions, provisioning documents
 
 ┃ ┣ Play_Runbook Template    # Playbook/Runbook combo template
 
 ┃ ┣ README.md                # Detailed documentation concerning problem/solutions
 
 ┃ ┣ SQLTemplate.sql          # Comprehensive SQL template indicating minimal required information
 
 ┃ ┣ Security Levels          # Multi-level security scheme highlighting data integrity/security
 
 ┣ ComprehensiveReportProject # Contains a large time sensitive project led by myself & coordinated cross departmentally
 
 ┃ ┣ IPEDSACTREPORT.sql       # Massive & Dynamic SQL script for report requirements
 
 ┃ ┣ README.md                # Detailed documentation for goals/challenges of this project
 
 ┗  README.md                 # You are here!
