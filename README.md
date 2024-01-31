# Olist E-commerce Data Analysis 

## Introduction

The data can be downloaded from [here](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download&select=olist_orders_dataset.csv). It is a Brazilian ecommerce public dataset of orders made at Olist Store. The dataset has information on 100k orders from 2016 to 2018 made at multiple marketplaces in Brazil. Its features allow viewing orders from multiple dimensions: from order status, price, payment, and freight performance to customer location, product attributes, and finally reviews written by customers. 
The analysis is performed in PostgreSQL 16.1. The queries used are included in the Brazilian E-Commerce Analysis.sql file. 
The analysis focuses on customer behavior and preferences, order patterns, and geographical insights. The findings and insights derived from it could be used to inform e-commerce business strategy, marketing, and operational improvements. 

## Summary of insights

## 1. Customer Behavior and Preferences

### 1.1 Order Item Count
- Most orders (87.59%) consist of a single item, indicating a preference for individual item purchases.
- Orders with multiple items are less frequent, with a sharp decrease in frequency as the number of items per order increases.

### 1.2 Average Order Value
- The overall average order value, including product and freight costs, is approximately BRL 160.58.

### 1.3 Payment Methods
- Credit cards are the most preferred payment method, used in 73.92% of orders.
- Boleto, a Brazilian payment method, follows with 19.04% usage.
- Lesser-used methods include vouchers and debit cards.

### 1.4 Payment Installments
- About half of the customers (50.58%) prefer paying in full (one installment).
- Installments of two to ten are also common, indicating a mix of full and installment payment preferences.

### 1.5 Average Order Value by Payment Method
- Credit card orders have the highest average value (BRL 166.81), suggesting a tendency to use credit for more expensive purchases.

## 2. Order Delivery and Efficiency

### 2.1 Average Delivery Time
- A significant improvement in delivery efficiency has been observed over the years, with the average delivery time reducing from 19.68 days in 2016 to 12.14 days in 2018.

### 2.2 Late Deliveries
- The percentage of late deliveries has increased from 1.50% in 2016 to 9.37% in 2018, highlighting challenges in managing delivery times despite growing order volumes.

### 2.3 Late Deliveries and Customer Reviews
- Late deliveries significantly affect customer satisfaction, with higher percentages of late deliveries corresponding to lower review scores.

## 3. Geographical Insights

### 3.1 Orders by State
- São Paulo (SP) leads in the number of orders, followed by Rio de Janeiro (RJ) and Minas Gerais (MG).
- There is a heavy concentration of orders in the Southeastern states.

### 3.2 Average Order Value by State
- States like Paraíba (PB) and Acre (AC) have higher average order values, indicating potential for larger or premium purchases.

### 3.3 Total Order Value by State
- São Paulo (SP) has the highest number of orders and total order value, emphasizing its significant market share.

## Conclusion

The analysis provides insights into customer purchasing behavior, payment preferences, order delivery efficiency, and geographical market dynamics in the Brazilian e-commerce sector. São Paulo emerges as a key market, credit cards as the preferred payment method, and a clear trend of improving delivery efficiency over time. However, challenges in managing late deliveries and the varying economic landscape across different states are evident.

This analysis can guide strategic decisions and tailor marketing and sales approaches in the e-commerce sector. 
