select a.*,
substr(b.SUP1,INSTR(b.SUP1,'|')+1) SUP1,
substr(b.MGR1,INSTR(b.MGR1,'|')+1) MGR1,
substr(b.SRMGR1,INSTR(b.SRMGR1,'|')+1) SRMGR1,
substr(b.DIR1,INSTR(b.DIR1,'|')+1) DIR1,
substr(b.SRDIR1,INSTR(b.SRDIR1,'|')+1) SRDIR1,
substr(b.VP1,INSTR(b.VP1,'|')+1) VP1,
substr(b.SVP1,INSTR(b.SVP1,'|')+1) SVP1,
substr(b.EVP1,INSTR(b.EVP1,'|')+1) EVP1,
substr(b.PRES1,INSTR(b.PRES1,'|')+1) PRES1,
substr(b.CEO,INSTR(b.CEO,'|')+1) CEO
 from (SELECT 
 papf.person_number , pe.primary_flag,
  to_char(:P_AS_OF_DATE,'mm/dd/yyyy') As_of_date,
  ppnf.full_name || ' ' || ppnf.MIDDLE_NAMES NAME,
  paam.system_person_type Org_Relation, 
  pjf.Job_code,
  Substr(per_extract_utility.Get_by_primary_key_de('hr_all_organization_units_f_vl', 'organization_id', paam.business_unit_id, 'name', trunc(sysdate)),1,5)  unit,
  pjtl.name Descr, 
  --pjf.JOB_FUNCTION_CODE,
  SUBSTR(paam.full_part_time, 1, 1) FULL_PART_TIME,
  paam.permanent_temporary_flag REG_TEMP,
  paam.hourly_salaried_code EMPL_TYPE,
 -- pjf.MANAGER_LEVEL,
  per_extract_utility.Get_decoded_lookup('MANAGER_LEVEL', pjf.MANAGER_LEVEL) MANAGER_LEVEL,
  --per_extract_utility.get_decoded_lookup('PER_ETHNICITY', pe.ethnicity) ethnicity,
  	(SELECT meaning
           FROM FND_LOOKUP_VALUES_VL
      WHERE lookup_type = 'PER_ETHNICITY'
      AND lookup_code = pe.ethnicity)ethn,
	  decode(per_extract_utility.get_decoded_lookup('PER_ETHNICITY', pe.ethnicity),'White','Non Minority',
null,'Non Minority','Not disclosed','Non Minority'
,'Minority' )Minority_Non,
  -- decode(per_extract_utility.get_decoded_lookup('PER_ETHNICITY', pe.ethnicity),'White','Non Minority','Minority' )Minority_Non,
    	/*decode((SELECT meaning
           FROM FND_LOOKUP_VALUES_VL
      WHERE lookup_type = 'PER_ETHNICITY'
      AND lookup_code = pe.ethnicity),'White','Non Minority','Minority' )Minority_Non,*/
	  
  /*	CASE 
WHEN pjf.MANAGER_LEVEL IN (0, 3, 10, 11, 12) THEN 'Officer' 
WHEN pjf.MANAGER_LEVEL IN (1, 16) THEN 'Director' 
WHEN pjf.MANAGER_LEVEL IN (4) THEN 'Sr. Manager' 
WHEN pjf.MANAGER_LEVEL IN (13, 15) THEN 'Manager' 
WHEN pjf.MANAGER_LEVEL IN (7, 8, 9, 14) THEN 'Non-Management' 
ELSE 'Not Found' 
END Title_Groups,*/
 /* Substr(
    per_extract_utility.Get_by_primary_key_de(
      'hr_all_organization_units_f_vl', 
      'organization_id', paam.organization_id, 
      'name', paam.effective_start_date
    ), 
    1, 
    Instr(
      per_extract_utility.Get_by_primary_key_de(
        'hr_all_organization_units_f_vl', 
        'organization_id', paam.organization_id, 
        'name', paam.effective_start_date
      ), 
      '-'
    )-2
  ) deptid*/
     per_extract_utility.Get_by_primary_key_de(
      'hr_all_organization_units_f_vl', 
      'organization_id', paam.organization_id, 
      'name', trunc(sysdate)
    )deptid, 
  
  --pplf.sex GENDER IH,
  per_extract_utility.get_decoded_lookup('SEX', pplf.sex) GENDER,
(select TO_CHAR(psdf.seniority_date,'MM/DD/YYYY')
from per_seniority_dates_f psdf
where psdf.person_id  =paam.person_id  
   AND sysdate BETWEEN psdf.effective_start_date AND psdf.effective_end_date
   AND psdf.seniority_date_code = 'OD_LHRD_EP') date_start,
/*Post Spinoff Code changes to populate the hire/rehire date - End */

--  trim(substr(csb.CODE, instr(csb.CODE, '_', - 1, 1) + 1, length(csb.code))) SAL_ADMIN_PLAN,
  (select 
  csb.name from  cmp_salary cs,
  cmp_salary_bases csb where  cs.assignment_id = paam.assignment_id 
  AND csb.salary_basis_id = cs.salary_basis_id 
  and trunc(:P_AS_OF_DATE) between cs.date_from  and NVL(cs.date_to ,trunc(:P_AS_OF_DATE))
  and cs.SALARY_APPROVED = 'Y')SAL_ADMIN_PLAN,
	pgf.GRADE_CODE GRADE,
	   hlafv.ATTRIBUTE2 Region,
   hlafv.ATTRIBUTE3 District,
    hlafv.LOCATION_NAME location,--internal_location_code location,
 /* decode(
    paam.assignment_status_type, 'ACTIVE', 
    'Active', 'SUSPENDED', 'Active', 
    'INACTIVE', 'Terminated', null
  ) Pay_STATUS, */
  per_extract_utility.Get_decoded_lookup('JOB_FUNCTION_CODE', pjf.job_function_code) JOB_FUNCTION_CODE,
 
  (
    select 
      papf_sup.person_number 
    FROM 
      per_all_people_f papf_sup, 
      per_person_names_f ppnf_sup, 
      per_assignment_supervisors_f pasf1 
    where 
      1 = 1 
      and papf_sup.person_id = ppnf_sup.person_id 
      AND ppnf_sup.person_id = pasf1.manager_id 
      AND pasf1.assignment_id = paam.assignment_id 
      AND pasf1.primary_flag = 'Y' 
      AND pasf1.manager_type = 'LINE_MANAGER' 
      AND ppnf_sup.name_type = 'GLOBAL' 
      AND paam.effective_start_date BETWEEN papf_sup.effective_start_date 
      AND papf_sup.effective_end_date 
      AND paam.effective_start_date BETWEEN ppnf_sup.effective_start_date 
      AND ppnf_sup.effective_end_date 
      AND paam.effective_start_date BETWEEN pasf1.effective_start_date 
      AND pasf1.effective_end_date
  ) Sup_number, 
    (
    select 
      ppnf_sup.full_name 
    FROM 
      per_all_people_f papf_sup, 
      per_person_names_f ppnf_sup, 
      per_assignment_supervisors_f pasf1 
    where 
      1 = 1 
      and papf_sup.person_id = ppnf_sup.person_id 
      AND ppnf_sup.person_id = pasf1.manager_id 
      AND pasf1.assignment_id = paam.assignment_id 
      AND pasf1.primary_flag = 'Y' 
      AND pasf1.manager_type = 'LINE_MANAGER' 
      AND ppnf_sup.name_type = 'GLOBAL' 
      AND paam.effective_start_date BETWEEN papf_sup.effective_start_date 
      AND papf_sup.effective_end_date 
      AND paam.effective_start_date BETWEEN ppnf_sup.effective_start_date 
      AND ppnf_sup.effective_end_date 
      AND paam.effective_start_date BETWEEN pasf1.effective_start_date 
      AND pasf1.effective_end_date
  ) Sup_name, 
  
  xep.LE_INFORMATION_CONTEXT Reg_Region,
 -- paam.legislation_code Reg_Region, 
 -- ,hlafv.TOWN_OR_CITY 
  pea.email_address Work_Email,
  (SELECT
					
				DECODE(T.INFORMATION1,'P','P','NONEXEMPT','N','EXEMPT','E','M','M','A','A','X','X','O','O','E','E',T.INFORMATION1)					
				FROM PER_JOB_LEG_F T 
				WHERE
					T.JOB_ID = paam.JOB_ID 
					AND T.LEGISLATION_CODE = 'US' 
					AND paam.EFFECTIVE_START_DATE BETWEEN T.EFFECTIVE_START_DATE AND T.EFFECTIVE_END_DATE 
					AND ROWNUM < 2 
			)
			AS FLSA_STATUS,
  to_char(pp.date_of_birth,'mm/dd') birthdate,
  
(select pldfv.location_name||'    '||paf.town_or_city||'    '||paf.region_2||'   '||paf.Country
 from per_addresses_f paf, per_location_details_f_vl pldfv
 WHERE
paf.address_id = pldfv.main_address_id
and paf.country = 'US' and pldfv.active_status like 'A' 
and pldfv.attribute1='USSTO'
and trunc(sysdate) between paf.effective_start_date and paf.effective_end_date
and trunc(sysdate) between pldfv.effective_start_date and pldfv.effective_end_date
and paf.address_id = paam.ASS_ATTRIBUTE2 and rownum<2)Secondary_Store,

(select pldfv.location_name||'    '||paf.town_or_city||'    '||paf.region_2||'   '||paf.Country
 from per_addresses_f paf, per_location_details_f_vl pldfv
 WHERE
paf.address_id = pldfv.main_address_id
and paf.country = 'US' and pldfv.active_status like 'A' 
and pldfv.attribute1='USSTO'
and trunc(sysdate) between paf.effective_start_date and paf.effective_end_date
and trunc(sysdate) between pldfv.effective_start_date and pldfv.effective_end_date
 and paf.address_id = paam.ASS_ATTRIBUTE3 and rownum<2)Third_Store,
 
 (SELECT ppt.USER_PERSON_TYPE
        FROM per_person_types_vl               ppt
      WHERE paam.person_type_id = ppt.person_type_id  
      AND ROWNUM = 1 ) User_person_Type
 
FROM 
  PER_PERSON_SECURED_LIST_V  papf, --per_all_people_f
 -- per_seniority_dates_f psdf1,   --added as  part of hire date spinoff changes
  per_person_names_f ppnf, 
  PER_ASSIGNMENT_SECURED_LIST_V   paam,  --per_all_assignments_m
  hr_locations_all_f_vl hlafv, 
  xle_entity_profiles xep, 
  PER_DEPARTMENT_SECURED_LIST_V  houf, --hr_all_organization_units_f_vl
  per_jobs_f pjf, 
  per_jobs_f_tl pjtl, 
  per_email_addresses pea ,
  per_ethnicities pe,
  per_people_legislative_f pplf,
  per_periods_of_service ppos,
  --cmp_salary cs,
 -- cmp_salary_bases csb,
  per_grades_f pgf,
  per_persons pp,
  HR_ORG_UNIT_CLASSIFICATIONS_F houcf, 
  PER_DEPARTMENT_SECURED_LIST_V  haouf, --HR_ALL_ORGANIZATION_UNITS_F
  HR_ORGANIZATION_UNITS_F_TL hauft
  WHERE 
  1 = 1 
  AND papf.person_id = ppnf.person_id 
  --AND psdf1.person_id = papf.person_id
 -- AND psdf1.seniority_date_code = 'OD_LHRD_EP'
  AND paam.person_id = papf.person_id 
  AND hlafv.location_id(+) = paam.location_id 
  AND xep.legal_entity_id = houf.legal_entity_id 
  AND houf.organization_id = paam.legal_entity_id 
  AND xep.legal_employer_flag = 'Y' 
  AND pjtl.job_id(+) = paam.job_id 
  AND pjtl.language(+) = 'US' 
  AND pjf.job_id(+) = paam.job_id 
  --AND pjf.active_status (+) = 'A' 
  AND pea.person_id(+)= papf.person_id
  AND pea.email_type(+)= 'W1' 
  AND pe.person_id( + ) = papf.person_id 
  AND pe.primary_flag( + ) = 'Y' 
  AND ppnf.person_id = pplf.person_id( + ) 
  AND ppnf.legislation_code = pplf.legislation_code( + ) 
  AND ppos.person_id = paam.person_id
   --AND cs.assignment_id( + ) = paam.assignment_id 
  --AND csb.salary_basis_id( + ) = cs.salary_basis_id   
  AND pgf.grade_id( + ) = paam.grade_id
  AND pp.person_id = papf.person_id  
   and haouf.ORGANIZATION_ID = houcf.ORGANIZATION_ID 
AND haouf.ORGANIZATION_ID = hauft.ORGANIZATION_ID 
AND hauft.organization_id = paam.organization_id
and houcf.status = 'A'
AND hauft.LANGUAGE = 'US'
AND houcf.CLASSIFICATION_CODE = 'DEPARTMENT'
--and hlafv.INTERNAL_LOCATION_CODE in ('001344','001348','001461','003031','006869','006896','006897')
--AND trunc(sysdate) BETWEEN psdf1.effective_start_date AND psdf1.effective_end_date 
AND trunc(:P_AS_OF_DATE) BETWEEN houcf.EFFECTIVE_START_DATE AND houcf.EFFECTIVE_END_DATE 
AND trunc(:P_AS_OF_DATE) BETWEEN haouf.EFFECTIVE_START_DATE AND haouf.EFFECTIVE_END_DATE 
AND trunc(:P_AS_OF_DATE) BETWEEN hauft.EFFECTIVE_START_DATE AND hauft.EFFECTIVE_END_DATE 
  AND paam.assignment_type not in ('ET', 'CT', 'PT') 
  AND paam.primary_assignment_flag = 'Y' 
  AND paam.effective_latest_change = 'Y' 
  AND ppnf.name_type = 'GLOBAL' 
  AND  paam.legislation_code IN ('US') 
  and  xep.LE_INFORMATION_CONTEXT  = 'US'
  --AND paam.system_person_type IN ('EMP') 
AND paam.system_person_type IN ('EMP','CWK')  
  AND paam.assignment_status_type IN('ACTIVE', 'SUSPENDED')
/*commented the code and added the new code for Spin-off Project Changes - IH*/
--AND xep.legal_entity_identifier IN ('1001','1053','1060')
AND xep.legal_entity_identifier IN  ('1001','1053','1060','4100','4200','4300','4350','4400','4210')
/*commented the code and added the new code for Spin-off Project Changes - IH*/
  and  Substr(per_extract_utility.Get_by_primary_key_de('hr_all_organization_units_f_vl', 'organization_id', paam.business_unit_id, 'name', paam.effective_start_date),1,5) <> 'NQPEN'
  AND 	ppnf.first_name <> 'SVC'
 --and papf.person_number in('010277','010340')--'142985','895135' ,'305933','33','007317')
  AND trunc(:P_AS_OF_DATE) BETWEEN paam.effective_start_date AND paam.effective_end_date 
  AND trunc(:P_AS_OF_DATE) BETWEEN papf.effective_start_date AND papf.effective_end_date 
  AND trunc(:P_AS_OF_DATE) BETWEEN ppnf.effective_start_date AND ppnf.effective_end_date 
  AND trunc(sysdate) BETWEEN hlafv.effective_start_date(+) AND hlafv.effective_end_date(+) 
  AND trunc(:P_AS_OF_DATE) BETWEEN houf.effective_start_date AND NVL (houf.effective_end_date, trunc(:P_AS_OF_DATE))
  AND trunc(:P_AS_OF_DATE) BETWEEN pjf.effective_start_date(+) AND pjf.effective_end_date(+) 
  AND trunc(:P_AS_OF_DATE) BETWEEN pjtl.effective_start_date(+) AND pjtl.effective_end_date(+) 
  AND trunc(:P_AS_OF_DATE) BETWEEN pplf.effective_start_date( + ) AND pplf.effective_end_date( + ) 
  AND trunc(:P_AS_OF_DATE) BETWEEN pgf.effective_start_date( + ) AND pgf.effective_end_date( + ) 
  and ((COALESCE(:P_Location_code, null) is null) OR (hlafv.internal_location_code IN (:P_Location_code)))
  and ((COALESCE(:P_Region, null) is null) OR (hlafv.ATTRIBUTE2 IN (:P_Region)))
  and ((COALESCE(:P_District, null) is null) OR (hlafv.ATTRIBUTE3  IN (:P_District)))
   and ((COALESCE(:P_Dept, null) is null) OR (per_extract_utility.get_by_primary_key_de('hr_all_organization_units_f_vl', 'organization_id', paam.organization_id, 'name', trunc(sysdate)) IN (:P_Dept)))
  and ((COALESCE(:P_BU, null) is null) OR (Substr(per_extract_utility.Get_by_primary_key_de('hr_all_organization_units_f_vl', 'organization_id', paam.business_unit_id, 'name', trunc(sysdate)),1,5) IN (:P_BU)))
  
  
--and trunc(sysdate) between cs.date_from and NVL(cs.date_to,trunc(sysdate))
--and cs.SALARY_APPROVED = 'Y'
--and pe.primary_flag = 'N'
--and pe.legislation_code= 'US'
  /*AND    ppos.date_start = 
       ( 
              SELECT max(date_start) 
              FROM   per_periods_of_service ppos1 
              WHERE  ppos1.person_id = ppos.person_id 
			  and ppos1.date_start <= trunc(sysdate)) */
 AND  ppos.period_of_service_id = paam.period_of_service_id
 --AND  PPOS.PERIOD_TYPE='E' 
 ) A,
 (
( 
		SELECT
			papf_person.person_number Emp , flv.lookup_code OD_Rep_Level , papf.person_number|| '|' || ppnf.full_name Manager 
		FROM
			(
				SELECT
					B.*,
					B.manager_level || '-' || ROW_NUMBER() OVER (PARTITION BY B.manager_level, B.emp_pers_id 
				ORDER BY
					B.lvl) mgr_level 
				FROM
					(
						SELECT
							A.manager_id,
							A.manager_level,
							CONNECT_BY_ROOT A.person_id emp_pers_id,
							LEVEL lvl 
						FROM
							(
								SELECT
									pasf.manager_id,
									pasf.person_id,
									pjf.manager_level 
								FROM
									per_assignment_supervisors_f pasf,
									per_all_assignments_f paaf,--per_all_assignments_f   PER_ASSIGNMENT_SECURED_LIST_V
									per_jobs_f pjf,
									PER_ASSIGNMENT_SECURED_LIST_V MGRASG			-- Added to fix hierarchy IH
								WHERE
									pasf.manager_type = 'LINE_MANAGER' 
									AND paaf.assignment_id = pasf.manager_assignment_id 
									AND paaf.primary_assignment_flag = 'Y'			-- Added to fix hierarchy IH
									AND paaf.assignment_type in ('E', 'C')			-- Added to fix hierarchy IH
									-- Changes starts for NAIT-241281 -to handle GLB_TRANSFER issue
									AND MGRASG.assignment_id NOT IN (
																	SELECT paaf2.assignment_id
																	FROM per_all_assignments_f paaf2
																	WHERE paaf2.person_id = MGRASG.person_id
																	AND paaf2.action_code = 'GLB_TRANSFER'
																	AND paaf2.assignment_status_type_id = '1001'
																	AND trunc(:P_AS_OF_DATE) BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
																	) 
									-- Changes ends for NAIT-241281 -to handle GLB_TRANSFER issue
									AND paaf.job_id = pjf.job_id 
									AND pjf.active_status = 'A'
									AND MGRASG.assignment_id = pasf.assignment_id	-- Added to fix hierarchy IH
									AND MGRASG.primary_flag = 'Y' 					-- Added to fix hierarchy IH
									AND MGRASG.assignment_type in ('E', 'C')		-- Added to fix hierarchy IH
									AND MGRASG.primary_assignment_flag = 'Y'		-- Added to fix hierarchy IH
									AND trunc(:P_AS_OF_DATE) BETWEEN MGRASG.effective_start_date AND MGRASG.effective_end_date -- Added to fix ORC hierarchy issue. Post recruitment days only IH
									AND trunc(:P_AS_OF_DATE) BETWEEN pasf.effective_start_date AND pasf.effective_end_date 
									AND trunc(:P_AS_OF_DATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date 
									AND trunc(:P_AS_OF_DATE) BETWEEN pjf.effective_start_date AND pjf.effective_end_date
							)
							A CONNECT BY NOCYCLE PRIOR A.manager_id = A.person_id 
					)
					B 
			)
			C , fnd_lookup_values flv , per_all_people_f papf_person , per_all_people_f papf , per_person_names_f ppnf  --PER_PERSON_SECURED_LIST_V
		WHERE
			flv.lookup_type = 'OD_REP_MGR_LEVEL_MAP_LKP' 
			AND flv.meaning = C.mgr_level 
			AND flv.language = 'US' 
			AND flv.enabled_flag = 'Y' 
			AND trunc(:P_AS_OF_DATE) BETWEEN NVL(flv.start_date_active, trunc(:P_AS_OF_DATE)) AND NVL(flv.end_date_active, trunc(:P_AS_OF_DATE)) 
			AND trunc(:P_AS_OF_DATE) BETWEEN papf.effective_start_date and papf.effective_end_date 
			AND trunc(:P_AS_OF_DATE) BETWEEN papf_person.effective_start_date and papf_person.effective_end_date 
			AND trunc(:P_AS_OF_DATE) BETWEEN ppnf.effective_start_date and ppnf.effective_end_date 
			AND ppnf.name_type = 'GLOBAL' 
			AND papf.person_id = ppnf.person_id 
			AND papf.person_id = C.manager_id 
			--AND papf_person.person_id = ppnf.person_id  --
			--AND papf_person.person_id = C.manager_id  --
			AND papf_person.person_id = C.emp_pers_id) PIVOT ( MAX(Manager) FOR OD_Rep_Level IN 
			(
				'1' AS "SUP1",
				'2' AS "Sup2",
				'3' AS "MGR1",
				'4' AS "Mgr2",
				'5' AS "SRMGR1",
				'6' AS "SrMgr2",
				'7' AS "DIR1",
				'8' AS "Dir2",
				'9' AS "SRDIR1",
				'10' AS "SrDir2",
				'11' AS "VP1",
				'12' AS "VP2",
				'13' AS "SVP1",
				'14' AS "SVP2",
				'15' AS "EVP1",
				'16' AS "EVP2",
				'17' AS "PRES1",
				'18' AS "PRES2",
				'19' AS "CEO" 
			)
) 
	)B
WHERE
	1 = 1 
	AND B.Emp(+) = A.person_number 
	and    ((COALESCE(:P_SVP, null) is null) OR (SUBSTR(b.SVP1,1,INSTR(b.SVP1,'|')-1) IN (:P_SVP)))	
	and    ((COALESCE(:P_EVP, null) is null) OR (SUBSTR(b.EVP1,1,INSTR(b.EVP1,'|')-1) IN (:P_EVP)))		
    and    ((COALESCE(:P_VP, null) is null) OR (SUBSTR(b.VP1,1,INSTR(b.VP1,'|')-1) IN (:P_VP)))	
 order by 
  a.person_number