copy users from 's3://awssampledbuswest2/tickit/allusers_pipe.txt' 
credentials 'aws_iam_role=arn:aws:iam::419250651160:role/myRedshiftRole' 
delimiter '|' region 'us-west-2';

copy venue from 's3://awssampledbuswest2/tickit/venue_pipe.txt' 
credentials 'aws_iam_role=arn:aws:iam::419250651160:role/myRedshiftRole' 
delimiter '|' region 'us-west-2';

copy category from 's3://awssampledbuswest2/tickit/category_pipe.txt' 
credentials 'aws_iam_role=arn:aws:iam::419250651160:role/myRedshiftRole' 
delimiter '|' region 'us-west-2';

copy date from 's3://awssampledbuswest2/tickit/date2008_pipe.txt' 
credentials 'aws_iam_role=arn:aws:iam::419250651160:role/myRedshiftRole' 
delimiter '|' region 'us-west-2';

copy event from 's3://awssampledbuswest2/tickit/allevents_pipe.txt' 
credentials 'aws_iam_role=arn:aws:iam::419250651160:role/myRedshiftRole' 
delimiter '|' timeformat 'YYYY-MM-DD HH:MI:SS' region 'us-west-2';

copy listing from 's3://awssampledbuswest2/tickit/listings_pipe.txt' 
credentials 'aws_iam_role=arn:aws:iam::419250651160:role/myRedshiftRole' 
delimiter '|' region 'us-west-2';

copy sales from 's3://awssampledbuswest2/tickit/sales_tab.txt'
credentials 'aws_iam_role=arn:aws:iam::419250651160:role/myRedshiftRole'
delimiter '\t' timeformat 'MM/DD/YYYY HH:MI:SS' region 'us-west-2';


SELECT *    
FROM pg_table_def    
WHERE tablename = 'sales'; 

SELECT sum(qtysold) 
FROM   sales, date 
WHERE  sales.dateid = date.dateid 
AND    caldate = '2008-01-05';


SELECT firstname, lastname, total_quantity 
FROM   (SELECT buyerid, sum(qtysold) total_quantity
        FROM  sales
        GROUP BY buyerid
        ORDER BY total_quantity desc limit 10) Q, users
WHERE Q.buyerid = userid
ORDER BY Q.total_quantity desc;



SELECT eventname, total_price 
FROM  (SELECT eventid, total_price, ntile(1000) over(order by total_price desc) as percentile 
       FROM (SELECT eventid, sum(pricepaid) total_price
             FROM   sales
             GROUP BY eventid)) Q, event E
       WHERE Q.eventid = E.eventid
       AND percentile = 1
ORDER BY total_price desc;
