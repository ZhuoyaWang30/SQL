select product_cd, sum(avail_balance), rank() over (order by sum(avail_balance) desc)
from account 
group by product_cd;
-- rank() is oracle specific.

select product_cd, trunc(sum(avail_balance),-4), rank() over (order by trunc(sum(avail_balance), -4) desc)
from account 
group by product_cd;


select product_cd, 
trunc(sum(avail_balance),-4), 
row_number() over (order by trunc(sum(avail_balance), -4) desc)  seq,
dense_rank() over (order by trunc(sum(avail_balance), -4) desc) dense,
rank() over (order by trunc(sum(avail_balance), -4) desc) rank
from account 
group by product_cd;

-- cumulative distribution = probability 
select product_cd, sum(avail_balance), cume_dist() over (order by sum(avail_balance) desc)
from account 
group by product_cd;

--2. SUM(...)    MAX(....)   AVG(....)  RATIO_TO_REPORT(...)   OVER ()
select product_cd, sum(avail_balance), 
sum(sum(avail_balance)) over (order by sum(avail_balance) desc)  cumbalance
from account 
group by product_cd;

select product_cd, sum(avail_balance), 
    max(sum(avail_balance)) over (order by sum(avail_balance))  --() after over can be empty
    
    from account group by product_cd;

select product_cd, sum(avail_balance), 
    ratio_to_report(sum(avail_balance)) over ()    --x/sum(x)  () must be empty
 from account group by product_cd
    order by sum(avail_balance);

  -- AVG(...)  OVER(order by .....  Rows x preceding)
select product_cd, sum(avail_balance), 
    avg(sum(avail_balance)) over (order by sum(avail_balance) rows 2 preceding)  -- rows 2 preceding means moving average 
    
    from account group by product_cd;
--WINDOW FUNCTION???

-- PARTITION BY
select product_cd, to_char(open_date, 'YYYY'), sum(avail_balance)
from account
group by product_cd,to_char(open_date, 'YYYY');

select product_cd,to_char(open_date, 'YYYY'), 
sum(avail_balance),
rank() over (partition by to_char(open_date, 'YYYY') order by sum(avail_balance))  -- partition by is placed before order by
from account
group by product_cd,to_char(open_date, 'YYYY');

--branch instead of year
select product_cd, open_branch_id, sum(avail_balance),
      rank() over (partition by product_cd order by sum(avail_balance) desc)
from account
group by product_cd, open_branch_id;

-------

---grouping sets
select product_cd, open_branch_id, sum(avail_balance)
from account
group by grouping sets(product_cd, open_branch_id);

select product_cd, open_branch_id, to_char(open_date, 'Month') Month, sum(avail_balance)
from account
group by grouping sets(product_cd, open_branch_id),to_char(open_date, 'Month');


select product_cd, open_branch_id, to_char(open_date, 'Month') Month, sum(avail_balance)
from account
group by grouping sets(
    (product_cd, open_branch_id,to_char(open_date, 'Month')),
    (product_cd, open_branch_id),
    (product_cd, to_char(open_date, 'Month'))
    );   -- generate 57 rows

select product_cd, open_branch_id, to_char(open_date, 'Month') Month, sum(avail_balance)
from account
group by cube(product_cd, open_branch_id,to_char(open_date, 'Month'));  -- generate 97 rows

select product_cd, open_branch_id, 
   to_char(open_date,'YYYY') Year,
   to_char(open_date, 'Month') Month,
   sum(avail_balance)
   
   from account
   group by  grouping sets(product_cd, open_branch_id),
             grouping sets( to_char(open_date,'YYYY'), to_char(open_date, 'Month'));
-- hierarchy 

--  manager, branch   vs  product  year  grouping sets for combinations

select  decode(m.lname, null, 'No Manager', m.lname) as "Manager",
        b.name as "Branch",
        p.name as "Product",
        to_char(open_date, 'YYYY') as "Year",
        to_char(sum(avail_balance), '$9,99,999.00') as "Total"

from account  a
      join employee e on a.open_emp_id = e.emp_id
      
      join branch b on a.open_branch_id = b.branch_id
      join product p on a.product_cd = p.product_cd
      left outer join  employee m on e.superior_emp_id = m.emp_id

group by 
     grouping sets(m.lname,b.name),
     grouping sets(p.name, to_char(open_date,'YYYY')) ;
     
-- hierarchy  emp manager   product product type

select 
       decode(m.lname, null, 'No Manager', m.lname) as "Manager",
       e.lname as "Teller",
       p.product_type_cd as "ProductType",
       p.name as "Product",
       sum(avail_balance) as "Total"
       
from  account a 
      join employee e on a.open_emp_id = e.emp_id
      left outer join employee m on e.superior_emp_id = m.emp_id
      join product p on a.product_cd = p.product_cd
group by
     rollup(m.lname, e.lname),       ---- roll up from right to left
     rollup(p.product_type_cd, p.name); 
     


---------------------------
--miscellaneous queries.

--find the account with the highest balance
select account_id
from account
where avail_balance in
 ( select max(avail_balance) );
 
-- find the account with the second highest balance

select account_id
from account
where avail_balance in
(
select max(avail_balance)
from account
where avail_balance >
( select max(avail_balance) from account ));

-- (a,b,c,d)
-- want to know, does the table have a pk?
-- are there duplicates in the table? 

-- select *
-- from t1
-- group by (a,b,c,d) having count(*) > 1;

-- find employee names for operations department.

select employee.lname
from employee join department
on employee.dept_id = department.dept_id

where department.name like 'Operations';

-- subquery
select lname
from employee
where dept_id in (select dept_id from department where name like 'Operations');
     
-- join employee with itself

select e1.lname, 'VS', e2.lname
from employee e1 join employee e2
on e1.emp_id != e2.emp_id;
-- comparing to above
select e1.lname, 'VS', e2.lname
from employee e1 join employee e2
on e1.emp_id > e2.emp_id;

select open_emp_id, product_cd
from account
order by open_emp_id;
-- who has opened more than one kind of account?
-- count kinds of accounts -- product_cd
-- count(product_cd) > 1
-- group by 
select open_emp_id, count(distinct product_cd)
from account
group by open_emp_id
having count(distinct product_cd)>1 ;

-- how many employees opened more than one kind of account?
select count(*)
from
(select open_emp_id, count(distinct product_cd)
from account
group by open_emp_id
having count(distinct product_cd)>1 );
-- show the results then count them.

ALTER SESSION SET CURRENT_SCHEMA = msis543_sh;

SELECT channel_desc, country_id, sum(amount_sold) sales$
FROM sales JOIN  times 
ON sales.time_id = times.time_id
join customers
ON sales.cust_id = customers.cust_id
join channels
ON sales.channel_id = channels.channel_id
WHERE channels.channel_desc IN ('Direct Sales', 'Internet')
AND country_id IN ('US', 'UK')
AND times.calendar_month_desc = '2000-09'
group by cube(channel_desc, country_id);
-- cube gives grand total and combination 

SELECT channel_desc, country_id, sum(amount_sold) sales$
FROM sales JOIN  times 
ON sales.time_id = times.time_id
join customers
ON sales.cust_id = customers.cust_id
join channels
ON sales.channel_id = channels.channel_id
WHERE channels.channel_desc IN ('Direct Sales', 'Internet')
AND country_id IN ('US', 'UK')
AND times.calendar_month_desc = '2000-09'
group by grouping sets(channel_desc, country_id);


SELECT channel_desc, country_id, cust_gender,sum(amount_sold) sales$
FROM sales JOIN  times 
ON sales.time_id = times.time_id
join customers
ON sales.cust_id = customers.cust_id
join channels
ON sales.channel_id = channels.channel_id
WHERE channels.channel_desc IN ('Direct Sales', 'Internet')
AND country_id IN ('US', 'UK')
AND times.calendar_month_desc = '2000-09'
GROUP BY grouping sets(country_id, channel_desc), cust_gender;
-- country to gender and channel to gender


SELECT channel_desc, calendar_month_desc, country_id,
   TO_CHAR(SUM(amount_sold), '$9,999,999,999.99') SALES$ 
FROM sales JOIN customers
ON sales.cust_id=customers.cust_id
JOIN times
ON sales.time_id=times.time_id
JOIN channels
ON sales.channel_id= channels.channel_id
WHERE   channels.channel_desc IN ('Direct Sales', 'Internet') AND 
   times.calendar_month_desc IN ('2000-09', '2000-10')
   AND country_id IN ('UK', 'US')
GROUP BY channel_desc, rollup(calendar_month_desc, country_id);


SELECT channel_desc, calendar_month_desc, country_id, 
   TO_CHAR(SUM(amount_sold), '9,999,999,999') SALES$ 
FROM sales JOIN customers
ON  sales.cust_id=customers.cust_id
JOIN times
ON  sales.time_id=times.time_id
JOIN channels
on sales.channel_id= channels.channel_id
WHERE  
   channels.channel_desc IN ('Direct Sales', 'Internet') AND 
   times.calendar_month_desc IN ('2000-09', '2000-10')
   AND country_id IN ('UK', 'US')
GROUP BY GROUPING SETS((channel_desc, calendar_month_desc, country_id),
    (channel_desc, country_id), (calendar_month_desc, country_id));
--------------------
-- run query from 543:SQL for OLAP:2:Aggregation Queries: Using Oracle

select * from employee;
--current_schema = msis 543_00;



