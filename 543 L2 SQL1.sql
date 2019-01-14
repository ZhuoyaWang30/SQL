-- show employee last names and start dates

SELECT lname, start_date
FROM employee
ORDER by lname desc;

SELECT lname as "Last", start_date as "Started On"  
FROM employee
WHERE title  like 'Teller'  
  and start_date  like '%02' 
  and lname like  '%er'   
ORDER by start_date desc;

-- start_date > '31-DEC-02'

SELECT emp_id, dept_id
FROM employee
ORDER by dept_id;

-- GROUP BY

SELECT  dept_id, count(emp_id), min(start_date), max(start_date)
FROM employee
GROUP BY dept_id;

-- depts with > 1 employee?
SELECT dept_id
FROM employee
WHERE title like 'Teller'
GROUP BY dept_id
HAVING count(*) > 1;  -- * designates each row.

select *
from department;

select product_cd, open_branch_id, sum(avail_balance)
from account
group by product_cd, open_branch_id;

-- Drill Down vs Roll Up

select emp_id, dept_id
from employee;

select  e.LNAME, d.NAME, b.name
from employee e
        join department d  -- nicknames introduced
            on e.dept_id = d.dept_id
        join branch b
            on e.assigned_branch_id = b.branch_id;
            
                 
create view emp_full(name,department, branch)
as
            
select  e.LNAME, d.NAME, b.name
from employee e
        join department d  -- nicknames introduced
            on e.dept_id = d.dept_id
        join branch b
            on e.assigned_branch_id = b.branch_id;
            
            
select name, branch, department
from emp_full
where department like 'Operations';

-- show total balance by branch and product names
-- joins with branch and product
-- group by on branch name and product name

select  p.name, b.name, sum(a.avail_balance)
from   account a join product p on a.product_cd = p.product_cd
        join branch b on a.open_branch_id = b.branch_id
        
group by p.name, b.name;

--select product_fat_content, store, sum(sales$)
--from  sales_fact join product_dim on sales_fact.product_key = product_dim.product_key
--   join store_dim on sales_fact.store_key = store_dim.store_key
   
--group by product_dim.product_fat_content, store_dim.store;

-- Show Department names, Branch Names, and number of employees for each such combination.

-- employee join department      dept_id
-- join branch     assigned_branch_id = branch_id

select d.name,b.name, count(*)
from employee e join department d on e.dept_id = d.dept_id
    join branch b on e.assigned_branch_id = b.branch_id
    
group by d.name, b.name
order by count(*) desc;
