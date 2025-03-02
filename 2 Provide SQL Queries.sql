#What are the top 5 brands by receipts scanned among users 21 and over?
WITH valid_users AS (
    SELECT user_id 
    FROM USER_TAKEHOME
    WHERE TIMESTAMPDIFF(YEAR, BIRTH_DATE, CURDATE()) >= 21
),
brand_receipts AS (
    SELECT 
        t.user_id,
        p.BRAND,
        COUNT(t.RECEIPT_ID) AS receipt_count
    FROM TRANSACTION_TAKEHOME t
    JOIN PRODUCTS_TAKEHOME p ON t.BARCODE = p.BARCODE
    JOIN valid_users u ON t.user_id = u.user_id
    GROUP BY p.BRAND
)
SELECT BRAND, SUM(receipt_count) AS total_receipts
FROM brand_receipts
GROUP BY BRAND
ORDER BY total_receipts DESC
LIMIT 5;
#What are the top 5 brands by sales among users that have had their account for at least six months?
WITH eligible_users AS (
    SELECT user_id 
    FROM USER_TAKEHOME
    WHERE TIMESTAMPDIFF(MONTH, ACCOUNT_CREATED_DATE, CURDATE()) >= 6
),
brand_sales AS (
    SELECT 
        p.BRAND,
        SUM(t.FINAL_SALE) AS total_sales
    FROM TRANSACTION_TAKEHOME t
    JOIN PRODUCTS_TAKEHOME p ON t.BARCODE = p.BARCODE
    JOIN eligible_users u ON t.user_id = u.user_id
    WHERE t.FINAL_SALE IS NOT NULL
    GROUP BY p.BRAND
)
SELECT BRAND, total_sales
FROM brand_sales
ORDER BY total_sales DESC
LIMIT 5;

#Who are Fetch’s power users?
#Rank users based on receipts scanned (primary sort) and total spending 
WITH user_activity AS (
    SELECT 
        t.user_id, 
        COUNT(t.RECEIPT_ID) AS total_receipts, 
        SUM(t.FINAL_SALE) AS total_spent
    FROM TRANSACTION_TAKEHOME t
    WHERE t.FINAL_SALE IS NOT NULL
    GROUP BY t.user_id
)
SELECT user_id, total_receipts, total_spent
FROM user_activity
ORDER BY total_receipts DESC, total_spent DESC
LIMIT 10;
