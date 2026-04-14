# Supply-Chain-End-To-End-Analysis-with-Microsoft-Fabric
Fashion &amp; Beauty Supply Chain Analysis Using Microsoft Fabric &amp; Power BI


> Projet Data Analytics Engineering complet sur Microsoft Fabric : ingestion, transformation, modélisation et dashboard décisionnel sur un dataset supply chain Fashion & Beauty.

---

## Aperçu du projet

Ce projet implémente un pipeline de données end-to-end sur **Microsoft Fabric**, couvrant l'ensemble de la stack analytique moderne :

- Ingestion d'un fichier CSV dans un **Lakehouse** (OneLake)
- Transformation des données selon la **Medallion Architecture** (Bronze → Silver → Gold)
- Modélisation dimensionnelle en **étoile** dans un **Warehouse** Fabric
- Création d'un **modèle sémantique** avec mesures DAX centralisées
- Dashboard décisionnel **Power BI** en 3 pages thématiques

---

## Dataset

**Source** : [Supply Chain Analysis — Kaggle](https://www.kaggle.com/datasets/harshsingh2209/supply-chain-analysis)

**Domaine** : Fashion & Beauty (Skincare, Haircare, Cosmetics)

**Volume** : 100 SKUs · 1 fichier CSV · 24 colonnes

**Colonnes clés** :

| Colonne | Description |
|---|---|
| `SKU` | Identifiant unique produit |
| `Product Type` | Catégorie (Skincare / Haircare / Cosmetics) |
| `Revenue Generated` | Revenu total par SKU |
| `Lead Time` | Délai inbound fournisseur → entreprise |
| `Lead Times` | Délai outbound entreprise → client |
| `Manufacturing Lead Time` | Délai de fabrication interne |
| `Defect Rates` | Taux de défauts (échelle 0–5%) |
| `Inspection Results` | Résultat inspection (Pass / Fail / Pending) |
| `Shipping Carriers` | Transporteur utilisé |
| `Transportation Modes` | Mode de transport (Road / Air / Rail / Sea) |

---

## Architecture

### Stack technique

| Composant | Outil Fabric |
|---|---|
| Stockage | OneLake |
| Ingestion & transformation | Lakehouse + Notebooks PySpark |
| Couche de service | Warehouse SQL |
| Modélisation sémantique | Semantic Model (Direct Lake sur SQL) |
| Visualisation | Power BI Report |

### Medallion Architecture

```
CSV (Kaggle)
    ↓
Lakehouse — Bronze   (données brutes — Delta Table)
    ↓  Notebook 02_silver_transformation
Lakehouse — Silver   (données nettoyées + KPIs dérivés)
    ↓  Notebook 03_gold_modeling
Lakehouse — Gold     (modèle en étoile — 5 Delta Tables)
    ↓  SQL
Warehouse            (tables optimisées pour le reporting)
    ↓
Modèle Sémantique    (relations + 22 mesures DAX centralisées)
    ↓
Power BI Report      (3 pages — Exécutif / Qualité / Logistique)
```

### Modèle en étoile

```
                  gold_dim_product
                  (sku, product_type, price, availability)
                          ↑
gold_dim_supplier ← gold_fact_orders → gold_dim_shipping
(supplier_name,        (100 lignes)      (shipping_carriers)
 location,                  ↓
 production_volumes)  gold_dim_inspection
                      (sku, inspection_results,
                       defect_rates, quality_flag)
```
![Modèle Sémantique]('architecture/Modèle sémantique.png')

---

## Notebooks

### `01_bronze_exploration`
- Upload du CSV dans `Files/bronze/`
- Exploration PySpark (schema, nulls, distributions)
- Sauvegarde en Delta Table `bronze_supply_chain_raw`

### `02_silver_transformation`
- Renommage des colonnes en snake_case
- Typage des colonnes (Float, Integer)
- Suppression des doublons et gestion des nulls
- **Résolution de l'ambiguïté `lead_time` vs `lead_times`** :
  - `lead_time` → `inbound_lead_time` (fournisseur → entreprise)
  - `lead_times` → `outbound_lead_time` (entreprise → client)
- Colonnes dérivées : `profit_margin_pct`, `end_to_end_lead_time`, `bottleneck_segment`, `e2e_delay_flag`, `quality_flag`, `stock_coverage`
- Sauvegarde en Delta Table `silver_supply_chain`

### `03_gold_modeling`
- Construction du modèle en étoile (5 tables Gold)
- Contrôle qualité : nulls, KPIs de synthèse, intégrité référentielle
- Sauvegarde en Delta Tables `gold_*`

---

## Décisions de modélisation

| Décision | Justification |
|---|---|
| `customer_demographics` dans `fact_orders` | Variable catégorielle (Male/Female/Non-binary) sans identifiant client unique — attribut de segmentation, pas une entité |
| `dim_product_type` fusionnée dans `dim_product` | `product_type` est un attribut du SKU (relation many-to-one), pas une entité indépendante |
| `transportation_modes` et `routes` dans `fact_orders` | Attributs de la commande, pas du transporteur — un même carrier utilise plusieurs modes |
| Seuils `quality_flag` recalibrés | `defect_rates` exprimé sur 0–5%, seuils ajustés à > 3.5 (high), > 1.5 (medium), ≤ 1.5 (ok) |
| Grain `fact_orders` = 1 SKU | Dataset agrégé (100 SKUs distincts) — pas de dimension temporelle |

---

## KPIs produits

### Financiers
- `Total Revenue` · `Total Profit` · `Avg Profit Margin %`
- `Total Manufacturing Cost` · `Total Shipping Cost`

### Qualité
- `Avg Defect Rate` · `% SKUs High Defect` · `% SKUs Medium Defect`
- `% Inspection Passed` · `% Inspection Failed` · `% Inspection Pending`

### Logistique
- `Avg E2E Lead Time` · `Avg Inbound Lead Time`
- `Avg Manufacturing Lead Time` · `Avg Outbound Lead Time`
- `% SKUs Critical` · `% SKUs At Risk` · `% SKUs On Time`

### Stock
- `Avg Stock Coverage` · `Total Stock Levels` · `Total Order Quantities`

---

## Dashboard Power BI

Le rapport est structuré en 3 pages :

### Page 1 — Vue Exécutive
Vue d'ensemble financière : revenue par type de produit, marge par fournisseur, distribution par démographie client.

### Page 2 — Qualité & Défauts
Analyse des taux de défauts par produit et mode de transport, distribution des résultats d'inspection, matrice qualité par fournisseur.

### Page 3 — Performance Logistique
Décomposition du end-to-end lead time par segment (inbound / manufacturing / outbound), distribution des goulots d'étranglement, statut des délais par transporteur.

---

## Compétences démontrées

`Microsoft Fabric` · `OneLake` · `Lakehouse` · `PySpark` · `SQL Analytics Endpoint`
`Medallion Architecture` · `Delta Tables` · `Warehouse Fabric` · `Modèle Sémantique`
`Direct Lake` · `Power BI` · `DAX` · `Modélisation dimensionnelle` · `Data Quality`
`Supply Chain KPIs` · `Bottleneck Analysis`

---
## Structure du repository
supply-chain-fabric/
├── README.md
├── notebooks/
│   ├── 01_bronze_exploration.ipynb
│   ├── 02_silver_transformation.ipynb
│   └── 03_gold_modeling.ipynb
├── warehouse/
│   └── create_tables.sql
├── dax/
│   └── measures.md
├── dashboard/
│   └── screenshots/
│       ├── page1_vue_executive.png
│       ├── page2_qualite_defauts.png
│       └── page3_performance_logistique.png
├── architecture/
│   ├── medallion_architecture.png
│   └── data_model.png
└── docs/
    └── data_quality_decisions.md
---

## Joan Cindy

Projet réalisé dans le cadre d'un apprentissage personnel de Microsoft Fabric.
