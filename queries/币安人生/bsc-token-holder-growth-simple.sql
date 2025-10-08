-- BSC Token Holder Growth Over Time (Simplified & Faster)
-- Contract: 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
-- 追踪新holder的加入趋势（基于首次接收时间）

WITH all_transfers AS (
    SELECT 
        bytearray_substring(topic2, 13, 20) as to_address,
        CAST(bytearray_to_uint256(data) AS DOUBLE) / 1e18 as transfer_amount_decimal,
        block_time,
        tx_hash
    FROM bnb.logs 
    WHERE contract_address = 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
      AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
      AND bytearray_substring(topic2, 13, 20) != 0x0000000000000000000000000000000000000000
      AND block_date >= TIMESTAMP '2025-10-02 00:00:00'
),
first_receive AS (
    SELECT 
        to_address,
        MIN(block_time) as first_receive_time,
        DATE_TRUNC('day', MIN(block_time)) as join_date
    FROM all_transfers
    GROUP BY to_address
),
daily_new_holders AS (
    SELECT 
        join_date,
        COUNT(*) as new_holders
    FROM first_receive
    GROUP BY join_date
)
SELECT 
    join_date as date,
    new_holders,
    SUM(new_holders) OVER (ORDER BY join_date) as cumulative_holders,
    -- 7天移动平均
    AVG(new_holders) OVER (
        ORDER BY join_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as ma_7day,
    -- 30天移动平均
    AVG(new_holders) OVER (
        ORDER BY join_date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) as ma_30day
FROM daily_new_holders
ORDER BY join_date DESC;

