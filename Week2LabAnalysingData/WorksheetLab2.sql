--Checks if the tables were created and populated correctly
SELECT * FROM TEST;
SELECT * FROM EMP;
SELECT * FROM DEPT;
SELECT * FROM BONUS;
SELECT * FROM SALGRADE;

--Q1-1 What is the maximum and minimum salary
SELECT MAX(SAL) AS MAXIMUM_SALARY, MIN(SAL) AS MINIMUM_SALARY FROM EMP; 

--Q1-2 What is the differene between the maximun and average salary
SELECT (MAX(SAL) - AVG(SAL)) AS DIFFERENCE_AVG FROM EMP;
SELECT (MAX(SAL) - MIN(SAL)) AS DIFFERENCE_MIN FROM EMP;

--Q1-3 COUNT the number of employees per grade
SELECT COUNT(EMPNO) AS COUNT_NUMBER_EMPLOYEES FROM EMP; 
SELECT COUNT(GRADE) AS NEWGRADE FROM SALGRADE; 

-- Q1-3: Count the number of employees per grade
SELECT s.GRADE, 
       COUNT(e.EMPNO) AS NUM_EMPLOYEES
FROM EMP e
JOIN SALGRADE s 
  ON e.SAL BETWEEN s.LOSAL AND s.HISAL
GROUP BY s.GRADE
ORDER BY s.GRADE;

--Q1-4 What is the average salary per department
SELECT d.DNAME,
    AVG(e.SAL) AS AVERAGE_SALARY
FROM EMP e
JOIN DEPT d
 on e.DEPTNO = d.DEPTNO
GROUP BY d.DNAME
ORDER BY d.DNAME;

--Q1-5 Use Summary pacakge 
SET SERVEROUTPUT ON;

DECLARE
 S DBMS_STAT_FUNCS.SummaryType;
BEGIN
    DBMS_STAT_FUNCS.Summary(
        'Darren',
        'EMP',
        'SAL',
        3,
        s
    );

DBMS_OUTPUT.PUT_LINE('SUMMARY OF SAL');
  DBMS_OUTPUT.PUT_LINE('Count        : ' || s.count);
  DBMS_OUTPUT.PUT_LINE('Min          : ' || s.min);
  DBMS_OUTPUT.PUT_LINE('Max          : ' || s.max);
  DBMS_OUTPUT.PUT_LINE('Range        : ' || s.range);
  DBMS_OUTPUT.PUT_LINE('Mean         : ' || s.mean);
  DBMS_OUTPUT.PUT_LINE('Variance     : ' || s.variance);
  DBMS_OUTPUT.PUT_LINE('Stddev       : ' || s.stddev);
  DBMS_OUTPUT.PUT_LINE('Quantile 5   : ' || s.quantile_5);
  DBMS_OUTPUT.PUT_LINE('Quantile 25  : ' || s.quantile_25);
  DBMS_OUTPUT.PUT_LINE('Median       : ' || s.median);
  DBMS_OUTPUT.PUT_LINE('Quantile 75  : ' || s.quantile_75);
  DBMS_OUTPUT.PUT_LINE('Quantile 95  : ' || s.quantile_95);
  -- you can also print extremes, top/bottom values, etc.
END;
/

--Q1-6 HAVING CLAUSE
-- SELECT THE DEPARTMENT NAME AND THE NUMBER OF EMPLOYEES who have a department with more than 2 employees

SELECT d.Dname,
        COUNT(e.EMPNO) AS NUM_EMPLOYEES
FROM EMP e
JOIN DEPT d
  ON e.DEPTNO = d.DEPTNO 
GROUP BY d.DNAME
HAVING COUNT(e.EMPNO) > 2;


--Q1-7 List Employers Who have a salary greater than the average salary
SELECT e.ENAME, e.SAL
FROM EMP e
Group by e.ENAME, e.SAL
Having e.SAL > (SELECT AVG(SAL) FROM EMP)
ORDER BY e.sal DESC;

--REMINDER TO SELF E is used as alias for EMP table and D is used as alias for DEPT table
--SO when i SEE EMP e emp is referred to as e e.ENAME means FROM EMP Ename rather than typing the whole table name


--SECTION 2 ANALYTIC FUNCTIONS
--Q2-1 Sampling DATA 
SELECT * FROM EMP SAMPLE(5);
SELECT * FROM EMP SAMPLE(10);
SELECT * FROM EMP SAMPLE(15);
SELECT * FROM EMP SAMPLE(20);

-- From the different values of sampling we can see Higher % more rows on average 20% returned 6 rows while 5 usually returned 1 row
-- USING ORA HASH
SELECT ENAME,SAL 
FROM EMP
WHERE ORA_HASH(ENAME, 100) < 10;

-- For exactly 10%:
SELECT ENAME, SAL
FROM EMP
WHERE ORA_HASH(ENAME, 9) = 0;

-- Or use SAMPLE clause (non-deterministic):
SELECT ENAME, SAL
FROM EMP SAMPLE(10);

--HASH on reruns uses the same row it generates for names while Sample can have different rows on reruns

--Q2-2 PIVOT
--Q1-4 What is the average salary per department
SELECT d.DNAME,
    AVG(e.SAL) AS AVERAGE_SALARY
FROM EMP e
JOIN DEPT d
 on e.DEPTNO = d.DEPTNO
GROUP BY d.DNAME
ORDER BY d.DNAME;

--using pivot now 
SELECT *
FROM (
    SELECT d.DNAME, e.SAL
    FROM EMP e
    JOIN DEPT d ON e.DEPTNO = d.DEPTNO
)
PIVOT (
    AVG(SAL)
    FOR DNAME IN ('ACCOUNTING' AS ACCOUNTING,
                  'RESEARCH' AS RESEARCH,
                  'SALES' AS SALES,
                  'OPERATIONS' AS OPERATIONS)
);


--USING LEAD AND LAG 
SELECT EMPNO, ENAME, JOB, SAL
FROM EMP
ORDER BY SAL ASC;

--lag
SELECT EMPNO, ENAME, JOB, SAL,
       LAG(SAL) OVER (ORDER BY SAL) AS PREV_SALARY
FROM EMP
ORDER BY SAL ASC;

--lead
SELECT EMPNO, ENAME, JOB, SAL,
       LAG(SAL) OVER (ORDER BY SAL) AS PREV_SALARY,
       LEAD(SAL) OVER (ORDER BY SAL) AS NEXT_SALARY
FROM EMP
ORDER BY SAL ASC;

--Difference column
SELECT EMPNO, ENAME, JOB, SAL,
       LAG(SAL) OVER (ORDER BY SAL) AS PREV_SALARY,
       LEAD(SAL) OVER (ORDER BY SAL) AS NEXT_SALARY,
       SAL - LAG(SAL) OVER (ORDER BY SAL) AS DIFF_FROM_BELOW,
       LEAD(SAL) OVER (ORDER BY SAL) - SAL AS DIFF_FROM_ABOVE
FROM EMP
ORDER BY SAL ASC;

--Ranking STAFF
SELECT EMPNO, DEPTNO, SAL,
ROW_NUMBER() OVER (PARTITION BY DEPTNO ORDER BY SAL DESC) AS RANKING
FROM EMP
ORDER BY DEPTNO, SAL DESC;
       
--Excercise 3
DROP TABLE countries_ext;

CREATE TABLE countries_ext (
   country_code     VARCHAR2(5),
   country_name     VARCHAR2(50),
   country_language VARCHAR2(50)
)
ORGANIZATION EXTERNAL 
(
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY EXT_TAB_DATA
  ACCESS PARAMETERS 
  (
    RECORDS DELIMITED BY NEWLINE
    FIELDS TERMINATED BY ','
    MISSING FIELD VALUES ARE NULL 
    (
      country_code CHAR(5),
      country_name CHAR(50),
      country_language CHAR(50)
    )
  ) 
  LOCATION ('Countries1.txt','Countries2.txt')
)
PARALLEL 5 
REJECT LIMIT UNLIMITED;

Select * FROM countries_ext;
SELECT * FROM countries_ext WHERE country_language = 'English';

--Section 4 JSON
create table departments_json (
  department_id   integer not null primary key,
  department_data blob not null
);

alter table departments_json
  add constraint dept_data_json 
  check ( department_data is json );

insert into departments_json 
  values ( 110, utl_raw.cast_to_raw ( '{
  "department": "Accounting",
  "employees": [
    {
      "name": "Higgins, Shelley",
      "job": "Accounting Manager",
      "hireDate": "2002-06-07T00:00:00"
    },
    {
      "name": "Gietz, William",
      "job": "Public Accountant",
      "hireDate": "2002-06-07T00:00:00"
    }
  ]
}' ));

update departments_json
set    department_data = json_mergepatch ( 
         department_data,
         '{
           "department" : "Finance and Accounting"
         }'
       )
where  department_id = 110 ;

update departments_json
set    department_data = json_mergepatch ( 
         department_data,
         '{ "employees" :
  [ {
      "name" : "Gietz, William",
      "job" : "Public Accountant",
      "hireDate" : "2002-06-07T00:00:00"
    },
    {
      "name" : "Higgins, Shelley",
      "job" : "Accounting Manager",
      "hireDate" : "2002-06-07T00:00:00"
    },
    {
      "name" : "Chen, John",
      "job" : "Accountant",
      "hireDate" : "2005-09-28T00:00:00"
    },
    {
      "name" : "Greenberg, Nancy",
      "job" : "Finance Manager",
      "hireDate" : "2002-08-17T00:00:00"
    },
    {
      "name" : "Urman, Jose Manuel",
      "job" : "Accountant",
      "hireDate" : "2006-03-07T00:00:00"
    }
  ]
}'
       )
where  department_id = 110 ;

--OLD METHOD ABOVE NEW METHOD BELOW
update departments_json  
set    department_data = json_transform (
  department_data, 
  replace '$.department' = 'Finance and Accounting'
)
where  department_id = 110;

update departments_json  
set    department_data = json_transform (
  department_data, 
  insert '$.employees[last+1]' = (
    select d.department_data.employees[0]
    from   departments_json d  
    where  department_id = 100 
  )
)
where  department_id = 110;

update departments_json d
   set
   department_data = json_transform(department_data,
               replace '$.employees' =(
      select json_arrayagg(employee)
        from(
         select *
           from
            json_table(d.department_data,
               '$.employees[*]'
               columns(
                  employee json path '$[*]'
               )
            )
         union all
         select employee
           from departments_json j
         cross apply
            json_table(j.department_data,
                       '$.employees[*]'
               columns(
                  employee json path '$[*]'
               )
            )
          where department_id = 100
      )
   ))
where  department_id = 110;

update departments_json  
set    department_data = json_transform (
  department_data, 
  remove '$.employees'
)
where  department_id = 100;

update departments_json d
set    department_data = json_transform (
  department_data, 
  replace '$.employees' = (
     select json_arrayagg ( employee ) from (
       select * from json_table (
         d.department_data, '$.employees[*]'
         columns ( employee json path '$[*]' )
       )
       union all
       select employee from departments_json j
       cross apply json_table (
         j.department_data, '$.employees[*]'
         columns ( employee json path '$[*]' )
       )
       where  department_id = 100
    )
  ),
  replace '$.department' = 'Finance and Accounting'
)
where  department_id = 110;

--https://blogs.oracle.com/sql/post/how-to-store-query-and-create-json-documents-in-oracle-database