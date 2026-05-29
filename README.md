Project Overview
MakeMyTrip processes millions of travel bookings across flights, hotels, and holiday packages. Amid this scale, revenue leakage — money that should have been earned but was lost due to discounts, pricing mismatches, coupon misuse, or agent-level discrepancies — can go undetected and cost the business significantly.
This project dives deep into multi-year transactional data to identify where, why, and how much revenue is leaking, and what patterns emerge across different leakage types, agents, users, and payment gateways.
  Problem Statements
1.	What is the total revenue leakage from refunds, pricing errors, and waived penalties?
2.	Which booking category has the highest refund rate, and how does it trend month-over-month?
3.	Which coupons have been redeemed beyond their usage limits (coupon abuse)?
4.	What is the revenue lost due to incomplete/pending bookings that were never paid?
5.	Where are pricing discrepancies the largest — by route and trip type?
6.	Which users have the highest chargeback/dispute history, and what is the financial exposure?
7.	Which agents are being over-paid commission relative to the business they generate?
8.	How much cancellation penalty was waived unnecessarily, and by whom?
9.	What is the revenue impact of No-Show bookings where the fare was collected but service not rendered?
10.	Which agents contribute the most to revenue leakage through cancellations, refunds, and pricing overrides — combined?
Without a structured analytical framework, these losses accumulate silently over time. This project builds that framework — from raw data to actionable insights — to help quantify and address revenue leakage systematically.
  Project Objectives
	Identify and quantify revenue leakage across multiple years of booking data
	Analyze root causes and leakage types driving the highest losses
	Measure the recovery rate and highlight unrecovered revenue at risk
	Surface patterns tied to specific agents, users, coupons, and payment gateways
	Answer 10 targeted business questions through structured SQL analysis
  Tools & Technologies
Tools used
o	SQL
o	Excel
o	Power BI
� Power BI
Interactive dashboard, KPI cards, and visual storytelling
� MySQL Workbench
Database creation, data import, EDA, and business queries
� Microsoft Excel
Source data preparation
  CSV Files
Raw data import into MySQL tables
  Dataset Information
	Detail
	Description
	Source
	MakeMyTrip (simulated/sourced transactional data)
	File Formats
	.xlsx (Excel), .csv
	Time Period
	Multi-year booking and transaction records
	Tables Created
	agents, coupons, users, pricing_audit
	Table Descriptions
	agents — Agent-level transaction and booking records
	coupons — Coupon usage, discount types, and associated revenue impact
	users — User profiles and booking activity
	pricing_audit — Quoted vs. charged pricing records for discrepancy detection




  Power BI Dashboard
The dashboard translates raw data into a clear picture of revenue health across the organization.
 
	KPI Cards
	Metric
	Description
	Recovery Rate
	% of leaked revenue successfully reclaimed
	Recovered Revenue
	Total revenue recovered after leakage events
	Unrecovered Revenue
	Revenue still lost or at risk
	YTD Revenue Leakage
	Cumulative year-to-date leakage amount
  Charts & Visuals
Revenue Leakage Trend Over Time — Line chart tracking leakage patterns across multiple years
Top Root Causes of Revenue Leakage — Ranked view of the primary drivers behind revenue loss
Total Leakage Amount by Leakage Type — Breakdown across leakage categories (coupon abuse, pricing mismatch, gateway issues, etc.)
Top Routes / Destinations by Leakage — Highlights which travel routes or destination segments contribute most to leakage
Payment Gateway Analysis — Identifies gateway-specific leakage and recovery behavior
  SQL Analysis
Workflow
Schema Design — Created relational tables for agents, coupons, users, and pricing audit data
Data Import — Loaded Excel and CSV files into MySQL tables
Exploratory Data Analysis (EDA) — Investigated distributions, nulls, relationships, and anomalies
Business Problem Solving — Wrote and executed 10 targeted SQL queries to answer real business questions
Sample Business Questions Addressed
Which agents are responsible for the highest revenue leakage?
What coupon types lead to the most over-discounting?
How does leakage vary across years and booking periods?
Which payment gateways have the lowest recovery rates?
What is the total unrecovered revenue by leakage type?
  Key Insights
  Revenue leakage is concentrated in a small subset of agents and coupon categories, suggesting targeted intervention can yield outsized recovery
  Coupon misuse emerged as one of the leading root causes of leakage, with certain discount codes being applied beyond their intended scope
  Payment gateway behavior varies significantly — some gateways show consistently lower recovery rates, indicating a systemic issue
  Multi-year trend analysis revealed leakage spikes during peak travel seasons, pointing to process gaps under high transaction volumes
  Recovery rate leaves meaningful room for improvement, with a significant portion of leakage remaining unrecovered across all years.
