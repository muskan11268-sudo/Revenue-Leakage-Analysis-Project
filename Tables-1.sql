CREATE DATABASE sql_project;
USE sql_project;
CREATE TABLE users(
	user_id int primary key auto_increment,
    user_name VARCHAR(120),
    email VARCHAR(180),
    phone VARCHAR(15),
    city VARCHAR(80),
    tier ENUM("Bronze","Silver","Gold","Platinum"),
    signup_date DATE,
    is_corporate TINYINT(1) DEFAULT 0
);
CREATE TABLE coupons(
            coupon_id int primary key auto_increment,
            coupon_code VARCHAR(30),
            discount_type ENUM('flat','Percentage'),
            discont_value DECIMAL (10,2),
            max_discount_cap DECIMAL (10,2),
            min_booking_vaue DATE,
            valid_from DATE,
            valid_to INT,
	        usage_limit INT,
            used_count INT,
            eligible_tier VARCHAR(20)
            );
            ALTER TABLE coupons 
            RENAME COLUMN discont_value to discount_value;
            ALTER TABLE coupons 
            RENAME COLUMN min_booking_vaue to min_booking_value;
            ALTER TABLE coupons 
            MODIFY COLUMN min_booking_vaLue DECIMAL(10,2);
            ALTER TABLE coupons 
            MODIFY COLUMN valid_to DATE;
CREATE TABLE agents ( 
                  agent_id INT primary key auto_increment,
                  agent_name VARCHAR(150),
                  region VARCHAR(50),
                  commision_pct DECIMAL(5,2),
                  actual_commission_paid DECIMAL (12,2) DEFAULT 0,
                  performance_tier ENUM('Stadard','Premium'),
                  active TINYINT(1) DEFAULT 1
            );
            ALTER TABLE agents
            RENAME COLUMN commision_pct to commission_pct;
  CREATE TABLE bookings(
                     booking_id int PRIMARY KEY auto_increment ,
                     user_id int,
                     trip_type ENUM('flight','hotel','bus','train','holiday'),
                     booking_date DATE,
                     travel_date DATE,
                     origin VARCHAR(80),
                     destination VARCHAR(80),
                     base_fare DECIMAL(10,2),
                     final_fare DECIMAL(10,2),
                     booking_status ENUM('Confirmed','Cancelled','Pending','No-show'),
                     payment_status ENUM('Paid','Refunded','Disputed','Failed'),
                     coupon_id int DEFAULT NULL,
                     agent_id int DEFAULT NULL,
                     channel ENUM('App','Web','Agent','Call-center'),
                     FOREIGN KEY (user_id) REFERENCES users(user_id),
                     FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id),
                     FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
                     );
                     
         CREATE TABLE refunds(
                         refund_id INT primary key ,
                         booking_id INT ,
                         refund_amount DECIMAL(10,2),
                         refund_reason VARCHAR(200),
                         refund_date DATE,
                         refund_type ENUM('Full','Partial'),
                         initiated_by ENUM('User','System','Agent'),
                         penalty_waived DECIMAL(10,2) DEFAULT 0,
                         FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
                         );
                     
		CREATE TABLE pricing_audit(
    audit_id        INT PRIMARY KEY AUTO_INCREMENT,
    booking_id      INT NOT NULL,
    expected_price  DECIMAL(10,2),
    charged_price   DECIMAL(10,2),
    price_diff      DECIMAL(10,2),
    diff_reason     VARCHAR(200),
    flagged         TINYINT(1)    DEFAULT 0,
    audit_date      DATE,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);           
                     
                     
                     
                     
                     
                     
				     
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
