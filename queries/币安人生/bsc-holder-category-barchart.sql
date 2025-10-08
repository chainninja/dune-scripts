-- BSC Token Holder Category Distribution (For Bar Chart)
-- Contract: 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
-- 生成柱状图：展示各类别holder的数量和持仓分布

WITH all_transfers AS (
    SELECT 
        bytearray_substring(topic1, 13, 20) as from_address,
        bytearray_substring(topic2, 13, 20) as to_address,
        CAST(bytearray_to_uint256(data) AS DOUBLE) / 1e18 as transfer_amount_decimal
    FROM bnb.logs 
    WHERE contract_address = 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
    AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
    AND block_date >= TIMESTAMP '2025-10-02 00:00:00'

),
holder_balances AS (
    SELECT 
        address,
        SUM(CASE WHEN transfer_type = 'in' THEN amount ELSE -amount END) as balance
    FROM (
        SELECT to_address as address, transfer_amount_decimal as amount, 'in' as transfer_type
        FROM all_transfers
        WHERE to_address != 0x0000000000000000000000000000000000000000
        UNION ALL
        SELECT from_address as address, transfer_amount_decimal as amount, 'out' as transfer_type
        FROM all_transfers
        WHERE from_address != 0x0000000000000000000000000000000000000000
    )
    GROUP BY address
    HAVING SUM(CASE WHEN transfer_type = 'in' THEN amount ELSE -amount END) > 0
),
categorized_holders AS (
    SELECT 
        balance,
        CASE 
            WHEN balance >= 1000000 THEN 'Whale (≥1M)'
            WHEN balance >= 100000 THEN 'Large Holder (100K-1M)'
            WHEN balance >= 10000 THEN 'Medium Holder (10K-100K)'
            WHEN balance >= 1000 THEN 'Small Holder (1K-10K)'
            WHEN balance >= 100 THEN 'Mini Holder (100-1K)'
            WHEN balance >= 1 THEN 'Micro Holder (1-100)'
            ELSE 'Dust (<1)'
        END as category,
        CASE 
            WHEN balance >= 1000000 THEN 1
            WHEN balance >= 100000 THEN 2
            WHEN balance >= 10000 THEN 3
            WHEN balance >= 1000 THEN 4
            WHEN balance >= 100 THEN 5
            WHEN balance >= 1 THEN 6
            ELSE 7
        END as category_order
    FROM holder_balances
),
total_supply AS (
    SELECT SUM(balance) as total_supply
    FROM holder_balances
)
SELECT 
    ch.category as "Holder Category",
    COUNT(*) as "Number of Holders",
    ROUND(SUM(ch.balance), 2) as "Total Balance",
    ROUND(SUM(ch.balance) / ts.total_supply * 100, 2) as "% of Total Supply",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as "% of Holders",
    ROUND(AVG(ch.balance), 2) as "Average Balance"
FROM categorized_holders ch
CROSS JOIN total_supply ts
GROUP BY ch.category, ch.category_order, ts.total_supply
ORDER BY ch.category_order;

