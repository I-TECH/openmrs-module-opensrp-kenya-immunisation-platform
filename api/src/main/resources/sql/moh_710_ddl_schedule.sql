-- noinspection SqlNoDataSourceInspectionForFile

DELIMITER $$
DROP PROCEDURE IF EXISTS create_moh_710_etl_table$$
CREATE PROCEDURE create_moh_710_etl_table()
BEGIN

DROP TABLE if exists openmrs_etl.etl_moh_710;

-- create table etl_moh_710
create table openmrs_etl.etl_moh_710 (
  id INT(11) UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
  county_id INT(11),
  sub_county_id INT(11),
  ward_id INT(11),
  health_facility_id int(11),
  year year(4),
  month tinyint(2),
  bcg_lt_1 int,
  bcg_gt_1 int,
  opv_0 int,
  opv_1_lt_1 int,
  opv_1_gt_1 int,
  opv_2_lt_1 int,
  opv_2_gt_1 int,
  opv_3_lt_1 int,
  opv_3_gt_1 int,
  ipv_lt_1 int,
  ipv_gt_1 int,
  penta_1_lt_1 int,
  penta_1_gt_1 int,
  penta_2_lt_1 int,
  penta_2_gt_1 int,
  penta_3_lt_1 int,
  penta_3_gt_1 int,
  pcv_1_lt_1 int,
  pcv_1_gt_1 int,
  pcv_2_lt_1 int,
  pcv_2_gt_1 int,
  pcv_3_lt_1 int,
  pcv_3_gt_1 int,
  rota_1_lt_1 int,
  rota_2_lt_1 int,
  vit_at_6 int,
  yf_lt_1 int,
  yf_gt_1 int,
  mr_1_lt_1 int,
  mr_1_gt_1 int,
  fic int,
  vit_1 int,
  vit_1_half int,
  mr_2_1_half_2 int,
  mr_2_gt_2 int,
  vit_2_to_5 int,
  unique(health_facility_id, year, month),
  INDEX(county_id),
  INDEX(sub_county_id),
  INDEX(ward_id),
  INDEX(health_facility_id)
);
SELECT "Successfully created etl_moh_710 table";

END$$
DELIMITER ;

-- Call procedure to create tables --
CALL create_moh_710_etl_table();


DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_moh_710$$
CREATE PROCEDURE sp_update_moh_710(IN concept_id INT(11), IN sequence_number TINYINT,
                                         IN col_name VARCHAR(25), IN unit VARCHAR(5), IN lower_bound VARCHAR(5),IN upper_bound VARCHAR(5))
  BEGIN

    IF sequence_number <> -1
    THEN
      SET @query = CONCAT('insert into openmrs_etl.etl_moh_710 (health_facility_id, year, month, ', col_name,') select * from (select d.health_facility_id,
        YEAR(vx.obs_datetime), MONTH(vx.obs_datetime), count(vx.obs_id) as cnt from obs vx join obs vx_seq
        on vx.encounter_id = vx_seq.encounter_id and vx_seq.concept_id=1418 and vx.concept_id = ?  and vx_seq.value_numeric = ?
        join openmrs_etl.etl_patient_demographics d on vx.person_id=d.patient_id
        WHERE CASE WHEN "',lower_bound,'" <> "" AND "',upper_bound,'" <> "" THEN TIMESTAMPDIFF(',unit,', d.dob, vx.obs_datetime) ',lower_bound,'
        and TIMESTAMPDIFF(',unit,', d.dob, vx.obs_datetime) ',upper_bound,' WHEN "',lower_bound,'" <> "" THEN
        TIMESTAMPDIFF(',unit,', d.dob, vx.obs_datetime) ',lower_bound,' WHEN "',upper_bound,'" <> "" THEN
        TIMESTAMPDIFF(',unit,', d.dob, vx.obs_datetime) ',upper_bound,' END group by d.health_facility_id,
        YEAR(vx.obs_datetime), MONTH(vx.obs_datetime))t ON DUPLICATE KEY UPDATE ', col_name,' = t.cnt');

      PREPARE stmt FROM @query;
      SET @concept_id = concept_id;
      SET @sequence_number = sequence_number;
      EXECUTE stmt
      USING @concept_id, @sequence_number;
      DEALLOCATE PREPARE stmt;
    ELSE
      SET @query = CONCAT('insert into openmrs_etl.etl_moh_710 (health_facility_id, year, month, ', col_name,') select * from (select d.health_facility_id,
        YEAR(vx.obs_datetime), MONTH(vx.obs_datetime), count(vx.obs_id) as cnt from obs vx join obs vx_seq
        on vx.encounter_id = vx_seq.encounter_id and vx_seq.concept_id=1418 and vx.concept_id = ?
        join openmrs_etl.etl_patient_demographics d on vx.person_id=d.patient_id
        WHERE CASE WHEN "',lower_bound,'" <> "" AND "',upper_bound,'" <> "" THEN TIMESTAMPDIFF(',unit,', d.dob, vx.obs_datetime) ',lower_bound,'
        and TIMESTAMPDIFF(',unit,', d.dob, vx.obs_datetime) ',upper_bound,' WHEN "',lower_bound,'" <> "" THEN
        TIMESTAMPDIFF(',unit,', d.dob, vx.obs_datetime) ',lower_bound,' WHEN "',upper_bound,'" <> "" THEN
        TIMESTAMPDIFF(',unit,', d.dob, vx.obs_datetime) ',upper_bound,' END group by d.health_facility_id,
        YEAR(vx.obs_datetime), MONTH(vx.obs_datetime))t ON DUPLICATE KEY UPDATE ', col_name,' = t.cnt');
      PREPARE stmt FROM @query;
      SET @concept_id = concept_id;
      EXECUTE stmt
      USING @concept_id;
      DEALLOCATE PREPARE stmt;
    END IF;

    UPDATE openmrs_etl.etl_moh_710 m join location l on m.health_facility_id=l.location_id set m.ward_id = l.parent_location;
    UPDATE openmrs_etl.etl_moh_710 m join location l on m.ward_id=l.location_id set m.sub_county_id = l.parent_location;
    UPDATE openmrs_etl.etl_moh_710 m join location l on m.sub_county_id=l.location_id set m.county_id = l.parent_location;

  END$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_etl_moh_710$$
CREATE PROCEDURE sp_update_etl_moh_710()
  BEGIN

    CALL sp_update_moh_710(886, -1, 'bcg_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(886, -1, 'bcg_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(783, 0, 'opv_0', 'WEEK', '', '<=2');
    CALL sp_update_moh_710(783, 1, 'opv_1_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(783, 1, 'opv_1_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(783, 2, 'opv_2_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(783, 2, 'opv_2_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(783, 3, 'opv_3_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(783, 3, 'opv_3_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(1422, -1, 'ipv_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(1422, -1, 'ipv_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(1685, 1, 'penta_1_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(1685, 1, 'penta_1_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(1685, 2, 'penta_2_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(1685, 2, 'penta_2_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(1685, 3, 'penta_3_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(1685, 3, 'penta_3_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(162342, 1, 'pcv_1_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(162342, 1, 'pcv_1_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(162342, 2, 'pcv_2_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(162342, 2, 'pcv_2_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(162342, 3, 'pcv_3_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(162342, 3, 'pcv_3_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(159698, 1, 'rota_1_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(159698, 2, 'rota_2_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(161534, -1, 'vit_at_6', 'MONTH', '>=6', '<12');
    CALL sp_update_moh_710(5864, -1, 'yf_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(5864, -1, 'yf_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(162586, 1, 'mr_1_lt_1', 'YEAR', '', '<1');
    CALL sp_update_moh_710(162586, 1, 'mr_1_gt_1', 'YEAR', '>=1', '');
    CALL sp_update_moh_710(161534, -1, 'vit_1', 'MONTH', '>=12', '<18');
    CALL sp_update_moh_710(161534, -1, 'vit_1_half', 'MONTH', '>=18', '<24');
    CALL sp_update_moh_710(162586, 2, 'mr_2_1_half_2', 'MONTH', '>=18', '<24');
    CALL sp_update_moh_710(162586, 2, 'mr_2_gt_2', 'MONTH', '>=24', '');
    CALL sp_update_moh_710(161534, -1, 'vit_2_to_5', 'YEAR', '>=2', '<5');

  END$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_moh_710_fic$$
CREATE PROCEDURE sp_update_moh_710_fic()
  BEGIN

    UPDATE openmrs_etl.etl_moh_710 m join (select d.health_facility_id, YEAR(i.mr_1_vx_date) as year, MONTH(i.mr_1_vx_date) as month, count(*) as cnt
    from openmrs_etl.etl_immunisations i join openmrs_etl.etl_patient_demographics d on i.patient_id=d.patient_id
    where  i.bcg_vx_date is not null and i.bcg_vx_date < i.mr_1_vx_date
    and i.opv_1_vx_date is not null and i.opv_1_vx_date < i.mr_1_vx_date
    and i.opv_2_vx_date is not null and i.opv_2_vx_date < i.mr_1_vx_date
    and i.opv_3_vx_date is not null and i.opv_3_vx_date < i.mr_1_vx_date
    and i.ipv_vx_date is not null and i.ipv_vx_date < i.mr_1_vx_date
    and i.penta_1_vx_date is not null and i.penta_1_vx_date < i.mr_1_vx_date
    and i.penta_2_vx_date is not null and i.penta_2_vx_date < i.mr_1_vx_date
    and i.penta_3_vx_date is not null and i.penta_3_vx_date < i.mr_1_vx_date
    and i.pcv_1_vx_date is not null and i.pcv_1_vx_date < i.mr_1_vx_date
    and i.pcv_2_vx_date is not null and i.pcv_2_vx_date < i.mr_1_vx_date
    and i.pcv_3_vx_date is not null and i.pcv_3_vx_date < i.mr_1_vx_date
    and i.rota_1_vx_date is not null and i.rota_1_vx_date < i.mr_1_vx_date
    and i.rota_2_vx_date is not null and i.rota_2_vx_date < i.mr_1_vx_date
    and i.vit_at_6_vx_date is not null and i.vit_at_6_vx_date < i.mr_1_vx_date
    and i.mr_1_vx_date is not null and TIMESTAMPDIFF(YEAR, d.dob, i.mr_1_vx_date) <= 1
    group by d.health_facility_id, YEAR(i.mr_1_vx_date), MONTH(i.mr_1_vx_date))t on m.health_facility_id=t.health_facility_id
    and m.year=t.year and m.month=t.month SET m.fic = t.cnt;

  END$$
DELIMITER ;

-- ----------------------------  scheduled updates ---------------------

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_scheduled_moh_710_updates$$
CREATE PROCEDURE sp_scheduled_moh_710_updates()
  BEGIN
    DECLARE update_script_id INT(11);

    SET update_script_id = LAST_INSERT_ID();

    TRUNCATE openmrs_etl.etl_moh_710;

    CALL sp_update_etl_moh_710();

    CALL sp_update_moh_710_fic();

  END$$
DELIMITER ;

DELIMITER $$
SET GLOBAL EVENT_SCHEDULER = ON$$
DROP EVENT IF EXISTS event_update_openmrs_etl_moh_710_tables$$
CREATE EVENT event_update_openmrs_etl_moh_710_tables
  ON SCHEDULE EVERY 30 MINUTE STARTS CURRENT_TIMESTAMP
DO
  CALL sp_scheduled_moh_710_updates();
$$
DELIMITER ;