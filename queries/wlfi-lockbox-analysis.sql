WITH claim_events AS (
    SELECT 
        bytearray_substring(topic1, 13, 20) as user_address,
        bytearray_to_uint256(data) as claim_amount,
        CAST(bytearray_to_uint256(data) AS DOUBLE) / 1e18 as claim_amount_decimal,
        block_time as claim_time,
        block_number as claim_block,
        tx_hash as claim_tx
    FROM ethereum.logs 
    WHERE contract_address = 0x74B4f6A2E579D730aAcb9dD23cfbbAEb95029583
      AND topic0 = 0xd8138f8a3f377c5259ca548e70e4c2de94f129f5a11036a15b69513cba2b426a
      AND block_time >= DATE('2025-08-01')
      AND block_time <= DATE('2025-09-30')
),
token_transfers AS (
    SELECT 
        bytearray_substring(topic1, 13, 20) as from_address,
        bytearray_substring(topic2, 13, 20) as to_address,
        bytearray_to_uint256(data) as transfer_amount,
        CAST(bytearray_to_uint256(data) AS DOUBLE) / 1e18 as transfer_amount_decimal,
        block_time as transfer_time,
        block_number as transfer_block,
        tx_hash as transfer_tx
    FROM ethereum.logs 
    WHERE contract_address = 0xdA5e1988097297dCdc1f90D4dFE7909e847CBeF6
      AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
      AND block_time >= DATE('2025-08-01')
      AND block_time <= DATE('2025-09-30')
),
user_transfer_summary AS (
    SELECT 
        t.from_address,
        SUM(t.transfer_amount_decimal) as total_transferred,
        COUNT(t.transfer_amount_decimal) as transfer_count,
        MIN(t.transfer_time) as first_transfer_time,
        MAX(t.transfer_time) as last_transfer_time,
        MIN(t.transfer_block) as first_transfer_block,
        MAX(t.transfer_block) as last_transfer_block
    FROM token_transfers t
    GROUP BY t.from_address
)
SELECT 
    c.user_address,
    c.claim_amount_decimal,
    c.claim_time,
    COALESCE(uts.total_transferred, 0) as total_transferred,
    COALESCE(uts.transfer_count, 0) as transfer_count,
    uts.first_transfer_time,
    uts.last_transfer_time,
    CASE 
        WHEN c.claim_amount_decimal > 0 THEN 
            ROUND(COALESCE(uts.total_transferred, 0) * 100.0 / c.claim_amount_decimal, 2)
        ELSE 0
    END as transfer_percentage
FROM claim_events c
LEFT JOIN user_transfer_summary uts ON uts.from_address = c.user_address
ORDER BY uts.total_transferred DESC NULLS LAST;
