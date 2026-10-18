CREATE SCHEMA IF NOT EXISTS olist;

CREATE TABLE IF NOT EXISTS "olist"."customers" (
    "customer_id" VARCHAR(128),
    "customer_unique_id" VARCHAR(128),
    "customer_zip_code_prefix" BIGINT,
    "customer_city" VARCHAR(92),
    "customer_state" VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS "olist"."geolocation" (
    "geolocation_zip_code_prefix" BIGINT,
    "geolocation_lat" DOUBLE PRECISION,
    "geolocation_lng" DOUBLE PRECISION,
    "geolocation_city" VARCHAR(92),
    "geolocation_state" VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS "olist"."order_items" (
    "order_id" VARCHAR(128),
    "order_item_id" BIGINT,
    "product_id" VARCHAR(128),
    "seller_id" VARCHAR(128),
    "shipping_limit_date" TIMESTAMP,
    "price" DOUBLE PRECISION,
    "freight_value" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "olist"."order_payments" (
    "order_id" VARCHAR(128),
    "payment_sequential" BIGINT,
    "payment_type" VARCHAR(64),
    "payment_installments" BIGINT,
    "payment_value" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "olist"."order_reviews" (
    "review_id" VARCHAR(128),
    "order_id" VARCHAR(128),
    "review_score" BIGINT,
    "review_comment_title" VARCHAR(196),
    "review_comment_message" VARCHAR(868),
    "review_creation_date" TIMESTAMP,
    "review_answer_timestamp" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "olist"."orders" (
    "order_id" VARCHAR(128),
    "customer_id" VARCHAR(128),
    "order_status" VARCHAR(64),
    "order_purchase_timestamp" TIMESTAMP,
    "order_approved_at" TIMESTAMP,
    "order_delivered_carrier_date" TIMESTAMP,
    "order_delivered_customer_date" TIMESTAMP,
    "order_estimated_delivery_date" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "olist"."product_category_name_translation" (
    "product_category_name" VARCHAR(132),
    "product_category_name_english" VARCHAR(124)
);

CREATE TABLE IF NOT EXISTS "olist"."products" (
    "product_id" VARCHAR(128),
    "product_category_name" VARCHAR(132),
    "product_name_lenght" BIGINT,
    "product_description_lenght" BIGINT,
    "product_photos_qty" BIGINT,
    "product_weight_g" BIGINT,
    "product_length_cm" BIGINT,
    "product_height_cm" BIGINT,
    "product_width_cm" BIGINT
);

CREATE TABLE IF NOT EXISTS "olist"."sellers" (
    "seller_id" VARCHAR(128),
    "seller_zip_code_prefix" BIGINT,
    "seller_city" VARCHAR(92),
    "seller_state" VARCHAR(64)
);

CREATE SCHEMA IF NOT EXISTS erp_inventory;

CREATE TABLE IF NOT EXISTS "erp_inventory"."inventory" (
    "inventory_id" VARCHAR(64),
    "product_id" VARCHAR(128),
    "warehouse_id" VARCHAR(64),
    "snapshot_date" TIMESTAMP,
    "opening_stock" BIGINT,
    "received_units" BIGINT,
    "sold_units" BIGINT,
    "reserved_units" BIGINT,
    "damaged_units" BIGINT,
    "adjusted_units" BIGINT,
    "closing_stock" BIGINT,
    "reorder_point" BIGINT,
    "safety_stock" BIGINT,
    "stockout_flag" BIGINT
);

CREATE TABLE IF NOT EXISTS "erp_inventory"."inventory_movements" (
    "movement_id" VARCHAR(64),
    "product_id" VARCHAR(128),
    "warehouse_id" VARCHAR(64),
    "movement_date" TIMESTAMP,
    "movement_type" VARCHAR(64),
    "quantity" BIGINT,
    "unit_cost" DOUBLE PRECISION,
    "total_cost" DOUBLE PRECISION,
    "reference_type" VARCHAR(68),
    "reference_id" VARCHAR(128),
    "reason" VARCHAR(80),
    "created_by" VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS "erp_inventory"."product_cost_history" (
    "product_id" VARCHAR(128),
    "effective_date" TIMESTAMP,
    "unit_cost" DOUBLE PRECISION,
    "supplier_id" VARCHAR(64),
    "cost_type" VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS "erp_inventory"."products_erp_reference" (
    "product_id" VARCHAR(128),
    "product_category_name" VARCHAR(132),
    "product_weight_g" BIGINT,
    "product_length_cm" BIGINT,
    "product_height_cm" BIGINT,
    "product_width_cm" BIGINT,
    "base_unit_cost" DOUBLE PRECISION,
    "supplier_ids" VARCHAR(152),
    "warehouse_ids" VARCHAR(140)
);

CREATE TABLE IF NOT EXISTS "erp_inventory"."purchase_order_items" (
    "purchase_order_id" VARCHAR(64),
    "purchase_order_item_id" VARCHAR(64),
    "product_id" VARCHAR(128),
    "quantity_ordered" BIGINT,
    "quantity_received" DOUBLE PRECISION,
    "unit_cost" DOUBLE PRECISION,
    "discount" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "line_total" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "erp_inventory"."purchase_orders" (
    "purchase_order_id" VARCHAR(64),
    "supplier_id" VARCHAR(64),
    "warehouse_id" VARCHAR(64),
    "order_date" TIMESTAMP,
    "expected_date" TIMESTAMP,
    "received_date" TIMESTAMP,
    "status" VARCHAR(72),
    "total_amount" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "erp_inventory"."replenishment_requests" (
    "replenishment_id" VARCHAR(64),
    "product_id" VARCHAR(128),
    "warehouse_id" VARCHAR(64),
    "request_date" TIMESTAMP,
    "requested_quantity" BIGINT,
    "approved_quantity" DOUBLE PRECISION,
    "priority" VARCHAR(64),
    "status" VARCHAR(64),
    "expected_delivery_date" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "erp_inventory"."supplier_performance" (
    "supplier_id" VARCHAR(64),
    "evaluation_date" TIMESTAMP,
    "delivery_delay_days" DOUBLE PRECISION,
    "quality_score" DOUBLE PRECISION,
    "fulfillment_rate" DOUBLE PRECISION,
    "defect_rate" DOUBLE PRECISION,
    "service_score" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "erp_inventory"."suppliers" (
    "supplier_id" VARCHAR(64),
    "supplier_name" VARCHAR(76),
    "supplier_type" VARCHAR(64),
    "city" VARCHAR(84),
    "state" VARCHAR(64),
    "country" VARCHAR(64),
    "registration_date" TIMESTAMP,
    "status" VARCHAR(64),
    "lead_time_days" DOUBLE PRECISION,
    "payment_terms" VARCHAR(64),
    "supplier_rating" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "erp_inventory"."warehouses" (
    "warehouse_id" VARCHAR(64),
    "warehouse_name" VARCHAR(104),
    "city" VARCHAR(92),
    "state" VARCHAR(64),
    "capacity_units" BIGINT,
    "warehouse_type" VARCHAR(76),
    "status" VARCHAR(64)
);

CREATE SCHEMA IF NOT EXISTS logistics_tms;

CREATE TABLE IF NOT EXISTS "logistics_tms"."carrier_performance" (
    "carrier_id" VARCHAR(64),
    "evaluation_date" DATE,
    "on_time_rate" DOUBLE PRECISION,
    "average_delay_minutes" DOUBLE PRECISION,
    "failed_delivery_rate" DOUBLE PRECISION,
    "damage_rate" DOUBLE PRECISION,
    "cost_per_km" DOUBLE PRECISION,
    "service_score" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "logistics_tms"."carriers" (
    "carrier_id" VARCHAR(64),
    "carrier_name" VARCHAR(104),
    "carrier_type" VARCHAR(64),
    "region" VARCHAR(64),
    "service_level" VARCHAR(64),
    "status" VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS "logistics_tms"."delivery_attempts" (
    "attempt_id" VARCHAR(64),
    "shipment_id" VARCHAR(64),
    "attempt_number" BIGINT,
    "attempt_date" TIMESTAMP,
    "result" VARCHAR(64),
    "reason" VARCHAR(88),
    "delay_minutes" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "logistics_tms"."routes" (
    "route_id" VARCHAR(64),
    "origin_state" VARCHAR(64),
    "origin_city" VARCHAR(92),
    "destination_state" VARCHAR(64),
    "destination_city" VARCHAR(92),
    "distance_km" DOUBLE PRECISION,
    "estimated_transit_days" DOUBLE PRECISION,
    "route_type" VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS "logistics_tms"."shipments" (
    "shipment_id" VARCHAR(64),
    "order_id" VARCHAR(128),
    "seller_id" VARCHAR(128),
    "customer_id" VARCHAR(128),
    "carrier_id" VARCHAR(64),
    "route_id" VARCHAR(64),
    "shipment_date" TIMESTAMP,
    "estimated_delivery_date" TIMESTAMP,
    "actual_delivery_date" TIMESTAMP,
    "shipping_cost" DOUBLE PRECISION,
    "package_weight" DOUBLE PRECISION,
    "package_volume" DOUBLE PRECISION,
    "status" VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS "logistics_tms"."transport_events" (
    "event_id" VARCHAR(64),
    "shipment_id" VARCHAR(64),
    "event_timestamp" TIMESTAMP,
    "event_type" VARCHAR(64),
    "location" VARCHAR(76),
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "event_status" VARCHAR(64),
    "delay_minutes" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "logistics_tms"."transport_incidents" (
    "incident_id" VARCHAR(64),
    "shipment_id" VARCHAR(64),
    "incident_date" TIMESTAMP,
    "incident_type" VARCHAR(64),
    "severity" VARCHAR(64),
    "description" VARCHAR(320),
    "resolution_status" VARCHAR(64),
    "resolution_date" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "logistics_tms"."vehicles" (
    "vehicle_id" VARCHAR(64),
    "carrier_id" VARCHAR(64),
    "vehicle_type" VARCHAR(64),
    "capacity_kg" DOUBLE PRECISION,
    "capacity_volume" DOUBLE PRECISION,
    "registration_year" DOUBLE PRECISION,
    "status" VARCHAR(64)
);

CREATE SCHEMA IF NOT EXISTS finance;

CREATE TABLE IF NOT EXISTS "finance"."commissions" (
    "commission_id" VARCHAR(64),
    "order_id" VARCHAR(128),
    "seller_id" VARCHAR(128),
    "commission_date" TIMESTAMP,
    "commission_type" VARCHAR(64),
    "commission_rate" DOUBLE PRECISION,
    "commission_amount" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "finance"."financial_reconciliation" (
    "reconciliation_id" VARCHAR(64),
    "transaction_id" VARCHAR(64),
    "reconciliation_date" TIMESTAMP,
    "expected_amount" DOUBLE PRECISION,
    "received_amount" DOUBLE PRECISION,
    "difference_amount" DOUBLE PRECISION,
    "reconciliation_status" VARCHAR(64),
    "discrepancy_reason" VARCHAR(68)
);

CREATE TABLE IF NOT EXISTS "finance"."payment_transactions" (
    "transaction_id" VARCHAR(64),
    "order_id" VARCHAR(128),
    "seller_id" VARCHAR(128),
    "transaction_date" TIMESTAMP,
    "payment_method" VARCHAR(64),
    "authorization_status" VARCHAR(64),
    "authorized_amount" DOUBLE PRECISION,
    "captured_amount" DOUBLE PRECISION,
    "refunded_amount" DOUBLE PRECISION,
    "transaction_status" VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS "finance"."refunds" (
    "refund_id" VARCHAR(64),
    "order_id" VARCHAR(128),
    "seller_id" VARCHAR(128),
    "refund_date" TIMESTAMP,
    "refund_reason" VARCHAR(64),
    "refund_amount" DOUBLE PRECISION,
    "refund_status" VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS "finance"."seller_accounts" (
    "account_id" VARCHAR(64),
    "seller_id" VARCHAR(128),
    "account_open_date" TIMESTAMP,
    "account_status" VARCHAR(64),
    "settlement_frequency" VARCHAR(64),
    "commission_rate" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS "finance"."seller_settlements" (
    "settlement_id" VARCHAR(64),
    "seller_id" VARCHAR(128),
    "settlement_date" TIMESTAMP,
    "gross_sales" DOUBLE PRECISION,
    "commissions" DOUBLE PRECISION,
    "freight_charges" DOUBLE PRECISION,
    "refunds" DOUBLE PRECISION,
    "adjustments" DOUBLE PRECISION,
    "net_settlement" DOUBLE PRECISION,
    "settlement_status" VARCHAR(64)
);
