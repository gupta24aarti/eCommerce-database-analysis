create database ecommerce;
use ecommerce;

-- Create tables

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(255) NOT NULL
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(255) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category_id INT,
    supplier_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(255) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE,
    order_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(255) NOT NULL,
    department_id INT,
    salary DECIMAL(10, 2),
    manager_id INT,
    birth_date DATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

CREATE TABLE employee_projects (
    employee_id INT,
    project_id INT,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Insert sample data

-- Suppliers
INSERT INTO suppliers (supplier_name) VALUES 
('Supplier A'),
('Supplier B'),
('Supplier C');

-- Categories
INSERT INTO categories (category_name) VALUES 
('Category 1'),
('Category 2'),
('Category 3');

-- Products
INSERT INTO products (product_name, category_id, supplier_id) VALUES 
('Product 1', 1, 1),
('Product 2', 1, 2),
('Product 3', 2, 1),
('Product 4', 3, 3),
('Product 5', 2, 2),
('Product 6', 3, 1);

-- Customers
INSERT INTO customers (customer_name) VALUES 
('Customer A'),
('Customer B'),
('Customer C');

-- Orders
INSERT INTO orders (customer_id, product_id, quantity, order_date, order_amount) VALUES 
(1, 1, 10, '2023-01-10', 100.00),
(1, 2, 5, '2023-02-15', 50.00),
(2, 3, 20, '2023-03-20', 200.00),
(2, 4, 15, '2023-04-25', 150.00),
(3, 5, 10, '2023-05-30', 100.00),
(3, 6, 25, '2023-06-05', 250.00),
(1, 3, 5, '2023-07-10', 50.00),
(2, 2, 15, '2023-08-15', 150.00),
(3, 1, 20, '2023-09-20', 200.00),
(1,	5,	10,'2023-08-12',400.00);

-- Departments
INSERT INTO departments (department_name) VALUES 
('HR'),
('Engineering'),
('Marketing');

-- Employees
INSERT INTO employees (employee_name, department_id, salary, manager_id, birth_date) VALUES 
('Employee A', 1, 60000.00, NULL, '1980-01-01'),
('Employee B', 1, 65000.00, 1, '1985-02-02'),
('Employee C', 2, 70000.00, 1, '1990-03-03'),
('Employee D', 3, 75000.00, 2, '1985-04-04'),
('Employee E', 2, 80000.00, 2, '1970-05-05'),
('Employee F', 3, 85000.00, 3, '1995-06-06');

-- Employee Projects
INSERT INTO employee_projects (employee_id, project_id) VALUES 
(1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 3),
(4, 1),
(4, 4),
(5, 4),
(6, 5);

select * from customers;
select * from orders;
select * from products;
select * from departments;

### CREATING INDEX
create index ecom_employee_index on employees (employee_id, department_id, manager_id,salary);

# 1. Write a query to retrieve the names and salaries of employees from each department who earn 
    -- more than ₹50,000. Use the index on department_id and salary to optimize the performance.
select department_id,employee_name, salary from employees where salary > 50000
order by department_id;

# For drop the index
drop index ecom_employee_index on employees;

# . Write a query to find the customer name who have placed orders amount more than 500.
SELECT c.customer_name 
FROM customers c 
JOIN orders o USING (customer_id)
WHERE order_amount > 500;


# 2. Find the most recently ordered product by each customer?
SELECT 
c.customer_id,
c.customer_name,
p.product_name,
o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id
WHERE (c.customer_id, o.order_date) 
IN (SELECT customer_id, MAX(order_date)
    FROM orders
    GROUP BY customer_id);


# 3. Find the most frequently ordered product by each customer? Note: most frequently ordered 
#    means the highest volume ordered
select customer_id, p.product_id, p.product_name 
from
(select customer_id,product_id,order_count, 
rank() over(partition by customer_id order by order_count desc) as rnk 
from
(select customer_id, product_id,count(distinct order_id) as order_count 
from  orders group by customer_id, product_id) order_count) order_count_ranked
join products p on order_count_ranked.product_id = p.product_id 
where rnk=1; 


select * from products;


# 4. List the names of suppliers who supply products in 'Category 2’. (try using join and subquery 
#    separately)
-- 1.USING INNER JOIN
select s.supplier_name,s.supplier_id 
from suppliers s inner join products p on s.supplier_id=p.supplier_id
where category_id = 2;

-- 2. using subquery
select supplier_name,supplier_id 
from suppliers 
where supplier_id in (select supplier_id from products where category_id = 2);


# 5. List the employees who are working on more than one project.
select employee_id, count(project_id) as Project  
from employee_projects
group by employee_id 
having count(project_id) > 1; 

select * from employee_projects;


# 6. Display the customer name along with number of orders and total amount paid
select c.customer_name,count(o.order_id) as no_of_order,sum(o.order_amount) as total_amount 
from customers c
join orders o on c.customer_id = o.customer_id 
group by customer_name;

select * from orders;


# 7. List the top 3 products that have generated the highest revenue.
select p.product_name,sum(o.order_amount*quantity) as highest_revenu 
from products p 
join orders o on p.product_id = o.product_id
group by product_name limit 3;


# 8. List customers who have ordered every product supplied by 'Supplier B'.
select c.customer_name 
from customers c join orders o on c.customer_id = o.customer_id
join products p on o.product_id=p.product_id
join suppliers s on p.supplier_id = s.supplier_id
where supplier_name ='supplier B';
 
 select * from orders;
 
 
# 9. Find the products ordered by at least two different customers.
select o.product_id,p.product_name 
from products p join orders o on p.product_id=o.product_id
group by product_id,product_name 
having count(distinct o.customer_id) >= 2;
  

# . List the departments where all employees earn above the company's average salary.
select d.department_name, d.department_id 
from departments d 
join employees e on d.department_id = e.department_id 
group by department_name, department_id
having max(salary) > (select avg(salary) from employees );  


# 10. Write a query to list all customers and their orders. If a customer has not placed any order,
 -- show their name with NULL for order details.
select c.customer_id, c.customer_name, o.order_id, o.order_date, o.order_amount 
from customers c left join orders o on c.customer_id = o.customer_id;


# 11. Write a query to find the total order amount for each product (based on product_id) 
-- and show it along with the product name. Include orders even if the product no longer 
-- exists in the products table.
select
o.product_id, p.product_name, COUNT(o.order_id) as total_orders, SUM(o.order_amount) as total_revenue
from products p
right join orders o on p.product_id = o.product_id
group by o.product_id, p.product_name
order by total_revenue desc;

select * from orders;
select * from customers;

#  creating view
use ecommerce;
create view e_commerce_view as 
select c.customer_name , p.product_name, cat.category_name, s.supplier_name ,o.order_date,
 o.order_amount, o.quantity 
 from customers c 
 join orders o using (customer_id)
 join products p using (product_id)
 join suppliers s using (supplier_id)
 join categories cat using (category_id);

select * from e_commerce_view;

