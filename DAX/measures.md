# Mesures DAX — Supply Chain Analytics

Toutes les mesures sont centralisées dans la table `_Mesures` du modèle sémantique.

---

## Mesures financières

```dax
Total Revenue =
SUM(fact_orders[revenue_generated])

Total Manufacturing Cost =
SUM(fact_orders[manufacturing_costs])

Total Shipping Cost =
SUM(fact_orders[shipping_costs])

Total Profit =
[Total Revenue] - [Total Manufacturing Cost] - [Total Shipping Cost]

Avg Profit Margin % =
AVERAGE(fact_orders[profit_margin_pct])

Total Products Sold =
SUM(fact_orders[number_of_products_sold])
```

---

## Mesures qualité

```dax
Avg Defect Rate =
AVERAGE(fact_orders[defect_rates])

% SKUs High Defect =
DIVIDE(
    COUNTROWS(FILTER(fact_orders, fact_orders[quality_flag] = "high_defect")),
    COUNTROWS(fact_orders),
    0
)

% SKUs Medium Defect =
DIVIDE(
    COUNTROWS(FILTER(fact_orders, fact_orders[quality_flag] = "medium_defect")),
    COUNTROWS(fact_orders),
    0
)

% Inspection Passed =
DIVIDE(
    COUNTROWS(FILTER(fact_orders, fact_orders[inspection_results] = "Pass")),
    COUNTROWS(fact_orders),
    0
)

% Inspection Failed =
DIVIDE(
    COUNTROWS(FILTER(fact_orders, fact_orders[inspection_results] = "Fail")),
    COUNTROWS(fact_orders),
    0
)

% Inspection Pending =
DIVIDE(
    COUNTROWS(FILTER(fact_orders, fact_orders[inspection_results] = "Pending")),
    COUNTROWS(fact_orders),
    0
)
```

---

## Mesures logistiques

```dax
Avg E2E Lead Time =
AVERAGE(fact_orders[end_to_end_lead_time])

Avg Inbound Lead Time =
AVERAGE(fact_orders[inbound_lead_time])

Avg Manufacturing Lead Time =
AVERAGE(fact_orders[manufacturing_lead_time])

Avg Outbound Lead Time =
AVERAGE(fact_orders[outbound_lead_time])

% SKUs Critical =
DIVIDE(
    COUNTROWS(FILTER(fact_orders, fact_orders[e2e_delay_flag] = "critical")),
    COUNTROWS(fact_orders),
    0
)

% SKUs At Risk =
DIVIDE(
    COUNTROWS(FILTER(fact_orders, fact_orders[e2e_delay_flag] = "at_risk")),
    COUNTROWS(fact_orders),
    0
)

% SKUs On Time =
DIVIDE(
    COUNTROWS(FILTER(fact_orders, fact_orders[e2e_delay_flag] = "on_time")),
    COUNTROWS(fact_orders),
    0
)
```

---

## Mesures stock

```dax
Avg Stock Coverage =
AVERAGE(fact_orders[stock_coverage])

Total Stock Levels =
SUM(fact_orders[stock_levels])

Total Order Quantities =
SUM(fact_orders[order_quantities])
```

---

## Mesures de comptage

```dax
Nb SKUs Total =
COUNTROWS(fact_orders)

Nb SKUs par Fournisseur =
COUNTROWS(
    SUMMARIZE(fact_orders, fact_orders[supplier_name])
)
```
