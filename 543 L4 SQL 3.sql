--Who manages "Helen Fleming"?
SELECT superior_emp_id
FROM employee
WHERE emp_id = 6;

SELECT fname, lname
FROM employee
WHERE emp_id = 4;

SELECT fname, lname     
FROM employee
WHERE emp_id = 
      (SELECT superior_emp_id
      FROM employee
      WHERE fname LIKE 'Helen' AND lname LIKE 'Fleming');   
      
-- We can name managers.
SELECT fname, lname
FROM employee
WHERE emp_id IN
   ?select DISTINCT superior_emp_id FROM employee);
   
-- Who does not manage anyone?
SELECT fname, lname
FROM employee
WHERE emp_id NOT IN
   ?select DISTINCT superior_emp_id FROM employee
     WHERE superior_emp_id IS NOT null);

SELECT product_cd, max(avail_balance)
FROM account
GROUP BY product_cd;

--which account has the highest balance in checking account?
SELECT account_id, product_cd, avail_balance
FROM account
WHERE avail_balance =
     (SELECT max(avail_balance)
     FROM account
     WHERE product_cd LIKE 'CHK')
     AND product_cd LIKE 'CHK';

-- join with a subquery!!!!! Very useful
SELECT a.account_id, a.product_cd, MaxQuery.maxbal
FROM
account a JOIN    
(SELECT product_cd, max(avail_balance) maxbal
FROM account
GROUP BY product_cd)  MaxQuery

ON a.product_cd = MaxQuery.product_cd     

WHERE a.avail_balance = MaxQuery.maxbal;

--Find accounts with balance higher than average balance within each product class:

SELECT a.ACCOUNT_ID, a.PRODUCT_CD, a.AVAIL_BALANCE
FROM account a JOIN
(SELECT PRODUCT_CD, avg(AVAIL_BALANCE) AS HI
FROM account 
GROUP BY PRODUCT_CD) HIQUERY
ON a.PRODUCT_CD = HIQUERY.PRODUCT_CD
WHERE a.avail_balance > HIQUERY.HI;
     
SELECT *
FROM individual
UNION
SELECT *
FROM business;  
--captions from first table, works only if columns aligned,
--and may not be meaningful

SELECT cust_id, lname AS name FROM individual
UNION
SELECT cust_id, name FROM business;

SELECT cust_id, lname AS name, 'Individual' AS "Customer Type" FROM individual
UNION
SELECT cust_id, name, 'Business' FROM business;

--EER Join /Union Join
SELECT customer.*, individual.*, business.*
FROM customer 
   JOIN individual ON customer.cust_id = individual.cust_id
   JOIN business ON customer.cust_id = business.cust_id;
   
-- adding left outer
SELECT customer.*, individual.*, business.*
FROM customer 
   left outer JOIN individual ON customer.cust_id = individual.cust_id
   left outer JOIN business ON customer.cust_id = business.cust_id;             
   
SELECT a.account_id, i.lname, b.name
FROM account a 
   left outer JOIN individual i ON a.cust_id = i.cust_id
   left outer JOIN business b ON a.cust_id = b.cust_id;
  
SELECT a.account_id, 
decode(c.cust_type_cd, 'I', i.lname,b.name)
FROM account a 
   JOIN customer c ON a.cust_id = c.cust_id
   left outer JOIN individual i ON a.cust_id = i.cust_id
   left outer JOIN business b ON a.cust_id = b.cust_id;

-- case...when...then

-- below method is better than above "decode" one
SELECT a.account_id, 
   case
     when c.cust_type_cd = 'I'
        then i.lname
     when c.cust_type_cd = 'B'
        then b.name
     else
        'Unknown'
   end   name
FROM account a 
    JOIN customer c ON a.cust_id = c.cust_id
    left outer JOIN individual i ON a.cust_id = i.cust_id
    left outer JOIN business b ON a.cust_id = b.cust_id;

-- value banding
SELECT account_id, PRODUCT_CD,avail_balance,
   case
      when avail_balance <= 1000
      then 'Low'
      when avail_balance <= 10000
      then 'Medium'
      else
      'High'
    end tier
    
    FROM account;
     
SELECT product, tier, sum(balance)
FROM acc_tiers
GROUP BY cube(product,tier);

SELECT decode(grouping(PRODUCT),1,'All Products', product) product,
decode(grouping(tier),1,'All Tiers',Tier) tier, 
COUNT(*) Count, 
to_char(trunc(sum(balance),-2),'$9,99,999') Balance
    FROM acc_tiers
    GROUP BY cube(tier, product);
    
--decode(product,null,'All Product', product)   
SELECT ac.id, p.name, ac.tier
    FROM acc_tiers ac JOIN product p ON ac.product = p.product_cd;
     
SELECT p.name, ac.tier, COUNT(*)
    FROM acc_tiers ac JOIN product p ON ac.product = p.product_cd
    GROUP BY p.name, ac.tier;
    
    
SELECT fname || '  ' || lname  name ,
        case
          when title = 'Head Teller'
             then 'Head Teller'
          when title = 'Teller' AND to_char(start_date, 'YYYY') <= 2001
          then 'Experienced Teller'
          when title = 'Teller' AND to_char(start_date, 'YYYY') >= 2003
             then 'Novice'
          else   'Teller'
        end  title,
        to_char(start_date, 'YYYY')
        
        FROM employee WHERE title IN('Teller', 'Head Teller');
        
-- reviewing results of query below shows some
-- customers operate both checking and cd accounts.        
SELECT cust_id, product_cd
FROM account
WHERE product_cd IN ('CHK','CD')
ORDER BY cust_id;

SELECT chkquery.cust_id, cdquery.cust_id
FROM
(SELECT cust_id
FROM account
WHERE product_cd = 'CHK') chkquery

JOIN
(SELECT cust_id
FROM account
WHERE product_cd = 'CD') cdquery
ON chkquery.cust_id= cdquery.cust_id;

SELECT cust_id
FROM account
WHERE product_cd LIKE 'CHK'

INTERSECT

SELECT cust_id
FROM account
WHERE product_cd LIKE 'CD';

---union intersect except (subtraction)  union all intersect all etc. to make more efficient.
