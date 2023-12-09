-- MySQL Script generated by MySQL Workbench
-- Sunday 10 December 2023 02:15:51 AM
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
SHOW WARNINGS;
-- -----------------------------------------------------
-- Schema sales
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `sales` ;

-- -----------------------------------------------------
-- Schema sales
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `sales` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
SHOW WARNINGS;
USE `sales` ;

-- -----------------------------------------------------
-- Table `customers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `customers` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `customers` (
  `id` CHAR(36) NOT NULL,
  `name` CHAR(100) NULL DEFAULT NULL,
  `phone` CHAR(30) NULL DEFAULT NULL,
  `email` CHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `rate`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rate` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `rate` (
  `name` CHAR(100) NULL DEFAULT NULL,
  `price` DECIMAL(10,2) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `transactions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `transactions` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `transactions` (
  `saledate` DATE NULL DEFAULT NULL,
  `transactionid` CHAR(36) NOT NULL,
  `customer_id` CHAR(36) NULL DEFAULT NULL,
  `item` CHAR(100) NULL DEFAULT NULL,
  `rate` DECIMAL(10,2) NULL DEFAULT NULL,
  `quantity` DECIMAL(10,2) NULL DEFAULT NULL,
  `total` DECIMAL(10,2) NULL DEFAULT NULL,
  PRIMARY KEY (`transactionid`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

SHOW WARNINGS;
USE `sales` ;

-- -----------------------------------------------------
-- function calcualte_cost
-- -----------------------------------------------------

USE `sales`;
DROP function IF EXISTS `calcualte_cost`;
SHOW WARNINGS;

DELIMITER $$
USE `sales`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `calcualte_cost`(item text, quantity decimal(10,2)) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN RETURN (select price*quantity as cost from rate where name=item) ; END$$

DELIMITER ;
SHOW WARNINGS;

-- -----------------------------------------------------
-- procedure data_test
-- -----------------------------------------------------

USE `sales`;
DROP procedure IF EXISTS `data_test`;
SHOW WARNINGS;

DELIMITER $$
USE `sales`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `data_test`()
BEGIN with test1 as (select id, count(1) from customers group by id having count(1) > 1), test2 as (select transactionid, count(1) from transactions group by transactionid having count(1) > 1 ), test3 as (select name, count(1) from rate group by name having count(1) > 1 ), test4 as (select * from transactions where saledate is null or customer_id is null or item is null or rate is null or quantity is null or total is null or transactionid is null or cast(saledate as char)='' or customer_id='' or item='' or rate='' or quantity='' or total='' or transactionid='' ), test5 as (select * from customers where id is null or id='' or email is null or email='' or name is null or name = ''), test6 as (select * from rate where name is null or price is null or name='' or price=''), test7 as (select transactionid, item, rate from transactions t join rate r on t.item=r.name where t.rate <> r.price ), test8 as (select transactionid, rate, quantity, total from transactions where round((rate * quantity),2) <> round(total,2) ), test9 as (select a.transactionid, a.saledate, a.item, a.customer_id, a.rate, a.quantity, a.total from transactions a where exists (select b.customer_id, b.item, b.saledate from transactions b where a.customer_id=b.customer_id and a.saledate=b.saledate and a.item=b.item group by b.customer_id, b.item, b.saledate having count(1) > 1 ) order by customer_id, saledate, item), test10 as (select item from transactions where not exists (select name from rate) ) select 'TEST 1' test_case_id, 'duplicate customer records in customers table' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test1 union all select 'TEST 2' test_case_id, 'duplicate records in transaction table' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test2 union all select 'TEST 3' test_case_id, 'duplicate entries in rate table' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test3 union all select 'TEST 4' test_case_id, 'null data' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test4 union all select 'TEST 5' test_case_id, 'null data' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test5 union all select 'TEST 6' test_case_id, 'null data' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test6 union all select 'TEST 7' test_case_id, 'item from transactions not having the correct amount' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test7 union all select 'TEST 8' test_case_id, 'total amount is calculated correctly ?' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test8 union all select 'TEST 9' test_case_id, 'same item bought by same person on the same day' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test9 union all select distinct 'TEST 10' test_case_id, 'unexpected item' message, count(*) records, case when count(*)=0 then 'PASS' else 'FAIL' end as result from test10  ; END$$

DELIMITER ;
SHOW WARNINGS;

-- -----------------------------------------------------
-- procedure merge_same_purchase
-- -----------------------------------------------------

USE `sales`;
DROP procedure IF EXISTS `merge_same_purchase`;
SHOW WARNINGS;

DELIMITER $$
USE `sales`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `merge_same_purchase`()
BEGIN drop table if exists `same purchases` ; create temporary table `same purchases` select a.transactionid, a.saledate, a.item, a.customer_id, a.rate, a.quantity, a.total from transactions a where exists (select b.customer_id, b.item, b.saledate from transactions b where a.customer_id=b.customer_id and a.saledate=b.saledate and a.item=b.item group by b.customer_id, b.item, b.saledate having count(1) > 1 ) order by customer_id, saledate, item; select * from `same purchases` ; delete from transactions where transactionid in (select transactionid from `same purchases`) ; insert into transactions (transactionid, saledate, item, customer_id, rate, quantity, total) select transactionid, saledate, item, customer_id, rate, quantity, total from (select transactionid, saledate, item, customer_id, rate, sum(quantity) over(partition by customer_id, saledate, item) quantity, sum(total) over(partition by customer_id, saledate, item) total, row_number() over(partition by customer_id, saledate, item) rn from `same purchases`) x where rn=1 ; END$$

DELIMITER ;
SHOW WARNINGS;

-- -----------------------------------------------------
-- procedure new transaction
-- -----------------------------------------------------

USE `sales`;
DROP procedure IF EXISTS `new transaction`;
SHOW WARNINGS;

DELIMITER $$
USE `sales`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `new transaction`(cust_id text, item text, quantity decimal(10,2))
BEGIN insert into transactions (saledate, transactionid, customer_id, item, rate, quantity, total) values (cast(now() as date), uuid(), cust_id, item, (select price from rate where name=item), quantity, (select quantity*(select price from rate where name=item))) ; END$$

DELIMITER ;
SHOW WARNINGS;

-- -----------------------------------------------------
-- View `count of sales by customer`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `count of sales by customer` ;
SHOW WARNINGS;
USE `sales`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `count of sales by customer` AS select `transactions`.`customer_id` AS `customer_id`,year(`transactions`.`saledate`) AS `year`,month(`transactions`.`saledate`) AS `month`,count(0) AS `purchases` from `transactions` group by `transactions`.`customer_id`,year(`transactions`.`saledate`),month(`transactions`.`saledate`);
SHOW WARNINGS;

-- -----------------------------------------------------
-- View `new customers by month`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `new customers by month` ;
SHOW WARNINGS;
USE `sales`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `sales`.`new customers by month` AS with `customer_list` as (select distinct year(`sales`.`transactions`.`saledate`) AS `year`,month(`sales`.`transactions`.`saledate`) AS `month`,`sales`.`transactions`.`customer_id` AS `customer_id`,row_number() OVER (PARTITION BY `sales`.`transactions`.`customer_id` ORDER BY year(`sales`.`transactions`.`saledate`),month(`sales`.`transactions`.`saledate`) )  AS `cust_rn` from `sales`.`transactions`) select `customer_list`.`year` AS `year`,`customer_list`.`month` AS `month`,count(distinct `customer_list`.`customer_id`) AS `new_customers` from `customer_list` where (`customer_list`.`cust_rn` = 1) group by `customer_list`.`year`,`customer_list`.`month` order by `customer_list`.`year`,`customer_list`.`month`;
SHOW WARNINGS;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
