#EDA 1: Overall booking distribution by trip type
SELECT
    trip_type,
    COUNT(booking_id)AS total_bookings,
    SUM(final_fare)  AS total_revenue,
    ROUND(AVG(final_fare), 2) AS avg_fare,
    SUM(base_fare - final_fare)AS total_discount_given,
    ROUND(
        SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0
        / COUNT(booking_id), 2
    )                                                          AS cancellation_rate_pct
FROM   bookings
GROUP BY trip_type
ORDER BY total_revenue DESC;


-- EDA 2: Payment status distribution (leak signals)
SELECT
    payment_status,
    COUNT(*) AS count,
    ROUND(SUM(final_fare), 2) AS total_value,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_total
FROM   bookings
GROUP BY payment_status
ORDER BY count DESC;

-- EDA 3: Monthly revenue vs refund trend
SELECT
    DATE_FORMAT(b.booking_date, '%Y-%m') AS month,
    SUM(b.final_fare)                    AS gross_revenue,
    COALESCE(SUM(r.refund_amount), 0)    AS total_refunds,
    SUM(b.final_fare) - COALESCE(SUM(r.refund_amount), 0) AS net_revenue,
    ROUND(
        COALESCE(SUM(r.refund_amount), 0) * 100.0
        / NULLIF(SUM(b.final_fare), 0), 2
    ) AS refund_rate_pct
FROM        bookings b
LEFT JOIN   refunds  r  ON b.booking_id = r.booking_id
GROUP BY DATE_FORMAT(b.booking_date, '%Y-%m')
ORDER BY month;
