-- ============================================================
-- Supply Chain Warehouse — Scripts de création des tables
-- Source : Lakehouse supply_chain_lh (tables Gold)
-- ============================================================

-- Table de faits
CREATE TABLE fact_orders AS
SELECT * FROM supply_chain_lh.dbo.gold_fact_orders;

-- Dimension Produit
CREATE TABLE dim_product AS
SELECT * FROM supply_chain_lh.dbo.gold_dim_product;

-- Dimension Fournisseur
CREATE TABLE dim_supplier AS
SELECT * FROM supply_chain_lh.dbo.gold_dim_supplier;

-- Dimension Transport
CREATE TABLE dim_shipping AS
SELECT * FROM supply_chain_lh.dbo.gold_dim_shipping;

-- Dimension Inspection Qualité
CREATE TABLE dim_inspection AS
SELECT * FROM supply_chain_lh.dbo.gold_dim_inspection;

-- ============================================================
-- Vérification du chargement
-- ============================================================

SELECT 'fact_orders'    AS table_name, COUNT(*) AS nb_rows FROM fact_orders    UNION ALL
SELECT 'dim_product'    AS table_name, COUNT(*) AS nb_rows FROM dim_product     UNION ALL
SELECT 'dim_supplier'   AS table_name, COUNT(*) AS nb_rows FROM dim_supplier    UNION ALL
SELECT 'dim_shipping'   AS table_name, COUNT(*) AS nb_rows FROM dim_shipping    UNION ALL
SELECT 'dim_inspection' AS table_name, COUNT(*) AS nb_rows FROM dim_inspection;

-- ============================================================
-- Vérification intégrité référentielle
-- ============================================================

-- SKUs orphelins
SELECT f.sku
FROM fact_orders f
LEFT JOIN dim_product p ON f.sku = p.sku
WHERE p.sku IS NULL;

-- Fournisseurs orphelins
SELECT f.supplier_name
FROM fact_orders f
LEFT JOIN dim_supplier s ON f.supplier_name = s.supplier_name
WHERE s.supplier_name IS NULL;

-- Transporteurs orphelins
SELECT f.shipping_carriers
FROM fact_orders f
LEFT JOIN dim_shipping d ON f.shipping_carriers = d.shipping_carriers
WHERE d.shipping_carriers IS NULL;

-- ============================================================
-- KPIs de validation
-- ============================================================

SELECT
    product_type,
    COUNT(sku)                          AS nb_skus,
    ROUND(SUM(revenue_generated), 2)    AS total_revenue,
    ROUND(AVG(profit_margin_pct), 2)    AS avg_margin_pct,
    ROUND(AVG(end_to_end_lead_time), 1) AS avg_e2e_lead_time,
    ROUND(AVG(defect_rates), 4)         AS avg_defect_rate
FROM fact_orders
GROUP BY product_type
ORDER BY total_revenue DESC;
