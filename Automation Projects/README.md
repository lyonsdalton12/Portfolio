**Project:** 3rd-Party Vendor ETL Pipeline
**Domain:** Data Engineering, API Integration, Automation  
**Languages/Tools:** Python, T-SQL, Windows Batch, Postman/Newman, JavaScript

**Overview**
This repository contains a robust, end-to-end ETL (Extract, Transform, Load) pipeline that automates the retrieval of student life session data from a third-party vendor system, transforms it according to internal business logic, and loads it securely into our institution's internal servers. 

**The Problem**
Our institution lacked a native integration to retrieve critical student life session information (Housing, Meal Plans, and Occupancy) from a newly adopted 3rd-party vendor. As a result, staff across multiple departments were forced to rely on manual data synchronization. This created a massive administrative bottleneck, introduced high rates of human error, and resulted in unreliable data for reporting and operations.

**The Solution**
I engineered a fully automated ETL pipeline to create a structured, virtually zero-touch data flow. Triggered automatically via Windows Task Scheduler, the pipeline handles complex API pagination, orchestrates data extraction, sanitizes the payload, and performs bulk database inserts—completely eliminating the need for manual oversight.

**Tech Stack**
* **Extraction:** Postman / Newman CLI, JavaScript (Dynamic API Pagination)
* **Orchestration:** Windows Command Line (Batch Scripting)
* **Transformation:** Python (JSON, Datetime, Collections)
* **Loading:** SQL Server (T-SQL) via pyodbc

---

**Pipeline Architecture**

1. **Data Extraction** (Postman & Newman)
The extraction phase utilizes a collection of authenticated GET requests to pull data from specific vendor endpoints.
* **Dynamic Pagination:** Engineered JavaScript Pre-request and Post-response scripts to dynamically evaluate API responses for "next page" URLs. The collection safely loops through endpoints, concatenating records into array variables until all data is retrieved.
* **Session Management:** The final output is configured to generate a comprehensive JSON report of the Newman execution, safely capturing all requested data for the transformation phase.

2. **Orchestration & Automation** (Windows Batch)
A centralized batch script (run_pipeline.bat) acts as the automated controller for the workflow.
* **CLI Integration:** The script programmatically executes the Postman collection via the Newman CLI.
* **Strict Error Handling:** Execution is validated at every step. If the API pull fails or the JSON output file is missing, the script halts immediately and throws a designated error code to prevent malformed data from reaching the database.
* **Seamless Handoff:** Upon successful data extraction, the batch script triggers the Python environment to begin transformation.

3. **Transformation & Load** (Python)
The final stage (load_to_sql.py) parses the Newman JSON report, applies necessary business logic, and pushes the data to the local SQL environment.
* **Data Filtering:** Actively parses the raw JSON array and sanitizes the dataset by dropping invalid or expired student records (e.g., evaluating if a student's end_date has already passed).
* **Data Enrichment:** Valid students are logically grouped using a composite key (building_id + room_id). The script iterates through these groups to assign a unique, sequential room_slot_id to each student for database normalization.
* **High-Performance Database Load:** Establishes a secure connection via pyodbc, resets the temporary staging tables, and utilizes executemany for a highly efficient bulk insert of the enriched records.

---

**Security & Configuration**
Security was a top priority when designing this architecture. 
* **Zero Hardcoded Credentials:** All configuration parameters, database credentials, and API keys are strictly separated from the codebase.
* **Environment Variables:** Secrets are dynamically pulled at runtime via OS-level environment variables, which are locked behind administrative safeguards.
* **Encrypted Backups:** Configuration states are backed up using encryption on both the local hosting machine and secure cloud storage.

---
*Note: All logic in this repository has been carefully sanitized of personalized and proprietary assets for demonstration purposes. AI assistance was utilized periodically for code documentation, formatting standardization, and exception logic refinement.*