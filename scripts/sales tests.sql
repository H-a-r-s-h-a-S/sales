with test1 as (select id, count(1) from customers group by id having count(1) > 1),
test2 as (select transactionid, count(1) from transactions group by transactionid having count(1) > 1 ),
test3 as (select name, count(1) from rate group by name having count(1) > 1 ),
test4 as (select * from transactions where saledate is null or customer_id is null or item is null or rate is null or quantity is null or total is null or transactionid is null or cast(saledate as char)='' or customer_id='' or item='' or rate='' or quantity='' or total='' or transactionid='' ),
test5 as (select * from customers where id is null or id='' or email is null or email='' or name is null or name = ''),
test6 as (select * from rate where name is null or price is null or name='' or price=''),
test7 as (select transactionid, item, rate from transactions t join rate r on t.item=r.name where t.rate <> r.price ),
test8 as (select transactionid, rate, quantity, total from transactions where round((rate * quantity),2) <> round(total,2) ),
test9 as (select a.transactionid, a.saledate, a.item, a.customer_id, a.rate, a.quantity, a.total from transactions a where exists (select b.customer_id, b.item, b.saledate from transactions b where a.customer_id=b.customer_id and a.saledate=b.saledate and a.item=b.item group by b.customer_id, b.item, b.saledate having count(1) > 1 ) order by customer_id, saledate, item),
test10 as (select item from transactions where not exists (select name from rate) )

select 'TEST 1' test_case_id, 'duplicate customer records in customers table' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test1 
union all
select 'TEST 2' test_case_id, 'duplicate records in transaction table' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test2 
union all
select 'TEST 3' test_case_id, 'duplicate entries in rate table' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test3 
union all
select 'TEST 4' test_case_id, 'null data' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test4 
union all
select 'TEST 5' test_case_id, 'null data' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test5 
union all
select 'TEST 6' test_case_id, 'null data' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test6 
union all
select 'TEST 7' test_case_id, 'item from transactions not having the correct amount' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test7 
union all
select 'TEST 8' test_case_id, 'total amount is calculated correctly ?' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test8 
union all
select 'TEST 9' test_case_id, 'same item bought by same person on the same day' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test9 
union all
select distinct 'TEST 10' test_case_id, 'unexpected item' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test10  ;