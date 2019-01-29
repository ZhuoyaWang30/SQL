-- 10/17/18
-- Who manages Helen Fleming?
select superior_emp_id
from employee
where emp_id = 6;

select fname, lname
from employee
where emp_id = 4;

select fname, lname     -- master query
from employee
where emp_id = 
      (select superior_emp_id
      from employee
      where fname like 'Helen' and lname like 'Fleming');   -- subquery
      
-- name managers.
select fname, lname
from employee
where emp_id IN
   ?select distinct superior_emp_id from employee);
   -- always use IN, not the = sign.
   -- after = is expected be a single value like 1, 3, 4
   --In translates to = value 1 or value 2 or value 3...
   
-- IN does not care about duplicates.   
-- IN also does not care about ? null.

-- Who does not manage anyone?
select fname, lname
from employee
where emp_id NOT IN
   ?select distinct superior_emp_id from employee
     where superior_emp_id is not null);
-- NOT IN is translated into != value 1 AND != value 2 AND ....

-- doing NOT IN or !=? always include a condition for excluding nulls.

-- max balance for each product. "each product" so use "group by"
select product_cd, max(avail_balance)
from account
group by product_cd;

--which account has the highest balance in checking account?
select account_id, product_cd, avail_balance
from account
where avail_balance =
     (select max(avail_balance)
     from account
     where product_cd like 'CHK')
     and product_cd like 'CHK';

-- join with a subquery!!!!! Very useful
select a.account_id, a.product_cd, MaxQuery.maxbal
from
account a join    
(select product_cd, max(avail_balance) maxbal
from account
group by product_cd)  MaxQuery

on a.product_cd = MaxQuery.product_cd     

where a.avail_balance = MaxQuery.maxbal;

--Find accounts with balance higher than average balance within each product class:

select a.ACCOUNT_ID, a.PRODUCT_CD, a.AVAIL_BALANCE
from account a join 
(select PRODUCT_CD, avg(AVAIL_BALANCE) as HI
from account 
group by PRODUCT_CD) HIQUERY
on a.PRODUCT_CD = HIQUERY.PRODUCT_CD
where a.avail_balance > HIQUERY.HI;
     
select * from individual;
select * from business;

select *
from individual
union
select *
from business;  --captions from first table, works only if columns aligned,
--and may not be meaningful

SELECT cust_id, lname as name FROM individual
UNION
select cust_id, name from business;

SELECT cust_id, lname as name, 'Individual' as "Customer Type" FROM individual
UNION
select cust_id, name, 'Business' from business;

--EER Join /Union Join
--no results will show
select customer.*, individual.*, business.*
from
   customer join individual on customer.cust_id = individual.cust_id
   join business on customer.cust_id = business.cust_id;

-- adding left outer (comapre with above)
select customer.*, individual.*
from
   customer left outer join individual on customer.cust_id = individual.cust_id;  -- adding left outer
   
-- has result adding left outer
select customer.*, individual.*, business.*
from
   customer left outer join individual on customer.cust_id = individual.cust_id
   left outer join business on customer.cust_id = business.cust_id;              -- adding left outer
   
select a.account_id, i.lname, b.name
from account a left outer join individual i on a.cust_id = i.cust_id
left outer join business b on a.cust_id = b.cust_id;
  
select a.account_id, 
decode(c.cust_type_cd, 'I', i.lname,b.name)

from account a join customer c on a.cust_id = c.cust_id
left outer join individual i on a.cust_id = i.cust_id
left outer join business b on a.cust_id = b.cust_id;

-- case...when...then

-- below method is better than above "decode" one
select a.account_id, 
   case
     when c.cust_type_cd = 'I'
        then i.lname
     when c.cust_type_cd = 'B'
        then b.name
     else
        'Unknown'
   end   name
from account a join customer c on a.cust_id = c.cust_id
left outer join individual i on a.cust_id = i.cust_id
left outer join business b on a.cust_id = b.cust_id;

-- value banding
select account_id, PRODUCT_CD,avail_balance,
   case
      when avail_balance <= 1000
      then 'Low'
      when avail_balance <= 10000
      then 'Medium'
      else
      'High'
    end tier
    
    from account;
     
-- view
create or replace view acc_tiers(id, product, balance, tier)
as (
select account_id, PRODUCT_CD,avail_balance,
   case
      when avail_balance <= 1000
      then 'Low'
      when avail_balance <= 10000
      then 'Medium'
      else
      'High'
    end tier
    
    from account);
    
    select * from acc_tiers;

    
select product, tier, sum(balance)
from acc_tiers
group by cube(product,tier);

select decode(grouping(PRODUCT),1,'All Products', product) product,
decode(grouping(tier),1,'All Tiers',Tier) tier, 
count(*) Count, 
to_char(trunc(sum(balance),-2),'$9,99,999') Balance
    from acc_tiers
    group by cube(tier, product);
    
--decode(product,null,'All Product', product)   
select ac.id, p.name, ac.tier
    from acc_tiers ac join product p on ac.product = p.product_cd;
     
select  p.name, ac.tier, count(*)
    from acc_tiers ac join product p on ac.product = p.product_cd
    
    group by p.name, ac.tier;
    
    
    select fname || '  ' || lname  name ,
        case
          when title = 'Head Teller'
             then 'Head Teller'
          when title = 'Teller' and to_char(start_date, 'YYYY') <= 2001
          then 'Experienced Teller'
          when title = 'Teller' and to_char(start_date, 'YYYY') >= 2003
             then 'Novice'
          else   'Teller'
        end  title,
        to_char(start_date, 'YYYY')
        
        from employee where title in('Teller', 'Head Teller');
        
        
-- reviewing results of query below shows some
-- customers operate both checking and cd accounts.        
select cust_id, product_cd
from account
where product_cd in ('CHK','CD')
order by cust_id;

select chkquery.cust_id, cdquery.cust_id
from
(select cust_id
from account
where product_cd = 'CHK') chkquery

join
(select cust_id
from account
where product_cd = 'CD') cdquery

on chkquery.cust_id= cdquery.cust_id;


select cust_id
from account
where product_cd like 'CHK'

intersect

select cust_id
from account
where product_cd like 'CD';

---union intersect except (subtraction)  union all intersect all etc. to make more efficient.

alter session set current_schema = msis543_sh;      -- msis543_sh in file"other use" and throll all the way down




    
     
     
     
     
     
     
     






