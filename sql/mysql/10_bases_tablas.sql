CREATE DATABASE IF NOT EXISTS `marketing_funnel` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON `marketing_funnel`.* TO 'olist'@'%';

CREATE TABLE IF NOT EXISTS `marketing_funnel`.`closed_deals` (
    `mql_id` VARCHAR(128),
    `seller_id` VARCHAR(128),
    `sdr_id` VARCHAR(128),
    `sr_id` VARCHAR(128),
    `won_date` DATETIME,
    `business_segment` VARCHAR(64),
    `lead_type` VARCHAR(64),
    `lead_behaviour_profile` VARCHAR(64),
    `has_company` DOUBLE,
    `has_gtin` DOUBLE,
    `average_stock` VARCHAR(64),
    `business_type` VARCHAR(92),
    `declared_product_catalog_size` DOUBLE,
    `declared_monthly_revenue` DOUBLE
);

CREATE TABLE IF NOT EXISTS `marketing_funnel`.`mql` (
    `mql_id` VARCHAR(128),
    `first_contact_date` DATETIME,
    `landing_page_id` VARCHAR(128),
    `origin` VARCHAR(64)
);

CREATE DATABASE IF NOT EXISTS `customer_service` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON `customer_service`.* TO 'olist'@'%';

CREATE TABLE IF NOT EXISTS `customer_service`.`customers_crm` (
    `crm_customer_id` VARCHAR(64),
    `customer_id` VARCHAR(128),
    `customer_unique_id` VARCHAR(128),
    `registration_date` DATETIME,
    `customer_segment` VARCHAR(64),
    `preferred_channel` VARCHAR(64),
    `loyalty_level` VARCHAR(64),
    `status` VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS `customer_service`.`escalations` (
    `escalation_id` VARCHAR(64),
    `ticket_id` VARCHAR(64),
    `escalation_date` DATETIME,
    `escalation_reason` VARCHAR(64),
    `escalation_level` VARCHAR(64),
    `resolved_date` DATETIME,
    `final_status` VARCHAR(80)
);

CREATE TABLE IF NOT EXISTS `customer_service`.`service_agents` (
    `agent_id` VARCHAR(64),
    `agent_name` VARCHAR(64),
    `team` VARCHAR(68),
    `region` VARCHAR(64),
    `hiring_date` DATETIME,
    `status` VARCHAR(64),
    `experience_level` VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS `customer_service`.`service_satisfaction` (
    `survey_id` VARCHAR(64),
    `ticket_id` VARCHAR(64),
    `survey_date` DATETIME,
    `satisfaction_score` DOUBLE,
    `recommendation_score` DOUBLE,
    `comment_text` VARCHAR(212)
);

CREATE TABLE IF NOT EXISTS `customer_service`.`service_tickets` (
    `ticket_id` VARCHAR(64),
    `customer_id` VARCHAR(128),
    `order_id` VARCHAR(128),
    `assigned_agent_id` VARCHAR(64),
    `ticket_date` DATETIME,
    `ticket_channel` VARCHAR(64),
    `issue_category` VARCHAR(64),
    `issue_subcategory` VARCHAR(64),
    `priority` VARCHAR(64),
    `status` VARCHAR(64),
    `first_response_timestamp` DATETIME,
    `resolution_timestamp` DATETIME,
    `satisfaction_score` DOUBLE,
    `escalation_flag` TINYINT(1)
);

CREATE TABLE IF NOT EXISTS `customer_service`.`ticket_interactions` (
    `interaction_id` VARCHAR(64),
    `ticket_id` VARCHAR(64),
    `interaction_timestamp` DATETIME,
    `agent_id` VARCHAR(64),
    `channel` VARCHAR(64),
    `interaction_type` VARCHAR(64),
    `response_time_minutes` DOUBLE,
    `interaction_text` VARCHAR(396),
    `sentiment_label` VARCHAR(64)
);

CREATE DATABASE IF NOT EXISTS `marketing_campaigns` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON `marketing_campaigns`.* TO 'olist'@'%';

CREATE TABLE IF NOT EXISTS `marketing_campaigns`.`campaign_audience` (
    `audience_id` VARCHAR(64),
    `campaign_id` VARCHAR(64),
    `customer_segment` VARCHAR(80),
    `region` VARCHAR(64),
    `category` VARCHAR(64),
    `audience_size` BIGINT
);

CREATE TABLE IF NOT EXISTS `marketing_campaigns`.`campaign_channels` (
    `campaign_channel_id` VARCHAR(64),
    `campaign_id` VARCHAR(64),
    `channel` VARCHAR(64),
    `planned_budget` DOUBLE,
    `actual_budget` DOUBLE
);

CREATE TABLE IF NOT EXISTS `marketing_campaigns`.`campaign_daily_metrics` (
    `campaign_id` VARCHAR(64),
    `metric_date` DATETIME,
    `impressions` BIGINT,
    `clicks` BIGINT,
    `leads` BIGINT,
    `conversions` BIGINT,
    `spend` DOUBLE,
    `revenue` DOUBLE,
    `conversion_rate` DOUBLE,
    `roi` DOUBLE
);

CREATE TABLE IF NOT EXISTS `marketing_campaigns`.`campaign_events` (
    `event_id` VARCHAR(64),
    `campaign_id` VARCHAR(64),
    `customer_id` VARCHAR(128),
    `event_timestamp` DATETIME,
    `event_type` VARCHAR(64),
    `channel` VARCHAR(64),
    `device_type` VARCHAR(64),
    `region` VARCHAR(64),
    `conversion_flag` TINYINT(1)
);

CREATE TABLE IF NOT EXISTS `marketing_campaigns`.`campaign_sales` (
    `campaign_id` VARCHAR(64),
    `order_id` VARCHAR(128),
    `order_item_id` BIGINT,
    `product_id` VARCHAR(128),
    `seller_id` VARCHAR(128),
    `attribution_type` VARCHAR(64),
    `attributed_revenue` DOUBLE,
    `discount_amount` DOUBLE
);

CREATE TABLE IF NOT EXISTS `marketing_campaigns`.`campaigns` (
    `campaign_id` VARCHAR(64),
    `campaign_name` VARCHAR(112),
    `campaign_type` VARCHAR(64),
    `start_date` DATETIME,
    `end_date` DATETIME,
    `objective` VARCHAR(64),
    `budget` DOUBLE,
    `target_segment` VARCHAR(80),
    `status` VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS `marketing_campaigns`.`promotions` (
    `promotion_id` VARCHAR(64),
    `campaign_id` VARCHAR(64),
    `product_id` VARCHAR(128),
    `seller_id` VARCHAR(128),
    `promotion_type` VARCHAR(64),
    `discount_percentage` DOUBLE,
    `start_date` DATETIME,
    `end_date` DATETIME,
    `maximum_redemptions` DOUBLE
);

CREATE DATABASE IF NOT EXISTS `external_carrier` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON `external_carrier`.* TO 'olist'@'%';

CREATE TABLE IF NOT EXISTS `external_carrier`.`carrier_events` (
    `carrier_event_id` VARCHAR(64),
    `shipment_id` VARCHAR(64),
    `carrier_id` VARCHAR(64),
    `event_timestamp` DATETIME,
    `event_timestamp_raw` DATETIME,
    `event_type` VARCHAR(64),
    `event_status` VARCHAR(64),
    `location` VARCHAR(64),
    `hub_id` VARCHAR(64),
    `exception_code` VARCHAR(64),
    `description` VARCHAR(288)
);

CREATE TABLE IF NOT EXISTS `external_carrier`.`carrier_hubs` (
    `hub_id` VARCHAR(64),
    `hub_name` VARCHAR(72),
    `city` VARCHAR(64),
    `state` VARCHAR(64),
    `region` VARCHAR(64),
    `latitude` DOUBLE,
    `longitude` DOUBLE
);

CREATE TABLE IF NOT EXISTS `external_carrier`.`carrier_incidents` (
    `incident_id` VARCHAR(64),
    `shipment_id` VARCHAR(64),
    `carrier_id` VARCHAR(64),
    `incident_type` VARCHAR(64),
    `incident_timestamp` DATETIME,
    `severity` VARCHAR(64),
    `resolution_status` VARCHAR(64),
    `resolution_timestamp` DATETIME
);

CREATE TABLE IF NOT EXISTS `external_carrier`.`carrier_shipments` (
    `shipment_id` VARCHAR(64),
    `order_id` VARCHAR(128),
    `carrier_id` VARCHAR(64),
    `origin_region` VARCHAR(64),
    `destination_region` VARCHAR(64),
    `shipment_created_at` DATETIME,
    `promised_delivery_date` DATETIME,
    `actual_delivery_date` DATETIME,
    `shipment_status` VARCHAR(64),
    `seller_id` VARCHAR(128),
    `customer_id` VARCHAR(128)
);

CREATE TABLE IF NOT EXISTS `external_carrier`.`carriers` (
    `carrier_id` VARCHAR(64),
    `carrier_name` VARCHAR(84),
    `carrier_type` VARCHAR(64),
    `service_level` VARCHAR(64),
    `region` VARCHAR(64),
    `active_flag` BIGINT
);

CREATE DATABASE IF NOT EXISTS `payment_gateway` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON `payment_gateway`.* TO 'olist'@'%';

CREATE TABLE IF NOT EXISTS `payment_gateway`.`chargebacks` (
    `chargeback_id` VARCHAR(64),
    `gateway_transaction_id` VARCHAR(64),
    `order_id` VARCHAR(128),
    `chargeback_date` DATETIME,
    `chargeback_amount` DOUBLE,
    `reason_category` VARCHAR(80),
    `status` VARCHAR(64),
    `resolution_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `payment_gateway`.`gateway_events` (
    `gateway_event_id` VARCHAR(64),
    `gateway_transaction_id` VARCHAR(64),
    `event_timestamp` DATETIME,
    `event_type` VARCHAR(64),
    `event_status` VARCHAR(64),
    `response_code` BIGINT,
    `processing_time_ms` BIGINT
);

CREATE TABLE IF NOT EXISTS `payment_gateway`.`gateway_transactions` (
    `gateway_transaction_id` VARCHAR(64),
    `order_id` VARCHAR(128),
    `payment_id` VARCHAR(64),
    `gateway_id` VARCHAR(64),
    `transaction_timestamp` DATETIME,
    `transaction_type` VARCHAR(64),
    `amount` DOUBLE,
    `currency` VARCHAR(64),
    `authorization_status` VARCHAR(64),
    `capture_status` VARCHAR(64),
    `response_code` BIGINT,
    `processing_time_ms` DOUBLE,
    `gateway_fee` DOUBLE,
    `merchant_amount` DOUBLE,
    `payment_type_source` VARCHAR(64),
    `installments` BIGINT
);

CREATE TABLE IF NOT EXISTS `payment_gateway`.`payment_gateways` (
    `gateway_id` VARCHAR(64),
    `gateway_name` VARCHAR(68),
    `gateway_type` VARCHAR(64),
    `country` VARCHAR(64),
    `currency` VARCHAR(64),
    `active_flag` TINYINT(1),
    `api_version` VARCHAR(64),
    `settlement_cycle_days` BIGINT
);

CREATE TABLE IF NOT EXISTS `payment_gateway`.`refunds_gateway` (
    `refund_id` VARCHAR(64),
    `gateway_transaction_id` VARCHAR(64),
    `order_id` VARCHAR(128),
    `refund_timestamp` DATETIME,
    `refund_amount` DOUBLE,
    `refund_reason` VARCHAR(64),
    `refund_status` VARCHAR(64)
);

FLUSH PRIVILEGES;
