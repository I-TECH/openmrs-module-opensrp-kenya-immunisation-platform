# noinspection SqlNoDataSourceInspectionForFile

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_etl_patient_demographics$$
CREATE PROCEDURE sp_update_etl_patient_demographics()
  BEGIN

    DECLARE last_update_time DATETIME;
    SELECT max(proc_time)
    INTO last_update_time
    FROM openmrs_etl.etl_script_status;
    -- update etl_patient_demographics table
    INSERT INTO openmrs_etl.etl_patient_demographics (
      patient_id,
      given_name,
      middle_name,
      family_name,
      gender,
      dob,
      date_created
    )
      SELECT
        p.person_id,
        p.given_name,
        p.middle_name,
        p.family_name,
        p.gender,
        p.birthdate,
        p.date_created
      FROM (
             SELECT
               p.person_id,
               pn.given_name,
               pn.middle_name,
               pn.family_name,
               p.gender,
               p.birthdate,
               pa.date_created
             FROM person p
               JOIN patient pa ON pa.patient_id = p.person_id
               INNER JOIN person_name pn ON pn.person_id = p.person_id AND pn.voided = 0
             WHERE pn.date_created > last_update_time
                   OR pn.date_changed > last_update_time
                   OR pn.date_voided > last_update_time
                   OR p.date_created > last_update_time
                   OR p.date_changed > last_update_time
                   OR p.date_voided > last_update_time
             GROUP BY p.person_id
           ) p
    ON DUPLICATE KEY UPDATE given_name = p.given_name, middle_name = p.middle_name, family_name = p.family_name;

    -- Set up mother details --
    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT *
            FROM
              (SELECT
                 p.person_id,
                 p.gender,
                 p.birthdate,
                 pn.given_name,
                 pn.family_name,
                 r.person_b,
                 concat(rt.a_is_to_b, " / ", rt.b_is_to_a) AS relationship_type
               FROM person p
                 JOIN person_name pn ON p.person_id = pn.person_id
                 LEFT JOIN relationship r ON p.person_id = r.person_a
                 JOIN relationship_type rt
                   ON r.relationship = rt.relationship_type_id
               WHERE r.person_b IN (SELECT patient_id
                                    FROM patient) AND (p.date_created > last_update_time
                                                       OR p.date_changed > last_update_time OR
                                                       pn.date_created > last_update_time OR
                                                       pn.date_changed > last_update_time OR
                                                       pn.date_voided > last_update_time)
               ORDER BY p.person_id ASC) prx
            GROUP BY prx.person_b) m ON m.person_b = d.patient_id
    SET d.mother_first_name = m.given_name,
      d.mother_last_name    = m.family_name,
      d.mother_gender       = m.gender,
      d.mother_dob          = m.birthdate,
      d.mother_relationship = m.relationship_type;

    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT *
            FROM
              (SELECT
                 o.person_id,
                 o.value_text AS mother_national_id
               FROM obs o
               WHERE o.concept_id = 163084
               ORDER BY o.person_id ASC)
              a
            GROUP BY a.person_id) p ON p.person_id = d.patient_id
    SET d.mother_national_id = p.mother_national_id;

    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT *
            FROM
              (SELECT
                 o.person_id,
                 o.value_text AS mother_phone_numer
               FROM obs o
               WHERE o.concept_id = 159635
               ORDER BY o.person_id ASC)
              a
            GROUP BY a.person_id) p ON p.person_id = d.patient_id
    SET d.mother_phone_numer = p.mother_phone_numer;

    -- Set up guardian details --
    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT *
            FROM
              (SELECT
                 p.person_id,
                 p.gender,
                 p.birthdate,
                 pn.given_name,
                 pn.family_name,
                 r.person_b,
                 concat(rt.a_is_to_b, " / ", rt.b_is_to_a) AS relationship_type
               FROM person p
                 JOIN person_name pn ON p.person_id = pn.person_id
                 LEFT JOIN relationship r ON p.person_id = r.person_a
                 JOIN relationship_type rt
                   ON r.relationship = rt.relationship_type_id
               WHERE r.person_b IN (SELECT patient_id
                                    FROM patient) AND (p.date_created > last_update_time
                                                       OR p.date_changed > last_update_time OR
                                                       pn.date_created > last_update_time OR
                                                       pn.date_changed > last_update_time OR
                                                       pn.date_voided > last_update_time)
               ORDER BY p.person_id DESC) prx
            GROUP BY prx.person_b
            HAVING count(prx.person_b) > 1) g ON g.person_b = d.patient_id
    SET d.guardian_first_name = g.given_name,
      d.guardian_last_name    = g.family_name,
      d.guardian_gender       = g.gender,
      d.guardian_dob          = g.birthdate,
      d.guardian_relationship = g.relationship_type;

    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT *
            FROM
              (SELECT
                 o.person_id,
                 o.value_text AS guardian_national_id
               FROM obs o
               WHERE o.concept_id = 163084
               ORDER BY o.person_id DESC)
              a
            GROUP BY a.person_id
            HAVING count(a.person_id) > 1) p ON p.person_id = d.patient_id
    SET d.guardian_national_id = p.guardian_national_id;

    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT
              pi.patient_id,
              max(if(pit.uuid = 'ccd8e564-030c-11e7-b443-54271eac1477', pi.identifier, NULL)) AS national_id_no,
              max(if(pit.uuid = '8d793bee-c2cc-11de-8d13-0010c6dffd0f', pi.identifier, NULL))    kip_id,
              max(if(pit.uuid = '1b12fc38-030d-11e7-b443-54271eac1477', pi.identifier,
                     NULL))                                                                      permanent_register_number,
              max(if(pit.uuid = 'dae8f6b8-030c-11e7-b443-54271eac1477', pi.identifier, NULL))    nupi,
              max(if(pit.uuid = '893bcc12-030c-11e7-b443-54271eac1477', pi.identifier, NULL))    cwc_number,
              max(if(pit.uuid = 'fc1c83d1-030c-11e7-b443-54271eac1477', pi.identifier, NULL))    hdss_number
            FROM patient_identifier pi
              JOIN patient_identifier_type pit ON pi.identifier_type = pit.patient_identifier_type_id
            WHERE voided = 0 AND (pi.date_created > last_update_time OR pi.date_changed > last_update_time OR
                                  pi.date_voided > last_update_time)
            GROUP BY pi.patient_id) pid ON pid.patient_id = d.patient_id
    SET d.national_id_no          = pid.national_id_no,
      d.kip_id                    = pid.kip_id,
      d.permanent_register_number = pid.permanent_register_number,
      d.nupi                      = pid.nupi,
      d.cwc_number                = pid.cwc_number,
      d.hdss_number               = pid.hdss_number;

    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT
              pa.person_id,
              pa.state_province  AS county,
              pa.county_district AS sub_county,
              pa.city_village    AS ward,
              pa.address4        AS sub_location,
              pa.address3        AS village,
              pa.address2        AS landmark,
              pa.address1        AS address,
              pa.address5        AS health_facility
            FROM person_address pa
            WHERE voided = 0 AND (pa.date_created > last_update_time OR pa.date_changed > last_update_time OR
                                  pa.date_voided > last_update_time)
            GROUP BY pa.person_id) pa ON pa.person_id = d.patient_id
    SET d.county        = pa.county,
      d.sub_county      = pa.sub_county,
      d.ward            = pa.ward,
      d.sub_location    = pa.sub_location,
      d.village         = pa.village,
      d.landmark        = pa.landmark,
      d.address         = pa.address,
      d.health_facility = pa.health_facility;

    -- Update patient_demographics set county id --
    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT
              l.location_id,
              l.name
            FROM location l) county ON d.county = county.name
    SET d.county_id = county.location_id
    WHERE d.county_id IS NULL;

    -- Update patient_demographics set sub county id --
    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT
              l.location_id,
              l.name
            FROM location l) sub_county ON d.sub_county = sub_county.name
    SET d.sub_county_id = sub_county.location_id
    WHERE d.sub_county_id IS NULL;

    -- Update patient_demographics set ward id --
    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT
              l.location_id,
              l.name
            FROM location l) ward ON d.ward = ward.name
    SET d.ward_id = ward.location_id
    WHERE d.ward_id IS NULL;

    -- Update patient_demographics set health facility id --
    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT
              l.location_id,
              l.name
            FROM location l) health_facility ON d.health_facility = health_facility.name
    SET d.health_facility_id = health_facility.location_id
    WHERE d.health_facility_id IS NULL;

    -- Update HEI status --
    UPDATE openmrs_etl.etl_patient_demographics d
      JOIN (SELECT
              o.person_id,
              cn.name
            FROM obs o
              JOIN concept_name cn ON o.value_coded = cn.concept_id AND cn.locale = 'en'
                                      AND cn.concept_name_type = 'FULLY_SPECIFIED'
            WHERE o.concept_id = 1396) h ON d.patient_id = h.person_id
    SET d.hei = h.name;

  END$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_immunisations$$
CREATE PROCEDURE sp_update_immunisations(IN concept_id       INT(11), IN sequence_number TINYINT,
                                         IN col_name         VARCHAR(25), IN last_update_time DATETIME)
  BEGIN

    IF sequence_number <> -1
    THEN
      SET @query = CONCAT('update openmrs_etl.etl_immunisations i join ( select vx.person_id, vx.obs_datetime
				from obs vx join obs vx_seq on vx.encounter_id = vx_seq.encounter_id and vx_seq.concept_id=1418
        and vx.concept_id = ? and vx_seq.value_numeric = ?
        where vx.date_created > "', last_update_time, '" or vx.obs_datetime > "', last_update_time, '"
        or vx_seq.date_created > "', last_update_time, '" or vx_seq.obs_datetime > "', last_update_time, '" group by vx.person_id) o
        on o.person_id = i.patient_id set i.', col_name, ' = o.obs_datetime');
      PREPARE stmt FROM @query;
      SET @concept_id = concept_id;
      SET @sequence_number = sequence_number;
      EXECUTE stmt
      USING @concept_id, @sequence_number;
      DEALLOCATE PREPARE stmt;
    ELSE
      SET @query = CONCAT('update openmrs_etl.etl_immunisations i join ( select vx.person_id, vx.obs_datetime
				from obs vx join obs vx_seq on vx.encounter_id = vx_seq.encounter_id and vx_seq.concept_id=1418
        and vx.concept_id = ? where vx.date_created > "', last_update_time, '" or vx.obs_datetime > "',
                          last_update_time, '"
        or vx_seq.date_created > "', last_update_time, '" or vx_seq.obs_datetime > "', last_update_time, '" group by vx.person_id) o
        on o.person_id = i.patient_id set i.', col_name, ' = o.obs_datetime');
      PREPARE stmt FROM @query;
      SET @concept_id = concept_id;
      EXECUTE stmt
      USING @concept_id;
      DEALLOCATE PREPARE stmt;
    END IF;

  END$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_etl_immunisations$$
CREATE PROCEDURE sp_update_etl_immunisations()
  BEGIN

    DECLARE last_update_time DATETIME;
    SELECT max(proc_time)
    INTO last_update_time
    FROM openmrs_etl.etl_script_status;

    INSERT IGNORE INTO openmrs_etl.etl_immunisations (patient_id) SELECT DISTINCT o.person_id
                                                                  FROM obs o
                                                                  WHERE o.date_created > last_update_time OR
                                                                        o.obs_datetime > last_update_time;

    CALL sp_update_immunisations(886, -1, 'bcg_vx_date', last_update_time);
    CALL sp_update_immunisations(783, 0, 'opv_0_vx_date', last_update_time);
    CALL sp_update_immunisations(783, 1, 'opv_1_vx_date', last_update_time);
    CALL sp_update_immunisations(162342, 1, 'pcv_1_vx_date', last_update_time);
    CALL sp_update_immunisations(1685, 1, 'penta_1_vx_date', last_update_time);
    CALL sp_update_immunisations(159698, 1, 'rota_1_vx_date', last_update_time);
    CALL sp_update_immunisations(783, 2, 'opv_2_vx_date', last_update_time);
    CALL sp_update_immunisations(162342, 2, 'pcv_2_vx_date', last_update_time);
    CALL sp_update_immunisations(1685, 2, 'penta_2_vx_date', last_update_time);
    CALL sp_update_immunisations(159698, 2, 'rota_2_vx_date', last_update_time);
    CALL sp_update_immunisations(783, 3, 'opv_3_vx_date', last_update_time);
    CALL sp_update_immunisations(162342, 3, 'pcv_3_vx_date', last_update_time);
    CALL sp_update_immunisations(1685, 3, 'penta_3_vx_date', last_update_time);
    CALL sp_update_immunisations(1422, -1, 'ipv_vx_date', last_update_time);
    CALL sp_update_immunisations(162586, 1, 'mr_1_vx_date', last_update_time);
    CALL sp_update_immunisations(162586, 2, 'mr_2_vx_date', last_update_time);
    CALL sp_update_immunisations(162586, 6, 'mr_at_6_vx_date', last_update_time);
    CALL sp_update_immunisations(5864, -1, 'yf_vx_date', last_update_time);

  END$$
DELIMITER ;

-- ----------------------------  scheduled updates ---------------------

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_scheduled_updates$$
CREATE PROCEDURE sp_scheduled_updates()
  BEGIN
    DECLARE update_script_id INT(11);

    INSERT INTO openmrs_etl.etl_script_status (script_name, start_time) VALUES ('scheduled_updates', NOW());
    SET update_script_id = LAST_INSERT_ID();

    CALL sp_update_etl_patient_demographics();
    CALL sp_update_etl_immunisations();

    UPDATE openmrs_etl.etl_script_status
    SET proc_time = NOW(), stop_time = NOW()
    WHERE id = update_script_id;

  END$$
DELIMITER ;

DELIMITER $$
SET GLOBAL EVENT_SCHEDULER = ON$$
DROP EVENT IF EXISTS event_update_openmrs_etl_tables$$
CREATE EVENT event_update_openmrs_etl_tables
  ON SCHEDULE EVERY 30 MINUTE STARTS CURRENT_TIMESTAMP
DO
  CALL sp_scheduled_updates();
$$
DELIMITER ;







