#REVENUE LEAKAGE ANALYSIS
#1. What is the total revenue leakage from refunds, pricing errors, and waived penalties?
WITH refund_leakage AS (
    SELECT SUM(refund_amount) AS amount, 'Refunds' AS leakage_type
    FROM   refunds
),
pricing_leakage AS (
    SELECT SUM(price_diff) AS amount, 'Pricing Errors' AS leakage_type
    FROM   pricing_audit
    WHERE  price_diff > 0          
      AND  flagged    = 1
),
penalty_leakage AS (
    SELECT SUM(penalty_waived) AS amount, 'Waived Penalties' AS leakage_type
    FROM   refunds
    WHERE  penalty_waived > 0
)
SELECT
    leakage_type,
    ROUND(amount, 2)                                        AS leakage_inr,
    ROUND(amount * 100.0 / SUM(amount) OVER(), 2)         AS share_pct
FROM (
    SELECT * FROM refund_leakage
    UNION ALL
    SELECT * FROM pricing_leakage
    UNION ALL
    SELECT * FROM penalty_leakage
) all_leakage
ORDER BY leakage_inr DESC;

#2. Which booking category has the highest refund rate, and how does it trend month-over-month?
SELECT
    b.trip_type,
    DATE_FORMAT(b.booking_date, '%Y-%m')  AS month,
    COUNT(b.booking_id)                   AS total_bookings,
    COUNT(r.refund_id)                    AS refunded_count,
    ROUND(SUM(r.refund_amount), 2)        AS refund_value,
    ROUND(
        COUNT(r.refund_id) * 100.0 / COUNT(b.booking_id), 2
    )                                     AS refund_rate_pct,
    LAG(
        ROUND(COUNT(r.refund_id) * 100.0 / COUNT(b.booking_id),2)
    ) OVER (PARTITION BY b.trip_type ORDER BY DATE_FORMAT(b.booking_date,'%Y-%m'))
										 AS prev_month_rate
FROM        bookings b
LEFT JOIN   refunds  r  ON b.booking_id = r.booking_id
GROUP BY b.trip_type, month
ORDER BY b.trip_type, month;

#3. Which coupons have been redeemed beyond their usage limits (coupon abuse)?
SELECT
    c.coupon_code,
    c.discount_type,
    c.discount_value,
    c.usage_limit,
    c.used_count,
    (c.used_count - c.usage_limit)       AS excess_uses,
    ROUND(
        (c.used_count - c.usage_limit)
        * LEAST(c.discount_value, c.max_discount_cap), 2
    )                                    AS estimated_loss_inr,
    c.eligible_tier,
    COUNT(DISTINCT b.user_id)            AS unique_abusers
FROM coupons c
JOIN  bookings b  ON c.coupon_id = b.coupon_id
WHERE  c.used_count > c.usage_limit
GROUP BY  c.coupon_id
ORDER BY  estimated_loss_inr DESC;

#4. What is the revenue lost due to incomplete/pending bookings that were never paid?
SELECT
    trip_type,
    channel,
    COUNT(booking_id)         AS abandoned_count,
    ROUND(SUM(final_fare), 2) AS potential_revenue_lost,
    ROUND(AVG(final_fare), 2) AS avg_abandoned_value,
    ROUND(
        COUNT(booking_id) * 100.0
        / SUM(COUNT(booking_id)) OVER(PARTITION BY trip_type), 2
    )                        AS channel_share_pct
FROM   bookings
WHERE  booking_status  = 'Pending'
  AND  payment_status  = 'Failed'
GROUP BY trip_type, channel
ORDER BY potential_revenue_lost DESC;

#5. Where are pricing discrepancies the largest — by route and trip type?
SELECT
    b.origin,
    b.destination,
    b.trip_type,
    COUNT(pa.audit_id)            AS flagged_bookings,
    ROUND(SUM(pa.price_diff), 2)  AS total_under_charged,
    ROUND(AVG(pa.price_diff), 2)  AS avg_discrepancy,
    MAX(pa.diff_reason)           AS primary_cause
FROM        pricing_audit  pa
JOIN        bookings       b      ON pa.booking_id = b.booking_id
WHERE  pa.flagged    = 1
  AND  pa.price_diff > 0
GROUP BY b.origin, b.destination, b.trip_type
ORDER BY total_under_charged DESC
LIMIT 10;

#6. Which users have the highest chargeback/dispute history, and what is the financial exposure?
SELECT
    u.user_id,
    u.user_name,
    u.tier,
    u.city,
    COUNT(b.booking_id) AS total_bookings,
    SUM(CASE WHEN b.payment_status = 'Disputed' THEN 1 ELSE 0 END)
                        AS dispute_count,
    ROUND(SUM(CASE WHEN b.payment_status = 'Disputed'
                    THEN b.final_fare ELSE 0 END), 2)AS disputed_value,
    ROUND(
        SUM(CASE WHEN b.payment_status = 'Disputed' THEN 1 ELSE 0 END) * 100.0
        / COUNT(b.booking_id), 2
    ) AS dispute_rate_pct
FROM        users     u
JOIN        bookings  b  ON u.user_id = b.user_id
GROUP BY  u.user_id
HAVING    dispute_count >= 3
ORDER BY  disputed_value DESC
LIMIT 10;

#7. Which agents are being over-paid commission relative to the business they generate?
SELECT
    a.agent_id,
    a.agent_name,
    a.region,
    a.commission_pct            AS agreed_pct,
    ROUND(SUM(b.final_fare), 2) AS total_revenue_generated,
    ROUND(
        SUM(b.final_fare) * a.commission_pct / 100, 2
    )                          AS expected_commission,
    a.actual_commission_paid,
    ROUND(
        a.actual_commission_paid
        - (SUM(b.final_fare) * a.commission_pct / 100), 2
    )                         AS overpayment
FROM        agents    a
JOIN        bookings  b  ON a.agent_id = b.agent_id
WHERE  b.payment_status = 'Paid'
GROUP BY  a.agent_id
HAVING    overpayment  > 0
ORDER BY  overpayment  DESC;

#8. How much cancellation penalty was waived unnecessarily, and by whom?
SELECT
    r.initiated_by,
    b.trip_type,
    COUNT(r.refund_id)              AS waiver_count,
    ROUND(SUM(r.penalty_waived), 2) AS total_waived,
    ROUND(AVG(r.penalty_waived), 2) AS avg_waiver_per_case,
    ROUND(
        SUM(r.penalty_waived) * 100.0
        / SUM(SUM(r.penalty_waived)) OVER(), 2
    )                              AS share_of_total_waived
FROM        refunds   r
JOIN        bookings  b  ON r.booking_id = b.booking_id
WHERE  r.penalty_waived > 0
GROUP BY r.initiated_by, b.trip_type
ORDER BY total_waived DESC;

#9. What is the revenue impact of No-Show bookings where the fare was collected but service not rendered?
WITH noshow_data AS (
    SELECT
        b.booking_id,
        b.trip_type,
        b.final_fare,
        b.channel,
        DATEDIFF(b.travel_date, b.booking_date) AS advance_days,
        r.refund_amount
    FROM        bookings b
    LEFT JOIN   refunds  r  ON b.booking_id = r.booking_id
    WHERE  b.booking_status = 'No-Show'
      AND  b.payment_status = 'Paid'
)
SELECT
    trip_type,
    COUNT(*) AS noshow_count,
    ROUND(SUM(final_fare), 2)AS refunded_post_noshow,
    ROUND(
        SUM(final_fare) - COALESCE(SUM(refund_amount), 0), 2
    ) AS net_retained,
    ROUND(AVG(advance_days), 0)AS avg_advance_booking_days
FROM   noshow_data
GROUP BY trip_type
ORDER BY fare_collected DESC;

#10. Which agents contribute the most to revenue leakage through cancellations, refunds, and pricing overrides — combined?

WITH agent_bookings AS (
    SELECT
        b.agent_id,
        COUNT(b.booking_id) AS total_bookings,
        SUM(b.final_fare)   AS gross_revenue,
        SUM(CASE WHEN b.booking_status = 'Cancelled'
                    THEN b.final_fare ELSE 0 END)AS cancelled_value
    FROM  bookings b
    WHERE b.agent_id IS NOT NULL
    GROUP BY b.agent_id
),
agent_refunds AS (
    SELECT
        b.agent_id,
        SUM(r.refund_amount) AS total_refunds,
        SUM(r.penalty_waived)AS total_waivers
    FROM        refunds   r
    JOIN        bookings  b  ON r.booking_id = b.booking_id
    WHERE  b.agent_id IS NOT NULL
    GROUP BY b.agent_id
),
agent_pricing AS (
    SELECT
        b.agent_id,
        SUM(pa.price_diff) AS pricing_loss
    FROM        pricing_audit  pa
    JOIN        bookings       b   ON pa.booking_id = b.booking_id
    WHERE  b.agent_id IS NOT NULL
      AND  pa.flagged = 1
    GROUP BY b.agent_id
)
SELECT
    a.agent_name,
    a.region,
    ab.total_bookings,
    ROUND(ab.gross_revenue, 2)AS gross_revenue,
    ROUND(COALESCE(ar.total_refunds, 0), 2)AS refunds,
    ROUND(COALESCE(ar.total_waivers, 0), 2)AS waivers,
    ROUND(COALESCE(ap.pricing_loss, 0), 2)AS pricing_override_loss,
    ROUND(
        COALESCE(ar.total_refunds, 0)
        + COALESCE(ar.total_waivers, 0)
        + COALESCE(ap.pricing_loss, 0), 2
    ) AS total_leakage,
    RANK() OVER (
        ORDER BY
            COALESCE(ar.total_refunds,0)
            + COALESCE(ar.total_waivers,0)
            + COALESCE(ap.pricing_loss,0) DESC
    )AS risk_rank
FROM            agents         a
JOIN            agent_bookings ab ON a.agent_id = ab.agent_id
LEFT JOIN       agent_refunds  ar ON a.agent_id = ar.agent_id
LEFT JOIN       agent_pricing  ap  ON a.agent_id = ap.agent_id
ORDER BY risk_rank
LIMIT 8;


