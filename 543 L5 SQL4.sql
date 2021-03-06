SELECT product_cd, trunc(sum(avail_balance),-4), rank() over (ORDER BY trunc(sum(avail_balance), -4) DESC)
FROM account 
GROUP BY product_cd;


SELECT product_cd, 
       trunc(sum(avail_balance),-4), 
       row_number() over (ORDER BY trunc(sum(avail_balance), -4) DESC)  seq,
       dense_rank() over (ORDER BY trunc(sum(avail_balance), -4) DESC) dense,
       rank() over (ORDER BY trunc(sum(avail_balance), -4) DESC) rank
FROM account 
GROUP BY product_cd;

SELECT product_cd, sum(avail_balance), cume_dist() over (ORDER BY sum(avail_balance) DESC)
FROM account 
GROUP BY product_cd;

SELECT product_cd, sum(avail_balance), sum(sum(avail_balance)) over (ORDER BY sum(avail_balance) DESC)  cumbalance
FROM account 
GROUP BY product_cd;

SELECT product_cd, sum(avail_balance), max(sum(avail_balance)) over (ORDER BY sum(avail_balance))
FROM account 
GROUP BY product_cd;

SELECT product_cd, sum(avail_balance), ratio_to_report(sum(avail_balance)) over () 
FROM account 
GROUP BY product_cd
ORDER BY sum(avail_balance);

-- AVG(...)  OVER(order by .....  Rows x preceding)
SELECT product_cd, sum(avail_balance), 
       avg(sum(avail_balance)) over (order by sum(avail_balance) rows 2 preceding) 
FROM account 
GROUP BY product_cd;

SELECT product_cd, to_char(open_date, 'YYYY'), sum(avail_balance)
FROM account
GROUP BY product_cd,to_char(open_date, 'YYYY');

--year
SELECT product_cd,to_char(open_date, 'YYYY'), 
       sum(avail_balance),
       rank() over (partition by to_char(open_date, 'YYYY') ORDER BY sum(avail_balance))  --partition by is placed before order by
FROM account
GROUP BY product_cd,to_char(open_date, 'YYYY');

--branch instead of year
SELECT product_cd, open_branch_id, sum(avail_balance),
       rank() over (partition by product_cd ORDER BY sum(avail_balance) DESC)
FROM account
GROUP BY product_cd, open_branch_id;

--grouping sets
SELECT product_cd, open_branch_id, sum(avail_balance)
FROM account
GROUP BY grouping sets(product_cd, open_branch_id);

select product_cd, open_branch_id, to_char(open_date, 'Month') Month, sum(avail_balance)
FROM account
GROUP BY grouping sets(product_cd, open_branch_id),to_char(open_date, 'Month');


SELECT product_cd, open_branch_id, to_char(open_date, 'Month') Month, sum(avail_balance)
FROM account
GROUP BY grouping sets(
    (product_cd, open_branch_id,to_char(open_date, 'Month')),
    (product_cd, open_branch_id),
    (product_cd, to_char(open_date, 'Month'))
    );   -- generate 57 rows

SELECT product_cd, open_branch_id, 
       to_char(open_date,'YYYY') Year,
       to_char(open_date, 'Month') Month,
       sum(avail_balance)
FROM account
GROUP BY grouping sets(product_cd, open_branch_id), grouping sets( to_char(open_date,'YYYY'), to_char(open_date, 'Month'));

-- manager, branch   vs  product  year  grouping sets for combinations
SELECT decode(m.lname, null, 'No Manager', m.lname) AS "Manager",
       b.name AS "Branch",
       p.name AS "Product",
       to_char(open_date, 'YYYY') AS "Year",
       to_char(sum(avail_balance), '$9,99,999.00') AS "Total"
FROM account  a
JOIN employee e ON a.open_emp_id = e.emp_id
JOIN branch b ON a.open_branch_id = b.branch_id
JOIN product p ON a.product_cd = p.product_cd
LEFT OUTER JOIN employee m ON e.superior_emp_id = m.emp_id
GROUP BY grouping sets(m.lname,b.name), grouping sets(p.name, to_char(open_date,'YYYY')) ;
     
-- hierarchy  emp manager   product product type
SELECT decode(m.lname, null, 'No Manager', m.lname) AS "Manager",
       e.lname AS "Teller",
       p.product_type_cd AS "ProductType",
       p.name AS "Product",
       sum(avail_balance) AS "Total"
FROM account a 
JOIN employee e ON a.open_emp_id = e.emp_id
LEFT OUTER JOIN employee m ON e.superior_emp_id = m.emp_id
JOIN product p ON a.product_cd = p.product_cd
GROUP BY rollup(m.lname, e.lname), rollup(p.product_type_cd, p.name);     ---- roll up from right to left
     
                                                                      
---------------------------
--miscellaneous queries.

--find the account with the highest balance
SELECT account_id
FROM account
WHERE avail_balance IN (SELECT max(avail_balance));
 
--find the account with the second highest balance
SELECT account_id
FROM account
WHERE avail_balance IN
     (SELECT max(avail_balance)
      FROM account
      WHERE avail_balance >
     (SELECT max(avail_balance) FROM account));

-- (a,b,c,d)
-- want to know, does the table have a primary key?
-- are there duplicates in the table? 
-- select *
-- from t1
-- group by (a,b,c,d) having count(*) > 1;

-- for example, find employee names for operations department.

SELECT employee.lname
FROM employee 
JOIN department
ON employee.dept_id = department.dept_id
WHERE department.name LIKE 'Operations';

-- if using subquery
SELECT lname
FROM employee
WHERE dept_id IN (SELECT dept_id FROM department WHERE name LIKE 'Operations');
     
-- join employee with itself
SELECT e1.lname, 'VS', e2.lname
FROM employee e1 
JOIN employee e2
ON e1.emp_id != e2.emp_id;
-- comparing to above
SELECT e1.lname, 'VS', e2.lname
FROM employee e1 
JOIN employee e2
ON e1.emp_id > e2.emp_id;

SELECT open_emp_id, product_cd
FROM account
ORDER BY open_emp_id;
      
-- who has opened more than one kind of account?
-- count kinds of accounts -- product_cd
-- count(product_cd) > 1

SELECT open_emp_id, count(distinct product_cd)
FROM account
GROUP BY open_emp_id
HAVING count(distinct product_cd)>1 ;

-- how many employees opened more than one kind of account?
SELECT count(*)
FROM
(SELECT open_emp_id, count(distinct product_cd)
FROM account
GROUP BY open_emp_id
HAVING count(distinct product_cd)>1 );
-- show the results then count them.

ALTER SESSION SET CURRENT_SCHEMA = msis543_sh;

SELECT channel_desc, country_id, sum(amount_sold) sales$
FROM sales 
JOIN  times 
ON sales.time_id = times.time_id
join customers
ON sales.cust_id = customers.cust_id
JOIN channels
ON sales.channel_id = channels.channel_id
WHERE channels.channel_desc IN ('Direct Sales', 'Internet')
AND country_id IN ('US', 'UK')
AND times.calendar_month_desc = '2000-09'
GROUP BY cube(channel_desc, country_id);
-- cube gives grand total and combination 

SELECT channel_desc, country_id, sum(amount_sold) sales$
FROM sales 
JOIN  times 
ON sales.time_id = times.time_id
join customers
ON sales.cust_id = customers.cust_id
join channels
ON sales.channel_id = channels.channel_id
WHERE channels.channel_desc IN ('Direct Sales', 'Internet')
AND country_id IN ('US', 'UK')
AND times.calendar_month_desc = '2000-09'
GROUP BY grouping sets(channel_desc, country_id);


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

