-- BSC Token Top Holders
-- Contract: 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
-- 查看Top 100 Holders的详细信息

WITH all_transfers AS (
    SELECT 
        bytearray_substring(topic1, 13, 20) as from_address,
        bytearray_substring(topic2, 13, 20) as to_address,
        CAST(bytearray_to_uint256(data) AS DOUBLE) / 1e18 as transfer_amount_decimal,
        block_time
    FROM bnb.logs 
    WHERE contract_address = 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
      AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
),
outgoing_transfers AS (
    SELECT 
        from_address as address,
        SUM(transfer_amount_decimal) as total_sent,
        COUNT(*) as send_count,
        MAX(block_time) as last_send_time
    FROM all_transfers
    WHERE from_address != 0x0000000000000000000000000000000000000000
    GROUP BY from_address
),
incoming_transfers AS (
    SELECT 
        to_address as address,
        SUM(transfer_amount_decimal) as total_received,
        COUNT(*) as receive_count,
        MIN(block_time) as first_receive_time,
        MAX(block_time) as last_receive_time
    FROM all_transfers
    WHERE to_address != 0x0000000000000000000000000000000000000000
    GROUP BY to_address
),
holder_balances AS (
    SELECT 
        COALESCE(i.address, o.address) as holder_address,
        COALESCE(i.total_received, 0) as total_received,
        COALESCE(o.total_sent, 0) as total_sent,
        COALESCE(i.total_received, 0) - COALESCE(o.total_sent, 0) as current_balance,
        COALESCE(i.receive_count, 0) as receive_count,
        COALESCE(o.send_count, 0) as send_count,
        i.first_receive_time,
        i.last_receive_time,
        o.last_send_time
    FROM incoming_transfers i
    FULL OUTER JOIN outgoing_transfers o ON i.address = o.address
    WHERE COALESCE(i.total_received, 0) - COALESCE(o.total_sent, 0) > 0
),
total_supply AS (
    SELECT SUM(current_balance) as total_supply
    FROM holder_balances
),
ranked_holders AS (
    SELECT 
        hb.*,
        ROW_NUMBER() OVER (ORDER BY hb.current_balance DESC) as rank,
        ROUND(hb.current_balance / ts.total_supply * 100, 4) as holding_percentage,
        CASE 
            WHEN hb.current_balance >= 1000000 THEN 'Whale (≥1M)'
            WHEN hb.current_balance >= 100000 THEN 'Large Holder (100K-1M)'
            WHEN hb.current_balance >= 10000 THEN 'Medium Holder (10K-100K)'
            WHEN hb.current_balance >= 1000 THEN 'Small Holder (1K-10K)'
            WHEN hb.current_balance >= 100 THEN 'Mini Holder (100-1K)'
            WHEN hb.current_balance >= 1 THEN 'Micro Holder (1-100)'
            ELSE 'Dust (<1)'
        END as holder_category
    FROM holder_balances hb
    CROSS JOIN total_supply ts
)
SELECT 
    rank as "Rank",
    holder_address as "Holder Address",
    ROUND(current_balance, 2) as "Balance",
    holding_percentage as "% of Supply",
    holder_category as "Category",
    ROUND(total_received, 2) as "Total Received",
    ROUND(total_sent, 2) as "Total Sent",
    receive_count as "Receive Count",
    send_count as "Send Count",
    first_receive_time as "First Receive",
    last_receive_time as "Last Receive",
    last_send_time as "Last Send",
    CASE 
        WHEN send_count = 0 THEN 'Never Sold'
        WHEN total_sent < total_received * 0.1 THEN 'Strong Holder'
        WHEN total_sent < total_received * 0.5 THEN 'Moderate Holder'
        ELSE 'Active Trader'
    END as "Holder Type"
FROM ranked_holders
ORDER BY rank
LIMIT 100;

