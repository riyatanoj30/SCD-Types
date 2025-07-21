# 📊 SCD Stored Procedures (Type 0 to 6)

This repository contains SQL stored procedures for handling **Slowly Changing Dimensions (SCD)** Types 0 through 6, commonly used in data warehousing to manage changes in dimension data over time.

---

## 📁 Contents

| File Name | Description |
|-----------|-------------|
| `scd_type_0.sql` | SCD Type 0 – Retain original value (no change allowed) |
| `scd_type_1.sql` | SCD Type 1 – Overwrite old value |
| `scd_type_2.sql` | SCD Type 2 – Create a new version (historical tracking) |
| `scd_type_3.sql` | SCD Type 3 – Track limited history in the same row |
| `scd_type_4.sql` | SCD Type 4 – Maintain a history table |
| `scd_type_6.sql` | SCD Type 6 – Hybrid of Types 1, 2, and 3 |
| `scd_type_0_to_6_procedures.sql` | Combined SQL file for all SCD types |

---

## 🧠 What is SCD?

**Slowly Changing Dimensions (SCD)** are techniques used in data warehouses to handle changing dimension data over time. Choosing the correct SCD type depends on the business requirement for historical tracking and reporting.

---

## 🧩 SCD Type Overview

| Type | Description | Use Case |
|------|-------------|----------|
| **Type 0** | Fixed attributes – no changes allowed | Immutable data like Date of Birth |
| **Type 1** | Overwrite old data | Correcting errors like spelling |
| **Type 2** | Track full history by adding new rows | Tracking address changes over time |
| **Type 3** | Track current and previous value in same row | Limited historical changes (e.g., previous job title) |
| **Type 4** | Use a separate history table | Offload historical data |
| **Type 6** | Combine 1 + 2 + 3 | Full hybrid – current, previous, and full history |

---

## 🛠 How to Use

1. **Adjust table names** to match your schema (e.g., `staging_table`, `dimension_table`).
2. **Modify fields** like `attribute_1`, `start_date`, `version`, etc., as per your data model.
3. **Execute stored procedures** in your SQL environment (MySQL, SQL Server, etc.).
4. Run these procedures as part of your **ETL/ELT process** after loading data into the staging table.

---

## 📝 Notes

- These procedures are written in generic SQL. You may need to adjust syntax for specific databases (e.g., MySQL, PostgreSQL, SQL Server).
- Versioning in Type 2/6 assumes use of `start_date`, `end_date`, `current_flag`, and `version`.
- All procedures are kept modular for easy testing and integration.

---

## 📌 Author

Created by **Riya Tanoj**  
