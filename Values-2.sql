INSERT INTO users (user_name,email,city,tier,signup_date,is_corporate)
 VALUES
  ('Aarav Mehta',   'aarav@example.com',   'Mumbai',  'Gold',     '2022-03-10', 0),
  ('Priya Sharma',  'priya@example.com',   'Delhi',   'Platinum', '2021-07-22', 1),
  ('Rohan Joshi',   'rohan@example.com',   'Bengaluru','Silver',  '2023-01-05', 0),
  ('Sneha Pillai',  'sneha@example.com',   'Chennai', 'Bronze',   '2023-08-19', 0),
  ('Karan Tiwari',  'karan@example.com',   'Kolkata', 'Gold',     '2022-11-30', 1);
  
  INSERT INTO coupons (coupon_code,discount_type,discount_value,max_discount_cap,
              min_booking_value,valid_from,valid_to,usage_limit,used_count,eligible_tier) 
  VALUES
  ('FIRST500',  'Flat',       500, 500,  2000, '2024-01-01', '2024-12-31', 1,  4820, 'ALL'),
  ('GOLDFLY20', 'Percentage', 20,  2000, 5000, '2024-04-01', '2024-06-30', 500, 812,  'Gold'),
  ('HOTELDEAL', 'Flat',       800, 800,  3000, '2024-03-15', '2024-05-15', 200, 634,  'ALL'),
  ('CORP15',    'Percentage', 15,  3000, 8000, '2024-01-01', '2024-12-31', 999, 290,  'Platinum');
  
  INSERT INTO bookings (user_id,trip_type,booking_date,travel_date,origin,destination,
               base_fare,final_fare,booking_status,payment_status,coupon_id,channel) VALUES
  (1, 'Flight', '2024-03-12', '2024-04-10', 'BOM', 'DEL', 8500,  8000,  'Confirmed',  'Paid',     2, 'App'),
  (2, 'Hotel',  '2024-03-18', '2024-04-20', 'Delhi','Goa',   12000, 11200, 'Confirmed',  'Paid',     3, 'Web'),
  (3, 'Flight', '2024-04-02', '2024-04-15', 'BLR', 'HYD', 4200,  3700,  'Cancelled', 'Refunded',  1, 'App'),
  (4, 'Bus',    '2024-04-10', '2024-04-25', 'Chennai','Bangalore',900, 900,'Confirmed','Paid',NULL,'Web'),
  (5, 'Flight', '2024-04-14', '2024-05-01', 'CCU', 'BOM', 9800,  9800,  'No-Show',   'Paid',    NULL, 'Agent');
    

  
  