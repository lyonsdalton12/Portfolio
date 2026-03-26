/*Title: IT_TEMP_SQLScripts 
Owner: IT Department
Last Reviewed: 03-26-2026
Status: Active
Sensitivity Level: Level 1: Public / Internal General
Scope: 
	The purpose of this template is to create a standardized way to format our SQL scripts. (CTRL + CLICK HERE FOR QUICK COPY/PASTE SQL SCRIPT TEMPLATE)
*/


--Example Template: 
/*
 * Script Name: YEAR 2024-2025 UNDERGRADUATE ADMISSIONS
 * ORIGINAL AUTHOR: Dalton Lyons
 * LAST UPDATED BY: Dalton Lyons
 * LAST UPDATED DATE: 03/13/2026
 * PURPOSE: To provide a comprehensive report for the IPEDS ACT Reporting requirements.
 * SAFEGUARDS:   Student ID Data must be masked for submission.
 * ADDITONAL COMMENTS: Not ALL students will be covered in this script; we need to go over everything with our administrative to ensure accuracy.
   Ensure you change variable declarations as needed. Multiple versions of this script should be available inside of the Shared Example/Directory
 */

/* =============================================
   CONFIGURATION SECTION
   ============================================= */
--Variable Declarations:

DECLARE @Year_cde VARCHAR(10) = '2024';
DECLARE @Begin_date VARCHAR(10) = '2024-07-01';
DECLARE @End_date VARCHAR(10) = '2025-06-30';
DECLARE @Div_cde VARCHAR(10) = 'UG';
--DECLARE @ST_TUIT_AMT varchar(10) = 12347;--DOUBLE CHECK PLACEHOLDER AMOUNT PER YEAR

/*
	CHEAT SHEET FOR ST_TUIT_AMT
25-26 Tuition $12345
24-25 Tuition $12347
23-24 Tuition $12346
*/




-- Declaring Temp Tables
DECLARE @Example1 TABLE (Term VARCHAR(10));
INSERT INTO @Example1 (Term) VALUES ('x3'),('x2'),('x1');

DECLARE @Example2 TABLE (Chg_Fee VARCHAR(10));
INSERT INTO @Example2 (Chg_Fee) VALUES ('x1'),('x2'),('x3'),('x4')

DECLARE @Example3 (CAND_VAL varchar(10));
INSERT INTO @Example3 (CAND_VAL) VALUES ('x2'),('x1');

/* =============================================
   LOGIC SECTION
   ============================================= */



--Quick Copy Paste:


/*
*Script Name: ---ENTER HERE---
* ORIGINAL AUTHOR:       ---ENTER HERE---
* LAST UPDATED BY: ---ENTER HERE---
* LAST UPDATED DATE: ---ENTER HERE---
 * PURPOSE:      ---ENTER HERE---
 * SAFEGUARDS:   ---ENTER HERE---
 * ADDITONAL COMMENTS: ---ENTER HERE--- */
/* =============================================
   CONFIGURATION SECTION
   ============================================= */
--Variable Declarations:
DECLARE @Var1 VARCHAR(10) = '';
DECLARE @Var2 VARCHAR(10) = '';

-- Declaring Temp Tables
DECLARE @Example TABLE (ExVar1 VARCHAR(10));
INSERT INTO @Example (ExVar1) VALUES ('x1'), ('x2'), ('x3');

/* =============================================
   LOGIC SECTION
   ============================================= */

-- SECTION 1. DESCRIPTION: ---ENTER HERE---

-- SECTION 2. DESCRIPTION: ---ENTER HERE---
