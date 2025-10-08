-- BSC Token Holder Growth Over Time
-- Contract: 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
-- 追踪holder数量随时间的增长趋势

WITH all_transfers AS (
    SELECT 
        bytearray_substring(topic1, 13, 20) as from_address,
        bytearray_substring(topic2, 13, 20) as to_address,
        CAST(bytearray_to_uint256(data) AS DOUBLE) / 1e18 as transfer_amount_decimal,
        DATE_TRUNC('day', block_time) as transfer_date,
        block_time
    FROM bnb.logs 
    WHERE contract_address = 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
      AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
     AND block_date >= TIMESTAMP '2025-10-02 00:00:00'
),
daily_dates AS (
    SELECT DISTINCT transfer_date
    FROM all_transfers
    ORDER BY transfer_date
),
-- 计算每天每个地址的累计余额
address_daily_balance AS (
    SELECT 
        d.transfer_date,
        addresses.address,
        SUM(
            CASE 
                WHEN t.transfer_date <= d.transfer_date THEN 
                    CASE WHEN transfer_type = 'in' THEN amount ELSE -amount END
                ELSE 0
            END
        ) as balance
    FROM daily_dates d
    CROSS JOIN (
        SELECT DISTINCT address FROM (
            SELECT to_address as address FROM all_transfers
            WHERE to_address != 0x0000000000000000000000000000000000000000
            UNION
            SELECT from_address as address FROM all_transfers
            WHERE from_address != 0x0000000000000000000000000000000000000000
        )
    ) addresses
    LEFT JOIN (
        SELECT transfer_date, to_address as address, transfer_amount_decimal as amount, 'in' as transfer_type
        FROM all_transfers
        WHERE to_address != 0x0000000000000000000000000000000000000000
        UNION ALL
        SELECT transfer_date, from_address as address, transfer_amount_decimal as amount, 'out' as transfer_type
        FROM all_transfers
        WHERE from_address != 0x0000000000000000000000000000000000000000
    ) t ON addresses.address = t.address
    GROUP BY d.transfer_date, addresses.address
),
-- 统计每天的holder数量
daily_holder_stats AS (
    SELECT 
        transfer_date,
        COUNT(CASE WHEN balance > 0 THEN 1 END) as total_holders,
        -- 按持仓量分类
        COUNT(CASE WHEN balance >= 1000000 THEN 1 END) as whales,
        COUNT(CASE WHEN balance >= 100000 AND balance < 1000000 THEN 1 END) as large_holders,
        COUNT(CASE WHEN balance >= 10000 AND balance < 100000 THEN 1 END) as medium_holders,
        COUNT(CASE WHEN balance >= 1000 AND balance < 10000 THEN 1 END) as small_holders,
        COUNT(CASE WHEN balance >= 1 AND balance < 1000 THEN 1 END) as mini_holders,
        -- 总供应量
        SUM(CASE WHEN balance > 0 THEN balance ELSE 0 END) as circulating_supply,
        -- 平均持仓
        AVG(CASE WHEN balance > 0 THEN balance END) as avg_holding,
        -- 中位数持仓（近似）
        APPROX_PERCENTILE(CASE WHEN balance > 0 THEN balance END, 0.5) as median_holding
    FROM address_daily_balance
    GROUP BY transfer_date
)
SELECT 
    transfer_date as date,
    total_holders,
    whales,
    large_holders,
    medium_holders,
    small_holders,
    mini_holders,
    circulating_supply,
    ROUND(avg_holding, 2) as avg_holding,
    ROUND(median_holding, 2) as median_holding,
    -- 计算增长率
    total_holders - LAG(total_holders, 1) OVER (ORDER BY transfer_date) as holder_growth,
    ROUND(
        (total_holders - LAG(total_holders, 1) OVER (ORDER BY transfer_date)) * 100.0 
        / NULLIF(LAG(total_holders, 1) OVER (ORDER BY transfer_date), 0),
        2
    ) as holder_growth_pct,
    -- 计算集中度（top holders占比）
    ROUND(
        (whales + large_holders) * 100.0 / NULLIF(total_holders, 0),
        2
    ) as concentration_pct
FROM daily_holder_stats
ORDER BY transfer_date DESC;

