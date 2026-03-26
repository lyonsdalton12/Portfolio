/*
 * Script Name: YEAR 2024-2025 UNDERGRADUATE ADMISSIONS
 * ORIGINAL AUTHOR: [Author Name]
 * LAST UPDATED BY: [Author Name]
 * LAST UPDATED DATE: [Date]
 * PURPOSE: To provide a comprehensive report for the IPEDS ACT Reporting requirements.
 * SAFEGUARDS:  Student ID Data must be masked for submission.
 * ADDITONAL COMMENTS: Not ALL students will be covered in this script, we need to go over everything with our administrative to ensure accuracy.
   Ensure to change variable declarations as needed. Multiple versions of this script should be available inside of the Shared Google Drive under [Department] > [User Folder] > [Reports Folder].
 */

/* =============================================
   CONFIGURATION SECTION
   ============================================= */
--Variable Declarations:

DECLARE @Year_cde VARCHAR(10) = '2024';
DECLARE @Begin_date VARCHAR(10) = '2024-07-01';
DECLARE @End_date VARCHAR(10) = '2025-06-30';
DECLARE @Div_cde VARCHAR(10) = 'ExDiv1';
--DECLARE @ST_TUIT_AMT varchar(10) = [Tuition_Amount];--DOUBLE CHECK PLACEHOLDER AMOUNT PER YEAR

/*
	CHEAT SHEET FOR ST_TUIT_AMT
25-26 Tuition $[Amount]
24-25 Tuition $[Amount]
23-24 Tuition $[Amount]
22-23 Tuition $[Amount]
21-22 Tuition $[Amount]
20-21 Tuition $[Amount]
19-20 Tuition $[Amount]
*/


-- Declaring Temp Tables

DECLARE @Temp_Term_Cdes TABLE (Term VARCHAR(10));
INSERT INTO @Temp_Term_Cdes (Term) VALUES ('ExTerm1'),('ExTerm2'),('ExTerm3');

DECLARE @Charge_Fee_Cdes TABLE (Chg_Fee VARCHAR(10));
INSERT INTO @Charge_Fee_Cdes (Chg_Fee) VALUES ('ExChg1'),('ExChg2'),('ExChg3')

DECLARE @CAND_TYPE TABLE (CAND_VAL varchar(10));
INSERT INTO @CAND_TYPE (CAND_VAL) VALUES ('ExCand1'),('ExCand1');





/* =============================================
   LOGIC SECTION
   ============================================= */


--*****************************************CTE TABLES FOR NEED/NON-NEED BELOW**********************************************--

WITH AggregatedAwards AS (
    --Pre-aggregate the awards table down to ONE row per student year token
      SELECT 
        stu_award_year_token,
        SUM(CASE WHEN REPLACE(fund_name, ' ', '') = 'EXA3' THEN ISNULL(disbursed_amt,0) ELSE 0 END) AS total_va_tuition,
        SUM(CASE WHEN REPLACE(fund_name, ' ', '') = 'EXA4' THEN ISNULL(disbursed_amt,0) ELSE 0 END) AS total_fws_tuition,
        SUM(CASE WHEN REPLACE(fund_name, ' ', '') = 'EXA5' THEN ISNULL(disbursed_amt,0) ELSE 0 END) AS total_pell_amt,
		SUM(CASE WHEN REPLACE(fund_name, ' ', '') = 'EXA1' THEN ISNULL(disbursed_amt,0) ELSE 0 END) AS total_job_need_tuition,
		SUM(CASE WHEN REPLACE(fund_name, ' ', '') = 'EXA2' THEN ISNULL(disbursed_amt,0) ELSE 0 END) AS total_job_non_need_tuition
    FROM [finaid_db]dbo.ExampleStudentAwardTable1
    GROUP BY stu_award_year_token
),

ExampleStudentFulltimeTable1 AS (
    SELECT 
        id_num,
        ISNULL(SUM(TUITION_HRS), 0) AS total_hrs,
        -- If they have 6 or more hours, flag as 'F', otherwise 'P'
        CASE 
            WHEN ISNULL(SUM(TUITION_HRS), 0) >= 12 THEN 1 
            ELSE 0
        END AS ExampleStudentFulltimeTable1
    FROM ExampleStudentHistoryTable1
    WHERE trm_cde IN (SELECT term FROM @Temp_Term_Cdes) 
      AND CREDIT_TYPE_CDE = 'ExCt1' 
      AND YR_CDE = @Year_cde
    GROUP BY id_num
),

ExampleStudentEnrollTable1 AS (
    SELECT 
        id_num,
        MAX(CASE 
            WHEN ISNULL(stage,0) = 'Ex1' THEN 1 --For normal enrolled students
			WHEN ISNULL(stage,0) >= 'Ex2' then 2 --For those who were accepted at minimum.
            ELSE 0 --those who were never accepted/enrolled or are outside the scope of this enrollment period.
        END) AS ExampleStudentEnrollTable1
    FROM ExampleStudentCandidacy1
    WHERE trm_cde IN 
	--('ExTerm1','ExTerm2','ExTerm3')
	(SELECT term FROM @Temp_Term_Cdes) 
      AND DIV_CDE =  @Div_cde 
      AND YR_CDE =  @Year_cde

    GROUP BY id_num
),

BaseData AS (
    SELECT 
        aa.stu_award_year_token,
        v.original_need,
        b.tot_inst_funds_disb - total_job_non_need_tuition - total_job_need_tuition as tot_inst_funds_disb,
		total_fws_tuition,
		total_va_tuition,
		SFP.AGI AS S,
		SFPO.AGI AS SS,
		SFPF.AGI AS SSS,
		SFPOF.AGI AS SSSS,
		SFSF.AGI AS SSSSS,
		SFSSF.AGI AS SSSSSS,
		SFS.AGI AS SSSSSSS, 
		SFSS.AGI AS SSSSSSSS,
		SFS.dependency_status as DPSTS,
		SFS.married,
        total_job_non_need_tuition,
		total_job_need_tuition,
		ISNULL(SFS.AGI,0) + ISNULL(SFP.AGI,0) AS STUAGI,
        aa.total_pell_amt,
		isnull(sfs.data_valid,0) as data_valid
    FROM AggregatedAwards aa
    LEFT OUTER JOIN [finaid_db].dbo.dbo.ExampleView1 v ON v.stu_award_year_token = aa.stu_award_year_token
    LEFT OUTER JOIN [finaid_db].dbo.ExampleStudentFinSumTable1 b ON aa.stu_award_year_token = b.stu_award_year_token
	LEFT OUTER JOIN [finaid_db].DBO.dbo.ExampleStudentFinParTable2 SFP ON SFP.stu_award_year_token = aa.stu_award_year_token
	LEFT OUTER JOIN [finaid_db].DBO.dbo.ExampleStudentFinParOtherTable2 SFPO ON SFPO.stu_award_year_token = aa.stu_award_year_token
	LEFT OUTER JOIN [finaid_db].DBO.dbo.ExampleStudentFinParTable1 SFPF ON SFPF.stu_award_year_token = aa.stu_award_year_token
	LEFT OUTER JOIN [finaid_db].DBO.dbo.ExampleStudentFinParOtherTable1 SFPOF ON SFPOF.stu_award_year_token = aa.stu_award_year_token
	LEFT OUTER JOIN [finaid_db].DBO.ExampleStudentFinTable1_FTIM SFSF ON SFSF.stu_award_year_token = aa.stu_award_year_token
	LEFT OUTER JOIN [finaid_db].DBO.ExampleStudentFinTable1_SPOUSE_FTIM SFSSF ON SFSSF.stu_award_year_token = aa.stu_award_year_token
	LEFT OUTER JOIN [finaid_db].DBO.ExampleStudentFinTable1 SFS ON SFS.stu_award_year_token = aa.stu_award_year_token
	LEFT OUTER JOIN [finaid_db].DBO.ExampleStudentFinTable1_SPOUSE SFSS ON SFSS.stu_award_year_token = aa.stu_award_year_token
),

CalculatedVars AS (
    SELECT 
        stu_award_year_token,
        original_need,
        total_pell_amt,
        tot_inst_funds_disb,
        total_va_tuition,
		total_fws_tuition,
		STUAGI,
		total_job_non_need_tuition,
		total_job_need_tuition,
		data_valid,
        CASE 
			WHEN ISNULL(original_need,'0') = '0' then 0
            WHEN (original_need - total_pell_amt) < 0 THEN 0 
            ELSE (original_need - total_pell_amt) 
        END AS remaining_need,
		STUAGI AS FINAGI
    FROM BaseData
)


--*****************************************CTE TABLES FOR NEED/NON-NEED ABOVE**********************************************--

-- SECTION 1. DESCRIPTION: Selection statements, specific criteria is dependant on current IPEDS ACTS Criteria. Please check with Registrar office for updated Criteria.



SELECT 
--/////////////////////TEMPORARY VALUES FOR TESTING COMMENT OUT BEFORE PULLING FOR FINAL SUBMISSION/////////////////////////--

	-- a.id_num,
	-- nm.first_name,
	-- nm.last_name,

--/////////////////////TEMPORARY VALUES FOR TESTING COMMENT OUT BEFORE PULLING FOR FINAL SUBMISSION/////////////////////////--

	reverse(convert(char(6),a.id_num-900)) AS stu_id, 
	--Might need to change data mask per year to avoid upload flags of students being marked in multiple years.
	--2025 = 100
	--2024 = 900
	--2023 = 700
	--2022 = 200
	--2021 = 300
	--2020 = 500
	--2019 = 400

--***************************************************************************************--

	ISNULL(er.race_eth, -1) AS race_eth,

--***************************************************************************************--

	CASE 
		WHEN ISNULL(b.gender,-1) = 'M' THEN 0
		WHEN ISNULL(b.gender,-1) = 'F' THEN 1
		WHEN ISNULL(b.gender,-1) = 'T' THEN 0
		ELSE -1
	END AS sex,

--***************************************************************************************--

	CASE 
		WHEN ISNULL(es.ExampleStudentEnrollTable1,0) in ('1','2') then 1 
		else 0 
	end as adm_stat, --All accepted or higher stage students (Official offer letter) 1 else 0

--***************************************************************************************--

	3 AS adm_proc,

--***************************************************************************************--

	CASE 
		WHEN ISNULL(es.ExampleStudentEnrollTable1,0) = 1 THEN 1 --Enrolled students 1
		WHEN ISNULL(es.ExampleStudentEnrollTable1,0) = 2 THEN 0 --Non full time students 0
		ELSE -3
	end as enr_stat, 

--***************************************************************************************--

	CASE 
		WHEN ISNULL(es.ExampleStudentEnrollTable1,0) = 1 AND ISNULL(fps.ExampleStudentFulltimeTable1,0) = 1 THEN 1 --Students who were full time and enrolled 1
		WHEN ISNULL(es.ExampleStudentEnrollTable1,0) = 1 AND ISNULL(fps.ExampleStudentFulltimeTable1,0) = 0 THEN 0 --Students who were enrolled but only part-time 0
		ELSE -3
	END AS first_full, 

--***************************************************************************************--

    ISNULL(
		CASE
			WHEN ISNULL(es.ExampleStudentEnrollTable1,0) = 1 AND ISNULL(fps.ExampleStudentFulltimeTable1,0) = 1 THEN 1  -- Enrolled students that ARE full time 1
			ELSE -3 --Non degree seeking should fall here
		END, -3) AS ba_seek,

--***************************************************************************************--

    ISNULL(ra.sat_math, -1) AS sat_math, ISNULL(ra.sat_reading, -1) AS sat_read, ISNULL(ra.sat_comp, -1) AS sat_comp,

--***************************************************************************************--

    ISNULL(ra.act_math, -1) AS act_math, ISNULL(ra.act_english, -1) AS act_eng, ISNULL(ra.act_comp, -1) AS act_comp,

--***************************************************************************************--

    -1 AS secndry_gpa,

--***************************************************************************************--

     ISNULL(
		CASE
			WHEN NV.data_valid = 'N' THEN -1
			WHEN NV.data_valid = '0' THEN -1
			WHEN NV.FINAGI = -1 THEN -1
			WHEN NV.FINAGI < 0  THEN 1
			WHEN NV.FINAGI BETWEEN 0 and 30000 then 1
			WHEN NV.FINAGI BETWEEN 30001 and 58000 then 2
			WHEN NV.FINAGI BETWEEN 58001 and 94000 then 3
			WHEN NV.FINAGI BETWEEN 94001 and 153000 then 4
			WHEN NV.FINAGI >= 153001 then 5 
			ELSE -1
		END,-1) AS fam_incm,

--***************************************************************************************--

	ISNULL(
		CASE 
			WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3
            WHEN pfi.tot_grants_disb > 0 or 
			pfi.tot_private_funds_disb > 0 or 
			pfi.tot_private_grants_disb > 0 or 
			pfi.tot_loans_disb > 0 or 
			pfi.tot_state_funds_disb > 0 or 
			pfi.tot_inst_funds_disb > 0 or
			pfi.tot_other_disb > 0
			THEN 1
            WHEN pfi.tot_grants_disb <= 0 and 
			pfi.tot_private_funds_disb <= 0 and
			pfi.tot_private_grants_disb <= 0 and 
			pfi.tot_loans_disb <= 0 and 
			pfi.tot_state_funds_disb <= 0 and 
			pfi.tot_inst_funds_disb <= 0 and
			pfi.tot_other_disb <= 0
			THEN 0
            ELSE -1
		END,-1) as fa_stat,

--***************************************************************************************--

    ISNULL(
		CASE 
			WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3 --Students that are NOT enrolled OR NOT full time -3
			WHEN pd.fed_pell_grant_eligibility = 'Y'  THEN 1 --Enrolled students that are full time and ARE eligible for Pell grant 1
			WHEN pd.fed_pell_grant_eligibility = 'N'  THEN 0 --Enrolled students that are full time and are NOT eligible for Pell grant 0
	        WHEN nv.total_pell_amt > 0 then 1
			ELSE 0
		END, -1) AS pell_elig, 

--***************************************************************************************--

    ISNULL(
		CASE 
			WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3
			WHEN ISNULL(pd.either_parent_attend_college,'-1') = 1 then 0
			WHEN ISNULL(pd.either_parent_attend_college,'-1') = 2 then 0
			WHEN ISNULL(pd.either_parent_attend_college,'-1') = 3 then 1
			WHEN ISNULL(pd.either_parent_attend_college,'-1') = 4 then -1
			WHEN ISNULL(pd.par_1_highest_grade_level,'4') = 3 or ISNULL(pd.par_2_highest_grade_level,'4') = 3 THEN 1
			WHEN ISNULL(pd.par_1_highest_grade_level,'4') = 4 AND ISNULL(pd.par_2_highest_grade_level,'4') = 4 THEN -1
			ELSE 0
		END, -1) AS parent_ed,

--***************************************************************************************--

	 CASE 
		WHEN  ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN 0
		ELSE CAST(ISNULL(sts.career_gpa,0)AS DECIMAL(10,2))
	 END AS gpa_yr1,

--***************************************************************************************--

	ISNULL(
		CASE 
			WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3 --Students that are NOT enrolled OR NOT full time -3
			WHEN sc.has_remedial = 1 THEN 1
			WHEN sc.has_remedial = 0 THEN 0
		END ,0) AS remed_crs, 

--***************************************************************************************--

	-3 as conted_crs,

--***************************************************************************************--

	CASE 
		WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3 --Students that are NOT enrolled OR NOT full time -3
		WHEN CAST(ROUND(ISNULL(th.tuit_fees,0),0,0)AS DECIMAL(10,0)) = 0 then 0
		ELSE CAST(ROUND(ISNULL(th.tuit_fees,0),0,0)AS DECIMAL(10,0))
	END as tuit_fees,

--***************************************************************************************--

	ISNULL(CASE 
		WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3
        WHEN nv.tot_inst_funds_disb - nv.total_job_non_need_tuition <= remaining_need THEN nv.tot_inst_funds_disb
        ELSE remaining_need
	END,0) as needaid_award,

--***************************************************************************************--

	ISNULL(CASE 
		WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3
        WHEN nv.tot_inst_funds_disb - nv.total_job_need_tuition <= remaining_need THEN nv.tot_inst_funds_disb 
        ELSE remaining_need
	END,0) as needaid_recd,

--***************************************************************************************--

	CASE 
		WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3
		WHEN nv.tot_inst_funds_disb - nv.Total_job_non_need_tuition > remaining_need  THEN nv.tot_inst_funds_disb - remaining_need
        ELSE 0
	END as notneedaid_award,

--***************************************************************************************--

	CASE 
		WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3
		WHEN nv.tot_inst_funds_disb - nv.Total_job_non_need_tuition > remaining_need  THEN nv.tot_inst_funds_disb - remaining_need
        ELSE 0
	END as notneedaid_recd,

--***************************************************************************************--

	ISNULL(
		CASE
			WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3
			WHEN pfi.tot_fed_funds_disb + pfi.tot_state_funds_disb - pfi.tot_ffelp_disb - nv.total_fws_tuition - nv.total_va_tuition  < 0 THEN 0
			else pfi.tot_fed_funds_disb + pfi.tot_state_funds_disb - pfi.tot_ffelp_disb - nv.total_fws_tuition - nv.total_va_tuition
		END,-3) as lclstatfedaid_award,

--***************************************************************************************--
	ISNULL(
		CASE
			WHEN ISNULL(fps.ExampleStudentFulltimeTable1, 0) != 1 OR ISNULL(es.ExampleStudentEnrollTable1, 0) != 1 THEN -3
			WHEN pfi.tot_fed_funds_disb + pfi.tot_state_funds_disb - pfi.tot_ffelp_disb - nv.total_fws_tuition - nv.total_va_tuition  < 0 THEN 0
			else pfi.tot_fed_funds_disb + pfi.tot_state_funds_disb - pfi.tot_ffelp_disb - nv.total_fws_tuition - nv.total_va_tuition
		END,-3) as lclstatfedaid_recd,

--***************************************************************************************--

	ISNULL(
		CASE 
			-- Rule 1: Non-Degree Seeking
			WHEN ISNULL(h.NON_DEGREE_SEEKING,0) != 'N' THEN -3
			-- Rule 2: Graduated Month
			WHEN ISNULL(LTRIM(RTRIM(h.exit_reason)),0) = 'G' and h.DIV_CDE = 'UG' THEN ISNULL(DATEPART(month, h.DTE_DEGR_CONFERRED), -3)
			-- Rule 3: Enrolled FT but hasn't graduated yet
			WHEN ISNULL(LTRIM(RTRIM(h.exit_reason)),0) != 'G' and h.DIV_CDE = 'UG' THEN -3
			ELSE 0 
		END, -1) AS comp_date_m,

	ISNULL(
		CASE 
			-- Rule 1: Non-Degree Seeking
			WHEN ISNULL(h.NON_DEGREE_SEEKING,0) != 'N' THEN -3
			-- Rule 2: Graduated Day
			WHEN ISNULL(LTRIM(RTRIM(h.exit_reason)),0) = 'G' and h.DIV_CDE = 'UG' THEN ISNULL(DATEPART(day, h.DTE_DEGR_CONFERRED), -3)
			-- Rule 3: Enrolled FT but hasn't graduated yet
			WHEN ISNULL(LTRIM(RTRIM(h.exit_reason)),0) != 'G' and h.DIV_CDE = 'UG' THEN -3
			ELSE 0 
		END, -1) AS comp_date_d,

	ISNULL(
		CASE 
			-- Rule 1: Non-Degree Seeking
			WHEN ISNULL(h.NON_DEGREE_SEEKING,0) != 'N' THEN -3
			-- Rule 2: Graduated Year
			WHEN ISNULL(LTRIM(RTRIM(h.exit_reason)),0) = 'G' and h.DIV_CDE = 'UG' THEN ISNULL(DATEPART(year, h.DTE_DEGR_CONFERRED),-3)
			-- Rule 3: Enrolled FT but hasn't graduated yet
			WHEN ISNULL(LTRIM(RTRIM(h.exit_reason)),0) != 'G' and h.DIV_CDE = 'UG' THEN -3
			ELSE -1
		END, -1) AS comp_date_y,

	ISNULL(
		CASE 
			WHEN ISNULL(h.NON_DEGREE_SEEKING,0) != 'N' then -3 
			WHEN B.DECEASED = 'Y' THEN -5
			WHEN ISNULL(h.exit_reason,0) != 'G' then -3
			WHEN ISNULL(h.exit_reason,0) = 'G' and h.DEGREE_YR <= h.EXPECT_GRAD_YR THEN 1 
			WHEN ISNULL(h.exit_reason,0) = 'G' and h.DEGREE_YR > h.EXPECT_GRAD_YR THEN 0
		 END,-1) AS comp_100,

		 ISNULL(
		CASE 
			WHEN ISNULL(h.NON_DEGREE_SEEKING,0) != 'N' then -3 
			WHEN B.DECEASED = 'Y' THEN -5
			WHEN ISNULL(h.exit_reason,0) != 'G' then -3
			WHEN ISNULL(h.exit_reason,0) = 'G' and h.DEGREE_YR = h.EXPECT_GRAD_YR THEN 1 
			WHEN ISNULL(h.exit_reason,0) = 'G' and h.DEGREE_YR - 2 <= h.EXPECT_GRAD_YR then 1
			WHEN ISNULL(h.exit_reason,0) = 'G' and h.DEGREE_YR - 2 > h.EXPECT_GRAD_YR THEN 0
		 END,-1) AS comp_150
		 
-- SECTION 2. DESCRIPTION: From/Join statements, cross database connections here. Ensure keys/connection is still up-to-date.

FROM ExampleStudentCandidacy1 a

--/////////////////////////////////TEMPORARY JOIN////////////////////////////////////////--

LEFT OUTER JOIN ExampleStudentNameTable1 nm ON nm.ID_NUM = a.ID_NUM

--/////////////////////////////////TEMPORARY JOIN////////////////////////////////////////--

--Joining for 'sex' field

LEFT OUTER JOIN (
    SELECT id_num, MAX(gender) as gender, MAX(deceased) as deceased
    FROM ExampleBiographTable1
    GROUP BY id_num
) b ON a.id_num = b.id_num

--Joining for 'race_eth' field

LEFT OUTER JOIN (
    SELECT id_num, 
		MAX(CASE WHEN ipeds_report_value = 9 THEN 8 
        WHEN ipeds_report_value = 8 THEN 7  
        WHEN ipeds_report_value = 7 THEN 6
        WHEN ipeds_report_value = 6 THEN 5
        WHEN ipeds_report_value = 5 THEN 4
        WHEN ipeds_report_value = 4 THEN 3
        WHEN ipeds_report_value = 3 THEN 2
        WHEN ipeds_report_value = 2 THEN -1
        WHEN ipeds_report_value = 1 THEN 1
        ELSE -1 END) AS 'race_eth'
    FROM ExampleStudentEthnicTable1
    GROUP BY id_num
) er ON a.id_num = er.id_num

--Joining for ACT/SAT information

LEFT OUTER JOIN (
    SELECT id_num, 
        MAX(sat_math) as sat_math, MAX(sat_reading) as sat_reading, MAX(sat_comp) as sat_comp,
        MAX(act_math) as act_math, MAX(act_english) as act_english, MAX(act_comp) as act_comp
    FROM [admissions_data_table]
    GROUP BY id_num
) ra ON a.id_num = ra.id_num

--PFAIDS BASE JOIN (Core for multiple dependent joins)

LEFT OUTER JOIN [finaid_db]dbo.ExampleFinStudentTable1 s ON s.alternate_id = a.id_num
LEFT OUTER JOIN [finaid_db]dbo.ExampleFinYearStudentTable1 ay ON ay.student_token = s.student_token AND ay.award_year_token = @Year_cde

--Joining for parent ed and Pell status via ranked transaction

LEFT OUTER JOIN (
    SELECT 
        stu_award_year_token,
        either_parent_attend_college,
        ISNULL(fed_pell_grant_eligibility,'0') AS fed_pell_grant_eligibility,
        par_1_highest_grade_level,
        par_2_highest_grade_level,
        ROW_NUMBER() OVER (PARTITION BY stu_award_year_token ORDER BY transaction_number DESC) as rn
    FROM [finaid_db].dbo.ExampleStudentFinTable1
) pd ON pd.stu_award_year_token = ay.stu_award_year_token AND pd.rn = 1

--Joining for First Year GPA

LEFT OUTER JOIN (
	SELECT ts.id_num, ts.CAREER_GPA,
		ROW_NUMBER() OVER (PARTITION BY ts.id_num ORDER BY ts.career_hrs_attempt DESC) AS rn
	FROM ExampleStudentDivTable1 ts
	WHERE yr_cde = @Year_cde and DIV_CDE = @Div_cde
) sts ON sts.id_num = a.ID_NUM AND sts.rn = 1

--Joining for Tuition Fees

LEFT OUTER JOIN (
	SELECT id_num, SUM(trans_amt) as tuit_fees 
	FROM ExampleStudentTransactionTable1 
    WHERE SOURCE_CDE = 'CG' AND TRANS_DTE BETWEEN @Begin_date AND @End_date 
	  AND CHG_FEE_CDE NOT IN (SELECT Chg_fee FROM @Charge_Fee_Cdes)
	  AND REPLACE(acct_cde, ' ', '') = '[Account_Code]' 
	GROUP BY id_num
) th on th.id_num = a.id_num

--Joining for Remedial Courses

LEFT OUTER JOIN (
	SELECT ID_NUM, 1 as has_remedial 
	FROM ExampleStudentHistoryTable1 
	WHERE (REPLACE(crs_cde,' ','') LIKE 'EXMP1%' OR REPLACE(crs_cde,' ','') LIKE 'EXMP2%')
      AND yr_cde = @Year_cde AND trm_cde in (select Term from @Temp_Term_Cdes)
    GROUP BY ID_NUM
) sc ON sc.ID_NUM = a.id_num

--Joining PFAids Disbursed Totals

LEFT OUTER JOIN [finaid_db].dbo.ExampleStudentFinSumTable1 pfi ON pfi.stu_award_year_token = ay.stu_award_year_token

--Joining  Pfaids par table for family income
LEFT OUTER JOIN [finaid_db].dbo.ExampleStudentFinTable1 pfp on pfp.stu_award_year_token = ay.stu_award_year_token

--Joining for Need/Non-Need CTE Results

LEFT OUTER JOIN CalculatedVars NV ON NV.stu_award_year_token = ay.stu_award_year_token

--Joining for Degree History

LEFT OUTER JOIN (
    SELECT id_num, isnull(non_degree_seeking,0) as non_degree_seeking, isnull(exit_reason,0) as exit_reason, isnull(cur_degree,0) as cur_degree,
	isnull(expect_grad_yr,0) as expect_grad_yr, isnull(degree_yr,0) as degree_yr, isnull(dte_degr_conferred,0) as dte_degr_conferred, div_cde
    FROM (
        SELECT 
            id_num, 
            non_degree_seeking,
            exit_reason,
            cur_degree,
            expect_grad_yr,
            degree_yr,
            dte_degr_conferred,
			div_cde,
            ROW_NUMBER() OVER (
                PARTITION BY id_num 
                ORDER BY expect_grad_yr DESC
            ) as row_num
        FROM ExampleStudentDegreeTable1
		WHERE DIV_CDE = @Div_cde
    ) ranked_degrees
    WHERE row_num = 1
) AS h ON h.id_num = a.ID_NUM


--Joining CTE For full time status
left outer join ExampleStudentFulltimeTable1 fps on fps.ID_NUM = a.ID_NUM

--Joining CTE For enrollment status
LEFT OUTER JOIN ExampleStudentEnrollTable1 es on es.ID_NUM = a.ID_NUM

-- SECTION 3. DESCRIPTION: Where statement, keep this as light as possible as we are working with numerous joins, can cause unintended issues if edited. 



WHERE a.DIV_CDE = @Div_cde 
  AND a.yr_cde = @Year_cde
  AND a.trm_cde in (select Term from @Temp_Term_Cdes)
  AND a.stage > '22'
  AND a.candidacy_type IN (SELECT CAND_VAL FROM @CAND_TYPE)
  AND a.CUR_CANDIDACY = 'Y'
  and a.id_num != '[Test_ID]'

	
 
  ORDER BY a.ID_NUM