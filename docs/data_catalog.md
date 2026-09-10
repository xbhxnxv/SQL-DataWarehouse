# Data Catalog — Gold Layer

The Gold layer is the business-ready, analytics-facing part of the warehouse. It is modeled as a star schema: two dimension views and one fact view. This catalog documents each field.

---

## gold.dim_customers

Customer dimension. Combines CRM customer records with ERP demographic and location data, one row per customer.

| Column          | Type          | Description                                                                 |
|-----------------|---------------|-----------------------------------------------------------------------------|
| customer_key    | INT           | Surrogate key uniquely identifying each customer row in the dimension.       |
| customer_id     | INT           | Natural customer id from the source CRM system.                             |
| customer_number | NVARCHAR(50)  | Alphanumeric customer code used for tracking and referencing.               |
| first_name      | NVARCHAR(50)  | Customer's first name.                                                      |
| last_name       | NVARCHAR(50)  | Customer's last name / surname.                                            |
| country         | NVARCHAR(50)  | Customer's country of residence (e.g. 'Germany', 'United States').          |
| marital_status  | NVARCHAR(50)  | Marital status ('Single', 'Married', 'n/a').                               |
| gender          | NVARCHAR(50)  | Gender ('Male', 'Female', 'n/a'). CRM is primary; ERP is the fallback.      |
| birthdate       | DATE          | Date of birth (yyyy-mm-dd).                                                |
| create_date     | DATE          | Date the customer record was created in the source system.                  |

---

## gold.dim_products

Product dimension. Combines CRM product records with ERP category data, one row per **current** product (historical product versions are excluded).

| Column        | Type          | Description                                                                 |
|---------------|---------------|-----------------------------------------------------------------------------|
| product_key   | INT           | Surrogate key uniquely identifying each product row in the dimension.        |
| product_id    | INT           | Natural product id from the source system.                                  |
| product_number| NVARCHAR(50)  | Structured product code used for categorization and inventory.              |
| product_name  | NVARCHAR(50)  | Descriptive product name (type, colour, size, etc.).                        |
| category_id   | NVARCHAR(50)  | Identifier linking the product to its high-level category.                  |
| category      | NVARCHAR(50)  | High-level product category (e.g. 'Bikes', 'Components').                   |
| subcategory   | NVARCHAR(50)  | More detailed classification within the category.                          |
| maintenance   | NVARCHAR(50)  | Whether the product requires maintenance ('Yes'/'No').                     |
| cost          | INT           | Base cost of the product.                                                  |
| product_line  | NVARCHAR(50)  | Product line ('Mountain', 'Road', 'Touring', 'Other Sales', 'n/a').        |
| start_date    | DATE          | Date the product became available for sale.                                |

---

## gold.fact_sales

Sales fact. One row per sales order line, linked to the customer and product dimensions by surrogate keys.

| Column        | Type          | Description                                                                 |
|---------------|---------------|-----------------------------------------------------------------------------|
| order_number  | NVARCHAR(50)  | Sales order identifier (e.g. 'SO54496').                                    |
| product_key   | INT           | Surrogate key linking the order line to gold.dim_products.                  |
| customer_key  | INT           | Surrogate key linking the order line to gold.dim_customers.                 |
| order_date    | DATE          | Date the order was placed.                                                 |
| shipping_date | DATE          | Date the order was shipped.                                                |
| due_date      | DATE          | Date payment was due.                                                      |
| sales_amount  | INT           | Total value of the line (quantity x price).                               |
| quantity      | INT           | Number of units ordered.                                                   |
| price         | INT           | Price per unit.                                                            |
