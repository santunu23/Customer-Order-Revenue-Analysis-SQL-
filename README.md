📊 Customer Order & Revenue Analysis (SQL)
📌 Project Overview

This project analyzes customer behavior, revenue distribution, and time-based sales trends for an e-commerce platform using SQL.
The goal is to understand who the customers are, how revenue is distributed, and what drives business growth over time.

The analysis follows a structured, business-oriented approach inspired by Google’s data analysis framework (Ask → Prepare → Process → Analyze → Share → Act).

🎯 Business Objectives

  Understand the customer base and purchasing behavior
  
  * Identify one-time vs repeat customers and their revenue contribution
  
  * Analyze revenue concentration and test Pareto (80/20) assumptions
  
  * Explore monthly revenue, order trends, and seasonality
  
  * Evaluate whether growth is driven by order volume or average order value (AOV)

🗂 Dataset Description

  * The dataset represents real-world e-commerce transactions and includes the following tables:
  
  * customers – customer identifiers (customer_id, customer_unique_id)
  
  * orders – order-level details and timestamps (order_purchase_timestamp)
  
  * order_items – item-level transaction values (price)

📌 Revenue Definition:
Revenue is calculated as the sum of order_items.price (shipping costs excluded).

📌 Time Dimension:
All trend analyses use order_purchase_timestamp.

🛠 Tools & Technologies

  * SQL (MySQL syntax) – data extraction and aggregation
  
  * Kaggle Notebook – analysis and storytelling
  
  * Tableau – data visualization (exported as images)
  
  * GitHub – project version control and documentation

🔍 Analysis Summary
1️⃣ Customer Behavior

  * ~97% of customers are one-time buyers
  
  * Repeat customers form a very small portion of the customer base
  
  * Repeat customers generate higher average revenue per customer but do not dominate total revenue

2️⃣ Revenue Distribution (Pareto Analysis)

  * Top 10 customers contribute ~0.5% of total revenue
  
  * Top 100 customers contribute ~2.45% of total revenue
  
  * Revenue is highly distributed, not concentrated
  
  * The traditional 80/20 Pareto principle does not apply

📌 Business implication: Low dependency on “whale” customers, but limited upside from customer concentration.

3️⃣ Revenue & Order Trends

  * Monthly revenue and order volumes show clear fluctuations
  
  * Revenue trends closely follow order volume trends
  
  * Growth is primarily volume-driven, not price-driven

4️⃣ Seasonality

  * Certain months consistently show higher order activity
  
  * Indicates predictable seasonal demand patterns

5️⃣ Average Order Value (AOV)

  * AOV remains relatively stable over time
  
  * Customers are not spending significantly more per order
  
  * Confirms a high-volume, low-ticket sales model

📈 Key Insights

  * Customer retention is low; growth depends heavily on new customer acquisition
  
  * Revenue is fragmented across a large customer base
  
  * Seasonal peaks present opportunities for targeted marketing
  
  * Increasing AOV could unlock additional revenue growth

✅ Recommendations

  * Introduce retention-focused strategies (loyalty programs, re-engagement campaigns)
  
  * Leverage seasonal peaks with targeted promotions
  
  * Explore cross-selling and bundling to improve AOV
  
  * Balance acquisition efforts with long-term customer retention initiatives

📌 Project Structure
├── README.md
├── sql_queries/
│   └── customer_revenue_analysis.sql
├── images/
│   └── tableau_charts.png
└── kaggle_notebook/
    └── analysis_notebook.ipynb

🚀 Future Enhancements

  * Product and category-level performance analysis
  
  * Seller-level revenue concentration
  
  * Payment method and installment behavior analysis
  
  * Delivery performance and logistics timing analysis

👤 Author

  Joy Sen
  Data Analytics Enthusiast | SQL | Business Insights
  📎 Kaggle • GitHub • LinkedIn
