CREATE FUNCTION `calcualte_cost` (item text, quantity decimal(10,2)) RETURNS decimal(10,2) DETERMINISTIC BEGIN RETURN (select price*quantity as cost from rate where name=item) ; END