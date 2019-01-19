select account_id, p.name, b.name
from account a join product p on a.product_cd = p.product_cd
join branch b on a.open_branch_id = b.branch_id;

-- show number of accounts with balance above 1000,
-- per product and branch
-- only for where the count exceeds 2,
-- excluding accounts opened at Headquarters
select p.name, b.name, count(a.account_id)
from account a join product p on a.product_cd = p.product_cd
join branch b on a.open_branch_id = b.branch_id
where b.name not like 'Headquarters'
and a.avail_balance > 1000
group by p.name, b.name
having count(a.account_id) > 2;



---------------
-- show account id, name of branch opened at, and name of branch
-- where the employee who opened the account works at


select a.account_id, b.name as "Opened At", eb.name as "Emp Branch"
from account a join branch b on a.open_branch_id = b.branch_id
    join employee e on a.open_emp_id = e.emp_id
    join branch eb on e.assigned_branch_id = b.branch_id; 
-- the new nickname ensures we are joining with a different copy of the branch table.
-- required, in case the two branch names are different.
-- this is due to sql in general, and join in particular, working with one row at a time.

-- employee last names, and managers last names

select emp.lname as "Empoyee", 'Report to', mgr.lname as "Manager"
from employee emp join employee mgr
on emp.superior_emp_id = mgr.emp_id;

-- when we compare our query results(17 rows) with the employee table(18 rows)(because the 1st row: Micheal superior id is null)
-- null is not equal to anything
-- nor is null not equal to anything 

-- 'inner join'  only actual matches reported.

-- By adding "left outer before join", the query result gives 18 rows this time with the null item
-- left outer join: Return all records from the left table, and the matched records from the right table
select emp.lname as "Empoyee", 'Report to', mgr.lname as "Manager"
from employee emp left outer join employee mgr
on emp.superior_emp_id = mgr.emp_id;

-- "right outer" includes employees who do not manage anyone.
-- right outer join: Return all records from the right table, and the matched records from the left table
select emp.lname as "Empoyee", 'Report to', mgr.lname as "Manager"
from employee emp right outer join employee mgr
on emp.superior_emp_id = mgr.emp_id;

-- cross join : cross product of the two tables, every possible combination.

-- (codes copied from the online lecture notes Worksheet1=sql practice 2)
select  product_cd, open_branch_id, to_char(open_date, 'YYYY'), sum(avail_balance)
from account
group by product_cd, open_branch_id, to_char(open_date, 'YYYY')
order by to_char(open_date, 'YYYY'), sum(avail_balance) desc;

-- same query, with rollup, which will generate sub-totals
select  product_cd, open_branch_id, to_char(open_date, 'YYYY'), sum(avail_balance)
from account
group by rollup(product_cd, open_branch_id, to_char(open_date, 'YYYY'));
-- order by to_char(open_date, 'YYYY'), sum(avail_balance) desc;
-- (in order to compare with previous one)

-- to_char (short stand of character) and rollup are specific to Oracle.

select 
  to_char(open_date, 'YYYY') as Year ,
  decode(to_char(open_date, 'YYYY-Month'),null, 'All Months',to_char(open_date, 'YYYY-Month')) as Month ,
  decode(product_cd,null,'All Products', product_cd) as Product,
  decode(open_branch_id, null, 'All Branches', open_branch_id) as Branch,
  to_char(round(sum(avail_balance),-2),'$9,99,999.99') as "Total Balance"

from account
group by rollup(to_char(open_date, 'YYYY'),to_char(open_date, 'YYYY-Month'),product_cd, open_branch_id);

-- decode(mgr.lname, null, 'No One', mgr.lname)
-- means if mgr.lname is null then show "No One", otherwise show mgr.lname


select  
to_char(open_date, 'YYYY') as Year ,  --captions
to_char(open_date, 'YYYY-Month') as Month ,
product_cd, 
Open_branch_id,
sum(avail_balance)
from account
group by to_char(open_date, 'YYYY'),to_char(open_date, 'YYYY-Month'),product_cd, open_branch_id
order by Year, Month, Sum(avail_balance) desc; --can use captions in ordering
-- same query, with rollup generate sub-totals
select  
to_char(open_date, 'YYYY') as Year ,
to_char(open_date, 'YYYY-Month') as Month ,
product_cd, 
Open_branch_id,
sum(avail_balance)
from account
group by rollup(to_char(open_date, 'YYYY'),to_char(open_date, 'YYYY-Month'),product_cd, open_branch_id)
order by Year, Month, Sum(avail_balance) desc;


    
    
    