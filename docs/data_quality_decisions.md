# Décisions Data Quality & Modélisation

Ce document trace toutes les décisions prises lors de la transformation
et de la modélisation des données, avec leur justification métier.

---

## 1. Ambiguïté lead_time vs lead_times

**Constat** : deux colonnes entières sans nulls, valeurs différentes,
corrélations quasi-nulles avec shipping_costs et manufacturing_costs.

**Investigation** :
- Test de corrélation avec `shipping_costs` et `manufacturing_costs`
- Consultation de la documentation Kaggle et de la communauté

**Décision** :
- `lead_time` (Lead Time) → `inbound_lead_time`
  _"Time required to receive raw materials from vendors/suppliers"_
- `lead_times` (Lead Times) → `outbound_lead_time`
  _"Time required to ship products to customers"_
- `manufacturing_lead_time` conservé tel quel
  _"Time required to produce a product"_

**KPI dérivé** : `end_to_end_lead_time = inbound + manufacturing + outbound`

---

## 2. Seuils quality_flag recalibrés

**Constat** : `defect_rates` est exprimé sur une échelle 0–5%
(et non 0–1 comme supposé initialement).

**Seuils initiaux (incorrects)** :
- `> 0.05` → high_defect
- `> 0.02` → medium_defect

**Résultat** : quasi 100% des SKUs classés `high_defect`.

**Seuils corrigés** (basés sur la distribution réelle) :
- `> 3.5` → high_defect   (~25% des SKUs)
- `> 1.5` → medium_defect (~50% des SKUs)
- `<= 1.5` → ok           (~25% des SKUs)

---

## 3. customer_demographics dans fact_orders

**Constat** : valeurs observées = Male / Female / Non-binary.
Pas d'identifiant client unique, pas d'attributs supplémentaires.

**Décision** : attribut de segmentation intégré directement dans
`fact_orders` — pas de `dim_customer` créée.

**Justification** : une dimension nécessite une clé primaire unique
et des attributs descriptifs. Ici, `customer_demographics` est
une variable catégorielle agrégée, pas une entité métier.

---

## 4. dim_product_type supprimée

**Constat** : `product_type` est un attribut du SKU
(relation many-to-one stricte).

**Décision** : `customer_demographics` non intégrée dans `dim_product`
(attribut client ≠ attribut produit). `dim_product_type` supprimée
car `product_type` est un simple attribut du SKU.

**Justification** : évite une jointure inutile dans Power BI
et respecte le principe de cohérence des entités dimensionnelles.

---

## 5. transportation_modes et routes dans fact_orders

**Constat** : un même carrier utilise plusieurs modes de transport
et plusieurs routes selon la commande.

**Décision** : `transportation_modes` et `routes` conservés dans
`fact_orders` comme attributs de la commande.
`dim_shipping` contient uniquement `shipping_carriers` comme clé.

**Justification** : si ces colonnes étaient dans `dim_shipping`,
la clé composite (carrier + mode + route) créerait des doublons
sur `shipping_carriers`, violant la contrainte Many-to-one.

---

## 6. Grain de fact_orders = 1 SKU

**Constat** : 100 lignes, 100 SKUs uniques — dataset agrégé.

**Implication** : pas de dimension temporelle, pas d'analyse
de tendance dans le temps. Toutes les analyses sont
comparatives (cross-produit / cross-fournisseur).

**Décision** : modèle en étoile adapté au grain SKU,
documenté explicitement dans le code et le README.
