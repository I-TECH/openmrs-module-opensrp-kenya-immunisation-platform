--changeset me:schedule runOnChange:true endDelimiter:#$$
DROP PROCEDURE IF EXISTS sp_update_etl_patient_demographics

$$

CREATE PROCEDURE sp_update_etl_patient_demographics()
BEGIN

DECLARE last_update_time DATETIME;
SELECT max(start_time) into last_update_time from openmrs_etl.etl_script_status;
-- update etl_patient_demographics table
insert into openmrs_etl.etl_patient_demographics(
patient_id,
given_name,
middle_name,
family_name,
gender,
dob
)
select
p.person_id,
p.given_name,
p.middle_name,
p.family_name,
p.gender,
p.birthdate
FROM (
select
p.person_id,
pn.given_name,
pn.middle_name,
pn.family_name,
p.gender,
p.birthdate
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
) p
ON DUPLICATE KEY UPDATE given_name = p.given_name, middle_name=p.middle_name, family_name=p.family_name;


-- Set up mother and guardian details --
update openmrs_etl.etl_patient_demographics d
join (select * from
		(select p.person_id, p.gender,p.birthdate, pn.given_name, pn.family_name, r.person_b,
			 concat(rt.a_is_to_b, " / ", rt.b_is_to_a) as relationship_type from person p join person_name pn on p.person_id = pn.person_id
			left join relationship r on p.person_id = r.person_a join relationship_type rt
				on r.relationship = rt.relationship_type_id where r.person_b in (select patient_id from patient) and (p.date_created > last_update_time
        or p.date_changed > last_update_time or pn.date_created > last_update_time or pn.date_changed > last_update_time or pn.date_voided > last_update_time)
		 order by p.person_id asc) prx group by prx.person_b) m on m.person_b = d.patient_id
join (select * from
		(select p.person_id, p.gender,p.birthdate, pn.given_name, pn.family_name, r.person_b,
			 concat(rt.a_is_to_b, " / ", rt.b_is_to_a) as relationship_type from person p join person_name pn on p.person_id = pn.person_id
			left join relationship r on p.person_id = r.person_a join relationship_type rt
				on r.relationship = rt.relationship_type_id where r.person_b in (select patient_id from patient) and (p.date_created > last_update_time
				or p.date_changed > last_update_time or pn.date_created > last_update_time or pn.date_changed > last_update_time or pn.date_voided > last_update_time)
		 order by p.person_id desc) prx group by prx.person_b having count(prx.person_b) > 1) g
	on g.person_b = d.patient_id
	set d.mother_first_name = m.given_name,
		d.mother_last_name = m.family_name,
		d.mother_gender = m.gender,
		d.mother_dob = m.birthdate,
		d.mother_relationship = m.relationship_type,
		d.guardian_first_name = g.given_name,
		d.guardian_last_name = g.family_name,
		d.guardian_gender = g.gender,
		d.guardian_dob = g.birthdate,
		d.guardian_relationship = g.relationship_type
;

update openmrs_etl.etl_patient_demographics d
join (select pi.patient_id,
max(if(pit.uuid='ccd8e564-030c-11e7-b443-54271eac1477',pi.identifier,null)) as national_id_no,
max(if(pit.uuid='606a1a0c-348b-435c-9773-968471d3165f',pi.identifier,null)) kip_id,
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
join (select pa.patient_id,
pa.state_province as county,
pa.county_district as sub_county,
pa.city_village as ward,
pa.address4 as sub_location,
pa.address3 as village,
pa.address2 as landmark,
pa.address1 as address
from person_address pa where voided=0 and (pa.date_created > last_update_time or pa.date_changed > last_update_time or pa.date_voided > last_update_time)
group by pa.patient_id) pa on pa.patient_id = d.patient_id
set d.county = pa.county,
	d.sub_county = pa.sub_county,
	d.ward = pa.ward,
	d.sub_location = pa.sub_location,
	d.village = pa.village,
	d.landmark = pa.landmark,
	d.address = pa.address
;

END

$$

DROP PROCEDURE IF EXISTS sp_update_etl_immunisations

$$

CREATE PROCEDURE sp_update_etl_immunisations()
BEGIN

DECLARE last_update_time DATETIME;
SELECT max(start_time) into last_update_time from openmrs_etl.etl_script_status;

insert into openmrs_etl.etl_immunisations(
			patient_id
		)	select distinct o.person_id from obs o where o.date_created > last_update_time or o.obs_datetime > last_update_time
		ON DUPLICATE KEY UPDATE patient_id = o.person_id;

		update openmrs_etl.etl_immunisations i
			join (
				select vx.person_id, vx.concept_id, vx.obs_datetime, vx. encounter_id, vx_seq.value_numeric
				from obs vx join obs vx_seq on vx.encounter_id = vx_seq.encounter_id and vx_seq.concept_id=1418
        and vx.concept_id <> 1410 and vx.concept_id <> 1418
        where vx.date_created > last_update_time or vx.obs_datetime > last_update_time
        or vx_seq.date_created > last_update_time or vx_seq.obs_datetime > last_update_time
				) o on o.person_id = i.patient_id
			set i.bcg_vx_date = IF(o.concept_id=886, o.obs_datetime, i.bcg_vx_date),
				i.opv_0_vx_date = IF(o.concept_id=783 AND o.value_numeric=0, o.obs_datetime, i.opv_0_vx_date),
				i.opv_1_vx_date = IF(o.concept_id=783 AND o.value_numeric=1, o.obs_datetime, i.opv_1_vx_date),
				i.pcv_1_vx_date = IF(o.concept_id=162342 AND o.value_numeric=1, o.obs_datetime, i.pcv_1_vx_date),
				i.penta_1_vx_date = IF(o.concept_id=1685 AND o.value_numeric=1, o.obs_datetime, i.penta_1_vx_date),
				i.rota_1_vx_date = IF(o.concept_id=159698 AND o.value_numeric=1, o.obs_datetime, i.rota_1_vx_date),
				i.opv_2_vx_date = IF(o.concept_id=783 AND o.value_numeric=2, o.obs_datetime, i.opv_2_vx_date),
				i.pcv_2_vx_date = IF(o.concept_id=162342 AND o.value_numeric=2, o.obs_datetime, i.pcv_2_vx_date),
				i.penta_2_vx_date = IF(o.concept_id=1685 AND o.value_numeric=2, o.obs_datetime, i.penta_2_vx_date),
				i.rota_2_vx_date = IF(o.concept_id=159698 AND o.value_numeric=2, o.obs_datetime, i.rota_2_vx_date),
				i.opv_3_vx_date = IF(o.concept_id=783 AND o.value_numeric=3, o.obs_datetime, i.opv_3_vx_date),
				i.pcv_3_vx_date = IF(o.concept_id=162342 AND o.value_numeric=3, o.obs_datetime, i.pcv_3_vx_date),
				i.penta_3_vx_date = IF(o.concept_id=1685 AND o.value_numeric=3, o.obs_datetime, i.penta_3_vx_date),
				i.ipv_vx_date = IF(o.concept_id=1422, o.obs_datetime, i.ipv_vx_date),
				i.mr_1_vx_date = IF(o.concept_id=162586 AND o.value_numeric=1, o.obs_datetime, i.mr_1_vx_date),
				i.mr_2_vx_date = IF(o.concept_id=162586 AND o.value_numeric=2, o.obs_datetime, i.mr_2_vx_date),
				i.mr_at_6_vx_date = IF(o.concept_id=162586 AND o.value_numeric=6, o.obs_datetime, i.mr_at_6_vx_date),
				i.yf_vx_date = IF(o.concept_id=5864, o.obs_datetime, i.yf_vx_date)
		;

END

$$

-- ----------------------------  scheduled updates ---------------------

DROP PROCEDURE IF EXISTS sp_scheduled_updates

$$

CREATE PROCEDURE sp_scheduled_updates()
BEGIN
DECLARE update_script_id INT(11);

INSERT INTO openmrs_etl.etl_script_status(script_name, start_time) VALUES('scheduled_updates', NOW());
SET update_script_id = LAST_INSERT_ID();

CALL sp_update_etl_patient_demographics();
CALL sp_update_etl_immunisations();

UPDATE openmrs_etl.etl_script_status SET stop_time=NOW() where id= update_script_id;

END

$$

SET GLOBAL EVENT_SCHEDULER=ON

$$

DROP EVENT IF EXISTS event_update_openmrs_etl_tables

$$

CREATE EVENT event_update_openmrs_etl_tables
	ON SCHEDULE EVERY 5 MINUTE STARTS CURRENT_TIMESTAMP
	DO
		CALL sp_scheduled_updates();
	$$








