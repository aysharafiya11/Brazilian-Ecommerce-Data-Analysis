# Data Dictionary

## Overview

This project uses the **Brazilian E-Commerce Public Dataset by Olist**, which contains information about customers, orders, products, sellers, payments, reviews, and geolocation. The dataset is used to analyze sales performance, customer behavior, seller performance, delivery efficiency and payment trends.

---

## Customers

**Description:** Stores customer information and location details.

| Column | Description |
|---------|-------------|
| customer_id | Unique identifier for each customer. |
| customer_unique_id | Unique customer identifier across multiple orders. |
| customer_zip_code_prefix | ZIP code prefix of the customer. |
| customer_city | Customer's city. |
| customer_state | Customer's state. |

---

## Orders

**Description:** Contains order lifecycle information from purchase to delivery.

| Column | Description |
|---------|-------------|
| order_id | Unique order identifier. |
| customer_id | Customer who placed the order. |
| order_status | Current status of the order. |
| order_purchase_timestamp | Date and time when the order was placed. |
| order_approved_at | Payment approval timestamp. |
| order_delivered_carrier_date | Date when the order was handed to the carrier. |
| order_delivered_customer_date | Date when the customer received the order. |
| order_estimated_delivery_date | Estimated delivery date. |

---

## Order Items

**Description:** Contains product-level details for each order.

| Column | Description |
|---------|-------------|
| order_id | Order identifier. |
| order_item_id | Item number within an order. |
| product_id | Product identifier. |
| seller_id | Seller identifier. |
| shipping_limit_date | Shipping deadline for the seller. |
| price | Product price. |
| freight_value | Shipping cost. |

---

## Order Payments

**Description:** Stores payment information for each order.

| Column | Description |
|---------|-------------|
| order_id | Order identifier. |
| payment_sequential | Sequence number of payment. |
| payment_type | Payment method used. |
| payment_installments | Number of installments. |
| payment_value | Total payment amount. |

---

## Order Reviews

**Description:** Customer ratings and review details.

| Column | Description |
|---------|-------------|
| review_id | Unique review identifier. |
| order_id | Order identifier. |
| review_score | Customer rating (1–5). |
| review_creation_date | Review creation date. |
| review_answer_timestamp | Review response timestamp. |

---

## Products

**Description:** Contains product information.

| Column | Description |
|---------|-------------|
| product_id | Unique product identifier. |
| product_category_name | Product category (Portuguese). |
| product_name_length | Length of product name. |
| product_description_length | Length of product description. |
| product_photos_qty | Number of product images. |
| product_weight_g | Product weight (grams). |
| product_length_cm | Product length (cm). |
| product_height_cm | Product height (cm). |
| product_width_cm | Product width (cm). |

---

## Sellers

**Description:** Stores seller information.

| Column | Description |
|---------|-------------|
| seller_id | Unique seller identifier. |
| seller_zip_code_prefix | Seller ZIP code prefix. |
| seller_city | Seller city. |
| seller_state | Seller state. |

---

## Geolocation

**Description:** Maps ZIP code prefixes to geographical locations.

| Column | Description |
|---------|-------------|
| geolocation_zip_code_prefix | ZIP code prefix. |
| geolocation_lat | Latitude. |
| geolocation_lng | Longitude. |
| geolocation_city | City name. |
| geolocation_state | State name. |

---

## Product Category Name Translation

**Description:** Translates Portuguese product category names into English.

| Column | Description |
|---------|-------------|
| product_category_name | Product category in Portuguese. |
| product_category_name_english | Product category in English. |

---

# Database Relationships

| Parent Table | Child Table | Key |
|--------------|-------------|-----|
| customers | orders | customer_id |
| orders | order_items | order_id |
| orders | order_payments | order_id |
| orders | order_reviews | order_id |
| order_items | products | product_id |
| order_items | sellers | seller_id |
| products | product_category_name_translation | product_category_name |
| customers / sellers | geolocation | ZIP code prefix |

---

# Dataset Summary

| Table | Purpose |
|--------|---------|
| customers | Customer information |
| orders | Order lifecycle |
| order_items | Products purchased in each order |
| order_payments | Payment details |
| order_reviews | Customer ratings and reviews |
| products | Product information |
| sellers | Seller information |
| geolocation | Geographic location mapping |
| product_category_name_translation | Category name translation |
