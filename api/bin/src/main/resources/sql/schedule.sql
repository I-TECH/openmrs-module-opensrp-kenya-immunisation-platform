DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_etl_patient_demographics$$
CREATE PROCEDURE sp_update_etl_patient_demographics()
BEGIN

DECLARE last_update_time DATETIME;
SELECT max(proc_time) into last_update_time from openmrs_etl.etl_script_status;
-- update etl_patient_demographics table
insert into openmrs_etl.etl_patient_demographics(
patient_id,
given_name,
middle_name,
family_name,
gender,
dob,
date_created
)
select
p.person_id,
p.given_name,
p.middle_name,
p.family_name,
p.gender,
p.birthdate,
p.date_created
FROM (
select
p.person_id,
pn.given_name,
pn.middle_name,
pn.family_name,
p.gender,
p.birthdate,
pa.date_created
from person p
join patient pa on pa.patient_id=p.person_id
inner join person_name pn on pn.person_id = p.person_id and pn.voided=0
where pn.date_created > last_update_time
or pn.date_changed > last_update_time
or pn.date_voided > last_update_time
or p.date_created > last_update_time
or p.date_changed > last_update_time
or p.date_voided > last_update_time
GROUP BY p.person_id
)p ON DUPLICATE KEY UPDATE given_name = p.given_name, middle_name=p.middle_name, family_name=p.family_name;


-- Set up mother details --
update openmrs_etl.etl_patient_demographics d
join (select * from
		(select p.person_id, p.gender,p.birthdate, pn.given_name, pn.family_name, r.person_b,
			 concat(rt.a_is_to_b, " / ", rt.b_is_to_a) as relationship_type from person p join person_name pn on p.person_id = pn.person_id
			left join relationship r on p.person_id = r.person_a join relationship_type rt
				on r.relationship = rt.relationship_type_id where r.person_b in (select patient_id from patient) and (p.date_created > last_update_time
        or p.date_changed > last_update_time or pn.date_created > last_update_time or pn.date_changed > last_update_time or pn.date_voided > last_update_time)
		 order by p.person_id asc) prx group by prx.person_b) m on m.person_b = d.patient_id
	set d.mother_first_name = m.given_name,
		d.mother_last_name = m.family_name,
		d.mother_gender = m.gender,
		d.mother_dob = m.birthdate,
		d.mother_relationship = m.relationship_type
;

update openmrs_etl.etl_patient_demographics d
	join (select  * from
		(select o.person_id, o.value_text as mother_national_id from obs o where o.concept_id = 163084 order by o.person_id asc)
		a group by a.person_id) p on p.person_id = d.patient_id
	set d.mother_national_id = p.mother_national_id
;

update openmrs_etl.etl_patient_demographics d
	join (select  * from
		(select o.person_id, o.value_text as mother_phone_numer from obs o where o.concept_id = 159635 order by o.person_id asc)
		a group by a.person_id) p on p.person_id = d.patient_id
set d.mother_phone_numer = p.mother_phone_numer
;

-- Set up guardian details --
update openmrs_etl.etl_patient_demographics d
join (select * from
		(select p.person_id, p.gender,p.birthdate, pn.given_name, pn.family_name, r.person_b,
			 concat(rt.a_is_to_b, " / ", rt.b_is_to_a) as relationship_type from person p join person_name pn on p.person_id = pn.person_id
			left join relationship r on p.person_id = r.person_a join relationship_type rt
				on r.relationship = rt.relationship_type_id where r.person_b in (select patient_id from patient) and (p.date_created > last_update_time
				or p.date_changed > last_update_time or pn.date_created > last_update_time or pn.date_changed > last_update_time or pn.date_voided > last_update_time)
		 order by p.person_id desc) prx group by prx.person_b having count(prx.person_b) > 1) g on g.person_b = d.patient_id
	set d.guardian_first_name = g.given_name,
		d.guardian_last_name = g.family_name,
		d.guardian_gender = g.gender,
		d.guardian_dob = g.birthdate,
		d.guardian_relationship = g.relationship_type
;

update openmrs_etl.etl_patient_demographics d
	join (select  * from
		(select o.person_id, o.value_text as guardian_national_id from obs o where o.concept_id = 163084 order by o.person_id desc)
		a group by a.person_id having count(a.person_id) > 1) p on p.person_id = d.patient_id
set d.guardian_national_id = p.guardian_national_id
;

update openmrs_etl.etl_patient_demographics d
join (select pi.patient_id,
max(if(pit.uuid='ccd8e564-030c-11e7-b443-54271eac1477',pi.identifier,null)) as national_id_no,
max(if(pit.uuid='8d793bee-c2cc-11de-8d13-0010c6dffd0f',pi.identifier,null)) kip_id,
max(if(pit.uuid='1b12fc38-030d-11e7-b443-54271eac1477',pi.identifier,null)) permanent_register_number,
max(if(pit.uuid='dae8f6b8-030c-11e7-b443-54271eac1477',pi.identifier,null)) nupi,
max(if(pit.uuid='893bcc12-030c-11e7-b443-54271eac1477',pi.identifier,null)) cwc_number,
max(if(pit.uuid='fc1c83d1-030c-11e7-b443-54271eac1477',pi.identifier,null)) hdss_number
from patient_identifier pi
join patient_identifier_type pit on pi.identifier_type=pit.patient_identifier_type_id
where voided=0 and (pi.date_created > last_update_time or pi.date_changed > last_update_time or pi.date_voided > last_update_time)
group by pi.patient_id) pid on pid.patient_id=d.patient_id
set d.national_id_no=pid.national_id_no,
		d.kip_id=pid.kip_id,
		d.permanent_register_number=pid.permanent_register_number,
    d.nupi=pid.nupi,
    d.cwc_number=pid.cwc_number,
    d.hdss_number=pid.hdss_number
;

update openmrs_etl.etl_patient_demographics d
join (select pa.person_id,
pa.state_province as county,
pa.county_district as sub_county,
pa.city_village as ward,
pa.address4 as sub_location,
pa.address3 as village,
pa.address2 as landmark,
pa.address1 as address, 
pa.address5 as health_facility 
from person_address pa where voided=0 and (pa.date_created > last_update_time or pa.date_changed > last_update_time or pa.date_voided > last_update_time)
group by pa.person_id) pa on pa.person_id = d.patient_id
set d.county = pa.county,
	d.sub_county = pa.sub_county,
	d.ward = pa.ward,
	d.sub_location = pa.sub_location,
	d.village = pa.village,
	d.landmark = pa.landmark,
	d.address = pa.address, 
	d.health_facility = pa.health_facility 
;

-- Update patient_demographics set county id --
update openmrs_etl.etl_patient_demographics d
join (select l.location_id, l.name from location l) county on d.county = county.name
set d.county_id = county.location_id where d.county_id is null;

-- Update patient_demographics set sub county id --
update openmrs_etl.etl_patient_demographics d
join (select l.location_id, l.name from location l) sub_county on d.sub_county = sub_county.name
set d.sub_county_id = sub_county.location_id where d.sub_county_id is null;

-- Update patient_demographics set ward id --
update openmrs_etl.etl_patient_demographics d
join (select l.location_id, l.name from location l) ward on d.ward = ward.name
set d.ward_id = ward.location_id where d.ward_id is null;

-- Update patient_demographics set health facility id --
update openmrs_etl.etl_patient_demographics d
join (select l.location_id, l.name from location l) health_facility on d.health_facility = health_facility.name
set d.health_facility_id = health_facility.location_id where d.health_facility_id is null;

END$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_immunisations$$
CREATE PROCEDURE sp_update_immunisations(IN concept_id INT(11), IN sequence_number TINYINT, IN col_name VARCHAR(25), IN last_update_time DATETIME)
BEGIN

	IF sequence_number <> '' THEN
		SET @query = CONCAT('update openmrs_etl.etl_immunisations i join ( select vx.person_id, vx.obs_datetime
				from obs vx join obs vx_seq on vx.encounter_id = vx_seq.encounter_id and vx_seq.concept_id=1418
        and vx.concept_id = ? and vx_seq.value_numeric = ?
        where vx.date_created > "',last_update_time,'" or vx.obs_datetime > "',last_update_time,'"
        or vx_seq.date_created > "',last_update_time,'" or vx_seq.obs_datetime > "',last_update_time,'" group by vx.person_id) o
        on o.person_id = i.patient_id set i.' , col_name, ' = o.obs_datetime');
		PREPARE stmt FROM @query;
		SET @concept_id = concept_id;
		SET @sequence_number = sequence_number;
		EXECUTE stmt USING @concept_id, @sequence_number;
		DEALLOCATE PREPARE stmt;
	ELSE
		SET @query = CONCAT('update openmrs_etl.etl_immunisations i join ( select vx.person_id, vx.obs_datetime
				from obs vx join obs vx_seq on vx.encounter_id = vx_seq.encounter_id and vx_seq.concept_id=1418
        and vx.concept_id = ? where vx.date_created > "',last_update_time,'" or vx.obs_datetime > "',last_update_time,'"
        or vx_seq.date_created > "',last_update_time,'" or vx_seq.obs_datetime > "',last_update_time,'" group by vx.person_id) o
        on o.person_id = i.patient_id set i.' , col_name, ' = o.obs_datetime');
		PREPARE stmt FROM @query;
		SET @concept_id = concept_id;
		EXECUTE stmt USING @concept_id;
		DEALLOCATE PREPARE stmt;
	END IF;

END$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_etl_immunisations$$
CREATE PROCEDURE sp_update_etl_immunisations()
BEGIN

DECLARE last_update_time DATETIME;
SELECT max(proc_time) into last_update_time from openmrs_etl.etl_script_status;

insert ignore into openmrs_etl.etl_immunisations(patient_id) select distinct o.person_id from obs o where o.date_created > last_update_time or o.obs_datetime > last_update_time;

	CALL sp_update_immunisations(886, '', 'bcg_vx_date', last_update_time);
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
	CALL sp_update_immunisations(1422, '', 'ipv_vx_date', last_update_time);
	CALL sp_update_immunisations(162586, 1, 'mr_1_vx_date', last_update_time);
	CALL sp_update_immunisations(162586, 2, 'mr_2_vx_date', last_update_time);
	CALL sp_update_immunisations(162586, 6, 'mr_at_6_vx_date', last_update_time);
	CALL sp_update_immunisations(5864, '', 'yf_vx_date', last_update_time);

END$$
DELIMITER ;

-- ----------------------------  scheduled updates ---------------------

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_scheduled_updates$$
CREATE PROCEDURE sp_scheduled_updates()
BEGIN
DECLARE update_script_id INT(11);

INSERT INTO openmrs_etl.etl_script_status(script_name, start_time) VALUES('scheduled_updates', NOW());
SET update_script_id = LAST_INSERT_ID();

CALL sp_update_etl_patient_demographics();
CALL sp_update_etl_immunisations();

UPDATE openmrs_etl.etl_script_status SET proc_time=NOW(), stop_time=NOW() where id= update_script_id;

END$$
DELIMITER ;

DELIMITER $$
SET GLOBAL EVENT_SCHEDULER=ON$$
DROP EVENT IF EXISTS event_update_openmrs_etl_tables$$
CREATE EVENT event_update_openmrs_etl_tables
	ON SCHEDULE EVERY 30 MINUTE STARTS CURRENT_TIMESTAMP
	DO
		CALL sp_scheduled_updates();
	$$
DELIMITER ;







