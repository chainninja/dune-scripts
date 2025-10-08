-- BSC Token Concentration Analysis
-- Contract: 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
-- 分析代币集中度：Whale和大户控制了多少供应量

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
total_supply AS (
    SELECT SUM(balance) as total_supply
    FROM holder_balances
),
ranked_holders AS (
    SELECT 
        balance,
        ROW_NUMBER() OVER (ORDER BY balance DESC) as rank
    FROM holder_balances
)
SELECT 
    '📊 Total Supply' as "Metric",
    CAST(ROUND((SELECT total_supply FROM total_supply), 2) AS VARCHAR) as "Value",
    '100.00%' as "Percentage"
UNION ALL
SELECT 
    '👥 Total Holders',
    CAST(COUNT(*) AS VARCHAR),
    '-'
FROM holder_balances
UNION ALL
SELECT 
    '🐋 Whales (≥1M tokens)',
    CAST(COUNT(*) AS VARCHAR) || ' holders',
    CAST(ROUND(SUM(balance) / (SELECT total_supply FROM total_supply) * 100, 2) AS VARCHAR) || '%'
FROM holder_balances
WHERE balance >= 1000000
UNION ALL
SELECT 
    '🦈 Large Holders (100K-1M)',
    CAST(COUNT(*) AS VARCHAR) || ' holders',
    CAST(ROUND(SUM(balance) / (SELECT total_supply FROM total_supply) * 100, 2) AS VARCHAR) || '%'
FROM holder_balances
WHERE balance >= 100000 AND balance < 1000000
UNION ALL
SELECT 
    '🐬 Medium Holders (10K-100K)',
    CAST(COUNT(*) AS VARCHAR) || ' holders',
    CAST(ROUND(SUM(balance) / (SELECT total_supply FROM total_supply) * 100, 2) AS VARCHAR) || '%'
FROM holder_balances
WHERE balance >= 10000 AND balance < 100000
UNION ALL
SELECT 
    '🐟 Small Holders (<10K)',
    CAST(COUNT(*) AS VARCHAR) || ' holders',
    CAST(ROUND(SUM(balance) / (SELECT total_supply FROM total_supply) * 100, 2) AS VARCHAR) || '%'
FROM holder_balances
WHERE balance < 10000
UNION ALL
SELECT 
    '---',
    '---',
    '---'
UNION ALL
SELECT 
    '🔝 Top 10 Holders',
    CAST(ROUND(SUM(balance), 2) AS VARCHAR),
    CAST(ROUND(SUM(balance) / (SELECT total_supply FROM total_supply) * 100, 2) AS VARCHAR) || '%'
FROM ranked_holders
WHERE rank <= 10
UNION ALL
SELECT 
    '🔝 Top 50 Holders',
    CAST(ROUND(SUM(balance), 2) AS VARCHAR),
    CAST(ROUND(SUM(balance) / (SELECT total_supply FROM total_supply) * 100, 2) AS VARCHAR) || '%'
FROM ranked_holders
WHERE rank <= 50
UNION ALL
SELECT 
    '🔝 Top 100 Holders',
    CAST(ROUND(SUM(balance), 2) AS VARCHAR),
    CAST(ROUND(SUM(balance) / (SELECT total_supply FROM total_supply) * 100, 2) AS VARCHAR) || '%'
FROM ranked_holders
WHERE rank <= 100;

