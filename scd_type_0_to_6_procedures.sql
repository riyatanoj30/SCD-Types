-- Assumptions
-- Common Fields
-- Primary Key: business_key (e.g., customer_id)
-- Attributes: attribute_1, attribute_2, ...
-- Metadata: start_date, end_date, current_flag, version

-- SCD 3 will have additional column: previous_attribute_1
-- SCD 4 will have a history table: dimension_table_history


CREATE PROCEDURE scd_type_0()
BEGIN
  -- Ignore changes for fixed columns
  DELETE FROM staging_table
  WHERE EXISTS (
    SELECT 1 FROM dimension_table d
    WHERE d.business_key = staging_table.business_key
      AND d.attribute_1 != staging_table.attribute_1 -- Immutable column
  );
  
  -- You may insert new rows only
  INSERT INTO dimension_table (business_key, attribute_1, ...)
  SELECT business_key, attribute_1, ...
  FROM staging_table
  WHERE NOT EXISTS (
    SELECT 1 FROM dimension_table d WHERE d.business_key = staging_table.business_key
  );
END;


CREATE PROCEDURE scd_type_1()
BEGIN
  -- Update existing records
  UPDATE dimension_table d
  JOIN staging_table s ON d.business_key = s.business_key
  SET d.attribute_1 = s.attribute_1,
      d.attribute_2 = s.attribute_2;

  -- Insert new records
  INSERT INTO dimension_table (business_key, attribute_1, attribute_2)
  SELECT s.business_key, s.attribute_1, s.attribute_2
  FROM staging_table s
  WHERE NOT EXISTS (
    SELECT 1 FROM dimension_table d WHERE d.business_key = s.business_key
  );
END;


CREATE PROCEDURE scd_type_2()
BEGIN
  -- Expire old record
  UPDATE dimension_table d
  JOIN staging_table s ON d.business_key = s.business_key AND d.current_flag = 1
  SET d.end_date = CURRENT_DATE(),
      d.current_flag = 0
  WHERE d.attribute_1 != s.attribute_1 OR d.attribute_2 != s.attribute_2;

  -- Insert new record with new version
  INSERT INTO dimension_table (business_key, attribute_1, attribute_2, start_date, end_date, current_flag, version)
  SELECT s.business_key, s.attribute_1, s.attribute_2, CURRENT_DATE(), '9999-12-31', 1,
         COALESCE((SELECT MAX(version) + 1 FROM dimension_table d WHERE d.business_key = s.business_key), 1)
  FROM staging_table s
  WHERE EXISTS (
    SELECT 1 FROM dimension_table d
    WHERE d.business_key = s.business_key AND d.current_flag = 1
      AND (d.attribute_1 != s.attribute_1 OR d.attribute_2 != s.attribute_2)
  );

  -- Insert brand-new records
  INSERT INTO dimension_table (business_key, attribute_1, attribute_2, start_date, end_date, current_flag, version)
  SELECT s.business_key, s.attribute_1, s.attribute_2, CURRENT_DATE(), '9999-12-31', 1, 1
  FROM staging_table s
  WHERE NOT EXISTS (
    SELECT 1 FROM dimension_table d WHERE d.business_key = s.business_key
  );
END;


CREATE PROCEDURE scd_type_3()
BEGIN
  -- Update current and move existing to previous
  UPDATE dimension_table d
  JOIN staging_table s ON d.business_key = s.business_key
  SET d.previous_attribute_1 = d.attribute_1,
      d.attribute_1 = s.attribute_1
  WHERE d.attribute_1 != s.attribute_1;

  -- Insert new records
  INSERT INTO dimension_table (business_key, attribute_1, previous_attribute_1)
  SELECT s.business_key, s.attribute_1, NULL
  FROM staging_table s
  WHERE NOT EXISTS (
    SELECT 1 FROM dimension_table d WHERE d.business_key = s.business_key
  );
END;


CREATE PROCEDURE scd_type_4()
BEGIN
  -- Move old record to history table
  INSERT INTO dimension_table_history
  SELECT * FROM dimension_table d
  JOIN staging_table s ON d.business_key = s.business_key
  WHERE d.attribute_1 != s.attribute_1;

  -- Update main dimension
  UPDATE dimension_table d
  JOIN staging_table s ON d.business_key = s.business_key
  SET d.attribute_1 = s.attribute_1;

  -- Insert new records
  INSERT INTO dimension_table (business_key, attribute_1)
  SELECT s.business_key, s.attribute_1
  FROM staging_table s
  WHERE NOT EXISTS (
    SELECT 1 FROM dimension_table d WHERE d.business_key = s.business_key
  );
END;


CREATE PROCEDURE scd_type_6()
BEGIN
  -- Expire old record
  UPDATE dimension_table d
  JOIN staging_table s ON d.business_key = s.business_key AND d.current_flag = 1
  SET d.end_date = CURRENT_DATE(),
      d.current_flag = 0
  WHERE d.attribute_1 != s.attribute_1;

  -- Insert new record with Type 2 and 3 features
  INSERT INTO dimension_table (business_key, attribute_1, previous_attribute_1, start_date, end_date, current_flag, version)
  SELECT s.business_key, s.attribute_1, d.attribute_1, CURRENT_DATE(), '9999-12-31', 1, d.version + 1
  FROM staging_table s
  JOIN dimension_table d ON d.business_key = s.business_key AND d.current_flag = 1
  WHERE d.attribute_1 != s.attribute_1;

  -- Insert brand-new rows
  INSERT INTO dimension_table (business_key, attribute_1, previous_attribute_1, start_date, end_date, current_flag, version)
  SELECT s.business_key, s.attribute_1, NULL, CURRENT_DATE(), '9999-12-31', 1, 1
  FROM staging_table s
  WHERE NOT EXISTS (
    SELECT 1 FROM dimension_table d WHERE d.business_key = s.business_key
  );
END;


