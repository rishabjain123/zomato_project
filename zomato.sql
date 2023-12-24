-- creating gold user table 
drop table if exists goldusers_signup;
create table zomato.goldusers_signup (userid integer, gold_signup_date date);
insert into zomato.goldusers_signup (userid, gold_signup_date)
values(1,'2020-08-22'),(3,'2020-02-21');
select *from zomato.goldusers_signup;

-- creating normal user table
create table zomato.users(userid integer, signup_date date);
insert into zomato.users(userid, signup_date)
values(1,'2018-07-13'),(2,'2019-06-15'),(3,'2020-03-27');
select *from zomato.users;

-- creating sales table 
create table zomato.sales(userid integer, orderdate date, product_id integer);
insert into zomato.sales(userid, orderdate, product_id)
values(1,'2019-05-13',3),(1,'2020-09-09',2),(1,'2019-06-23',3),
(2,'2020-01-10',2),(2,'2021-12-13',3),(2,'2022-08-19',2),
(3,'2022-10-23',1),(3,'2023-05-16',1),(3,'2021-11-12',2);
select *from zomato.sales;

-- creating product table 
create table zomato.product(product_id integer, product_name varchar(30), product_price integer);
insert into zomato.product(product_id, product_name, product_price)
values (1,'p1',800),(2,'p2',400),(3,'p3',600);
select *from zomato.product;

-- what is the total amount each customer spent on zomato?
select s.userid, sum(p.product_price) as total_amount from zomato.sales s
inner join zomato.product p on s.product_id = p.product_id group by s.userid;

-- how many days each customer visited zomato
select u.userid, count(s.orderdate) as days_customer_ordered from zomato.users u 
inner join zomato.sales s on u.userid = s.userid group by u.userid;

-- what was the first product purchased by each customer
select * from (select *, rank() over( partition by userid order by orderdate asc ) 
as first_product_ordered from zomato.sales) a where first_product_ordered = 1;

-- what is the most purchased item and how many times it was purchased
select product_id, count(*) from zomato.sales group by product_id order by count(*) desc;

-- which product is the most loved by each customer
select *, rank() over( partition by userid order by cnt desc) rnk from
(select userid, product_id, count(product_id) cnt from zomato.sales group by userid,product_id) a;

-- which item was purchased by the customer after they became a gold member
select a.*, rank() over(partition by a.userid order by a.orderdate desc) rnk from
(select g.userid, g.gold_signup_date, s.product_id from zomato.goldusers_signup g
inner join zomato.sales s on g.userid = s.userid and s.orderdate > g.gold_signup_date) a;

--  what is total orders and amount spent for each member before they become a gold member
select a.userid, sum(p.product_price) from
(select s.userid, s.orderdate, s.product_id, g.gold_signup_date from zomato.sales s
inner join zomato.goldusers_signup g on s.userid = g.userid and s.orderdate > g.gold_signup_date) a 
inner join zomato.product p on a.product_id = p.product_id group by a.userid;

-- if buying each product generates points for ex. for p1 Rs.5 = 1 zomato points,
-- for p2 Rs.10 = 5 zomato points and for p3 Rs.5 = 2 zomato points

-- cal. the points collected by each customer
create table zomato.points(product_id integer, product_points integer, rupee_per_product integer);
insert into zomato.points( product_id, product_points, rupee_per_product)
values(1,1,5),(2,5,10),(3,2,5);
select *from zomato.points;

select a.userid, sum(b.product_points*(a.total_amount)/(b.rupee_per_product)) as total_collected_point 
from(select s.userid, sum(p.product_price) as total_amount, p.product_id from zomato.sales s
inner join zomato.product p on s.product_id = p.product_id group by s.userid,p.product_id) a
inner join zomato.points b on a.product_id = b.product_id  group by a.userid;

-- if the customer joins gold membership after some time they earn 5 extra zomato points for every Rs. 10 spent
-- who earned more points 1 or 3

select s.userid, (sum(b.product_points) + 5*count(g.userid)) as new_product_points from 
zomato.sales s inner join zomato.points b on s.product_id = b.product_id 
left join zomato.goldusers_signup g on s.userid = g.userid 
and s.orderdate > g.gold_signup_date
group by s.userid ;
