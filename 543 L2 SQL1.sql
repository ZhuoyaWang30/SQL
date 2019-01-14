-- show employee last names and start dates

SELECT lname, start_date
FROM employee
ORDER BY lname DESC;

SELECT lname AS "Last", start_date AS "Started On"  
FROM employee
WHERE title  LIKE 'Teller'  
  AND start_date  LIKE '%02' 
  AND lname LIKE  '%er'   
ORDER BY start_date DESC;

-- start_date > '31-DEC-02'

SELECT emp_id, dept_id
FROM employee
ORDER BY dept_id;

-- GROUP BY

SELECT dept_id, COUNT(emp_id), min(start_date), max(start_date)
FROM employee
GROUP BY dept_id;

-- depts with > 1 employee?
SELECT dept_id
FROM employee
WHERE title LIKE 'Teller'
GROUP BY dept_id
HAVING COUNT(*) > 1;  

SELECT *
FROM department;

SELECT product_cd, open_branch_id, sum(avail_balance)
FROM account
GROUP BY product_cd, open_branch_id;

-- Drill Down vs Roll Up

SELECT emp_id, dept_id
FROM employee;

SELECT e.LNAME, d.NAME, b.name
FROM employee e
        JOIN department d  
            ON e.dept_id = d.dept_id
        JOIN branch b
            ON e.assigned_branch_id = b.branch_id;
            
                 
CREATE view emp_full(name,department, branch)
AS
            
SELECT e.LNAME, d.NAME, b.name
FROM employee e
        JOIN department d  
            ON e.dept_id = d.dept_id
        JOIN branch b
            ON e.assigned_branch_id = b.branch_id;
            
            
SELECT name, branch, department
FROM emp_full
WHERE department LIKE 'Operations';

-- show total balance by branch and product names
-- joins with branch and product
-- group by on branch name and product name

SELECT p.name, b.name, sum(a.avail_balance)
FROM  account a 
         JOIN product p 
             ON a.product_cd = p.product_cd
         JOIN branch b 
             ON a.open_branch_id = b.branch_id
 GROUP BY p.name, b.name;

--select product_fat_content, store, sum(sales$)
--from  sales_fact join product_dim on sales_fact.product_key = product_dim.product_key
-- join store_dim on sales_fact.store_key = store_dim.store_key
--group by product_dim.product_fat_content, store_dim.store;

-- Show Department names, Branch Names, and number of employees for each such combination.
-- employee join department      dept_id
-- join branch     assigned_branch_id = branch_id

SELECT d.name,b.name, count(*)
FROM employee e JOIN department d ON e.dept_id = d.dept_id
    JOIN branch b ON e.assigned_branch_id = b.branch_id
    
GROUP BY d.name, b.name
ORDER BY count(*) DESC;
