SELECT account_id, p.name, b.name
FROM account a JOIN product p ON a.product_cd = p.product_cd
JOIN branch b ON a.open_branch_id = b.branch_id;

-- show number of accounts with balance above 1000 per product and branch
-- only for where the count exceeds 2,
-- excluding accounts opened at Headquarters
SELECT p.name, b.name, COUNT(a.account_id)
FROM account a JOIN product p ON a.product_cd = p.product_cd
JOIN branch b ON a.open_branch_id = b.branch_id
WHERE b.name NOT LIKE 'Headquarters'
AND a.avail_balance > 1000
GROUP BY p.name, b.name
HAVING COUNT(a.account_id);

-- show account id, name of branch opened at, and name of branch
-- where the employee who opened the account works at
SELECT a.account_id, b.name AS "Opened At", eb.name AS "Emp Branch"
FROM account a 
    JOIN branch b ON a.open_branch_id = b.branch_id
    JOIN employee e ON a.open_emp_id = e.emp_id
    JOIN branch eb ON e.assigned_branch_id = b.branch_id; 

-- the new nickname ensures we are joining with a different copy of the branch table.
-- required, in case the two branch names are different.
-- this is due to sql in general, and join in particular, working with one row at a time.
-- employee last names, and managers last names
SELECT emp.lname AS "Empoyee", 'Report to', mgr.lname AS "Manager"
FROM employee emp 
JOIN employee mgr ON emp.superior_emp_id = mgr.emp_id;

-- when we compare our query results(17 rows) with the employee table(18 rows)(because the 1st row: Micheal superior id is null)
-- null is not equal to anything
-- nor is null not equal to anything 

-- 'inner join'  only actual matches reported.

-- By adding "left outer before join", the query result gives 18 rows this time with the null item
-- left outer join: Return all records from the left table, and the matched records from the right table
SELECT emp.lname AS "Empoyee", 'Report to', mgr.lname AS "Manager"
FROM employee emp left outer 
JOIN employee mgr ON emp.superior_emp_id = mgr.emp_id;

-- "right outer" includes employees who do not manage anyone.
-- right outer join: Return all records from the right table, and the matched records from the left table
SELECT emp.lname AS "Empoyee", 'Report to', mgr.lname AS "Manager"
FROM employee emp right outer 
JOIN employee mgr ON emp.superior_emp_id = mgr.emp_id;

-- cross join : cross product of the two tables, every possible combination.
SELECT  product_cd, open_branch_id, to_char(open_date, 'YYYY'), sum(avail_balance)
FROM account
GROUP BY product_cd, open_branch_id, to_char(open_date, 'YYYY')
ORDER BY to_char(open_date, 'YYYY'), sum(avail_balance) desc;

-- same query, with rollup, which will generate sub-totals
SELECT product_cd, open_branch_id, to_char(open_date, 'YYYY'), sum(avail_balance)
FROM account
GROUP BY rollup(product_cd, open_branch_id, to_char(open_date, 'YYYY'));
-- order by to_char(open_date, 'YYYY'), sum(avail_balance) desc;
-- (in order to compare with previous one)

-- to_char (short stand of character) and rollup are specific to Oracle.
SELECT
  to_char(open_date, 'YYYY') as Year ,
  decode(to_char(open_date, 'YYYY-Month'),null, 'All Months',to_char(open_date, 'YYYY-Month')) as Month ,
  decode(product_cd,null,'All Products', product_cd) as Product,
  decode(open_branch_id, null, 'All Branches', open_branch_id) as Branch,
  to_char(round(sum(avail_balance),-2),'$9,99,999.99') as "Total Balance"
FROM account
GROUP BY rollup(to_char(open_date, 'YYYY'),to_char(open_date, 'YYYY-Month'),product_cd, open_branch_id);

-- decode(mgr.lname, null, 'No One', mgr.lname)
-- means if mgr.lname is null then show "No One", otherwise show mgr.lname
SELECT
to_char(open_date, 'YYYY') AS Year ,  
to_char(open_date, 'YYYY-Month') AS Month ,
product_cd, 
Open_branch_id,
sum(avail_balance)
GROUP BY to_char(open_date, 'YYYY'),to_char(open_date, 'YYYY-Month'),product_cd, open_branch_id
ORDER BY Year, Month, Sum(avail_balance) DESC; 

-- same query, with rollup generate sub-totals
SELECT
to_char(open_date, 'YYYY') AS Year ,
to_char(open_date, 'YYYY-Month') AS Month ,
product_cd, 
Open_branch_id,
sum(avail_balance)
FROM account
GROUP BY rollup(to_char(open_date, 'YYYY'),to_char(open_date, 'YYYY-Month'),product_cd, open_branch_id)
ORDER BY Year, Month, Sum(avail_balance) DESC;
 
    
