
# Zomato Data Insights Using SQL
Exploring and uncovering key insights from Zomato's dummy data through comprehensive data analysis

# Tables and Relationships

#### goldusers_signup:
- Primary Key: userid (integer)
- gold_signup_date (date)
- Foreign Key: userid references users(userid)

#### users
- userid (integer)
- signup_date (date)
- Primary Key: userid

#### sales
- userid (integer)
- created_date (date)
- product_id (integer)
- Foreign Key 1: userid references users(userid)
- Foreign Key 2: product_id references product(product_id)

#### product 
- product_id (integer)
- product_name (text)
- price (integer)
- Primary Key: product_id

## How to use
#### Create Tables:
- Use the script.sql file to create the necessary tables and set up relationships between them.
- This script will create four tables: users, goldusers_signup, sales, and product, along with their relationships.

#### Establish Relationships:
- The relationships between the tables are defined in the script.sql file.
- Ensure that the foreign keys are properly set to maintain referential integrity.

#### Database Diagram:
- For a visual representation of the database structure, refer to the Database Diagram.png file.
- This diagram illustrates how the tables are connected and provides a clear understanding of the relationships.

#### SQL Queries for Analysis:
- The Zomato Data Insights.sql file contains the final queries used for data analysis.
- These queries will help you derive insights from the data stored in the tables.

## Conclusion
This project provides a structured approach to analyzing Zomato's dummy data using SQL. By following the steps and utilizing the provided files, you can create the database, understand its structure, and perform insightful data analysis.

## Author
[@chirag8911](https://github.com/chirag8911)
