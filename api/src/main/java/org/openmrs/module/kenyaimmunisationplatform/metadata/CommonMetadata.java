package org.openmrs.module.kenyaimmunisationplatform.metadata;

import org.openmrs.Concept;
import org.openmrs.Location;
import org.openmrs.PatientIdentifierType.LocationBehavior;
import org.openmrs.module.idgen.validator.LuhnMod30IdentifierValidator;
import org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle;
import org.springframework.stereotype.Component;

import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.*;

/**
 * Created by amosl on 3/6/17.
 */
@Component
public class CommonMetadata extends AbstractMetadataBundle {
	
	public static final class _EncounterType {
		
		public static final String REGISTRATION = "8a3d7e03-0250-11e7-aef1-54271eac1477";
		
		public static final String TRIAGE = "991b7123-0250-11e7-aef1-54271eac1477";
		
		public static final String VACCINATION = "b5a54d86-0250-11e7-aef1-54271eac1477";
		
		public static final String CHILD_ENROLLMENT = "74f0fcf0-4a98-11e7-9fd4-080027b84a73";
		
		public static final String NEW_WOMAN_REGISTRATION = "8cb2f455-4a98-11e7-9fd4-080027b84a73";
		
		public static final String NEW_GUARDIAN_REGISTRATION = "916fe5f5-4a98-11e7-9fd4-080027b84a73";
	}
	
	public static final class _Form {
		
		public static final String CHILD_ENROLLMENT = "5295b23d-024f-11e7-aef1-54271eac1477";
		
		public static final String TRIAGE = "6985afe3-024f-11e7-aef1-54271eac1477";
		
		public static final String BCG = "7732c7c5-024f-11e7-aef1-54271eac1477";
		
		public static final String VITAMIN_A = "967647cc-024f-11e7-aef1-54271eac1477";
		
		public static final String VACCINATION = "4c272b32-025c-11e7-aef1-54271eac1477";
	}
	
	public static final class _PatientIdentifierType {
		
		public static final String OPENMRS_ID = "8d793bee-c2cc-11de-8d13-0010c6dffd0f";
		
		public static final String CWC_NUMBER = "893bcc12-030c-11e7-b443-54271eac1477";
		
		public static final String DISTRICT_REGISTRATION_NUMBER = "bffa3601-030c-11e7-b443-54271eac1477";
		
		public static final String NATIONAL_ID = "ccd8e564-030c-11e7-b443-54271eac1477";
		
		public static final String NATIONAL_UNIQUE_PATIENT_IDENTIFIER = "dae8f6b8-030c-11e7-b443-54271eac1477";
		
		public static final String OLD_ID = "8d79403a-c2cc-11de-8d13-0010c6dffd0f";
		
		public static final String HDSS_NUMBER = "fc1c83d1-030c-11e7-b443-54271eac1477";
		
		public static final String PATIENT_CLINIC_NUMBER = "04222d69-030d-11e7-b443-54271eac1477";
		
		public static final String PERMANENT_REGISTER_NUMBER = "1b12fc38-030d-11e7-b443-54271eac1477";
	}
	
	public static final class _PersonAttributeType {
		
		public static final String BIRTHPLACE = "8d8718c2-c2cc-11de-8d13-0010c6dffd0f";
		
		public static final String CITIZENSHIP = "8d871afc-c2cc-11de-8d13-0010c6dffd0f";
		
		public static final String TELEPHONE_CONTACT = "53865094-031d-11e7-b443-54271eac1477";
		
		public static final String CIVIL_STATUS = "8d871f2a-c2cc-11de-8d13-0010c6dffd0f";
		
		public static final String EMAIL_ADDRESS = "696eca80-031d-11e7-b443-54271eac1477";
		
		public static final String HEALTH_CENTER = "8d87236c-c2cc-11de-8d13-0010c6dffd0f";
		
		public static final String SUBCHIEF_NAME = "76151583-031d-11e7-b443-54271eac1477";
		
		public static final String HEALTH_DISTRICT = "8d872150-c2cc-11de-8d13-0010c6dffd0f";
		
		public static final String NEXT_OF_KIN_NAME = "84aafd3f-031d-11e7-b443-54271eac1477";
		
		public static final String NEXT_OF_KIN_RELATIONSHIP = "8af5d506-031d-11e7-b443-54271eac1477";
		
		public static final String NEXT_OF_KIN_CONTACT = "93abdd8e-031d-11e7-b443-54271eac1477";
		
		public static final String NEXT_OF_KIN_ADDRESS = "9a3e9b7b-031d-11e7-b443-54271eac1477";
		
		public static final String MOTHERS_NAME = "8d871d18-c2cc-11de-8d13-0010c6dffd0f";
		
		public static final String RACE = "8d871386-c2cc-11de-8d13-0010c6dffd0f";
		
		public static final String CHW_NAME = "0fc03c0d-ede8-485d-bf93-09b6158db1b9";
		
		public static final String CHW_PHONE_NUMBER = "5008fca5-d839-4300-ac23-2cdf27ae5e56";
	}
	
	public static final class _RelationshipType {
		
		public static final String GRANDPARENT_GRANDCHILD = "70fccac8-54d8-11e7-b198-080027b84a73";
	}
	
	@Override
	public void install() {
		
		install(encounterType("Registration", "Initial data collection for a patient, not specific to any program",
		    _EncounterType.REGISTRATION));
		install(encounterType("Triage", "Collection of limited data prior to a more thorough examination",
		    _EncounterType.TRIAGE));
		install(encounterType("Vaccination", "Collection of information on vaccination given", _EncounterType.VACCINATION));
		install(encounterType("Child Enrollment", "Initial enrollment of a child to immunisation platform.",
		    _EncounterType.CHILD_ENROLLMENT));
		install(encounterType("New Woman Registration", "Registration of a mother of a child.",
		    _EncounterType.NEW_WOMAN_REGISTRATION));
		install(encounterType("New Guardian Registration", "Registration of a guardian of a child.",
		    _EncounterType.NEW_GUARDIAN_REGISTRATION));
		
		install(form("Child Enrollment Form", "The first form that captures basic demographic information on the "
		        + "child and caregiver information", _EncounterType.REGISTRATION, "1", _Form.CHILD_ENROLLMENT));
		install(form("Triage", "This form is the first form filled when a KNOWN patient enters the clinic",
		    _EncounterType.TRIAGE, "1", _Form.TRIAGE));
		install(form("BCG", "This form collects the BCG information", _EncounterType.VACCINATION, "1", _Form.BCG));
		install(form("Vitamin A", "This form collects information on the vitamin A distribution to the child",
		    _EncounterType.VACCINATION, "1", _Form.VITAMIN_A));
		install(form("Vaccination", "This form collects the information on the vaccination that is given.",
		    _EncounterType.VACCINATION, "1", _Form.VACCINATION));
		
		install(patientIdentifierType("OPENMRS_ID", "Medical Record Number generated by OpenMRS for every patient", null,
		    null, LuhnMod30IdentifierValidator.class, LocationBehavior.REQUIRED, true, _PatientIdentifierType.OPENMRS_ID));
		install(patientIdentifierType("CWC_NUMBER", "Assigned to a child patient when enrolling into the Child "
		        + "Welfare Clinic (CWC)", ".{1,14}",
		    "Should take the format (CWC-MFL code-serial number) e.g CWC-15007-00001", null, LocationBehavior.NOT_USED,
		    false, _PatientIdentifierType.CWC_NUMBER));
		install(patientIdentifierType("District Registration Number", "Assigned to every TB patient", null, null, null,
		    LocationBehavior.NOT_USED, false, _PatientIdentifierType.DISTRICT_REGISTRATION_NUMBER));
		install(patientIdentifierType("ID_NUMBER", "Kenyan national identity card number", "\\d{5,10}",
		    "Between 5 and 10 consecutive digits", null, LocationBehavior.NOT_USED, false,
		    _PatientIdentifierType.NATIONAL_ID));
		install(patientIdentifierType("NATIONAL_UNIQUE_PATIENT_IDENTIFIER", "National Unique patient identifier", ""
		        + ".{1,14}", "At most 14 characters long", null, LocationBehavior.NOT_USED, false,
		    _PatientIdentifierType.NATIONAL_UNIQUE_PATIENT_IDENTIFIER));
		install(patientIdentifierType("Old Identification Number", "Identifier given out prior to OpenMRS", null, null,
		    null, LocationBehavior.NOT_USED, false, _PatientIdentifierType.OLD_ID));
		install(patientIdentifierType("HDSS_NUMBER", "Unique number for HDSS integration", null, null, null,
		    LocationBehavior.NOT_USED, false, _PatientIdentifierType.HDSS_NUMBER));
		install(patientIdentifierType("Patient Clinic Number", "Assigned to the patient at a clinic service (not "
		        + "globally unique)", ".{1,15}", "At most 15 characters long", null, LocationBehavior.NOT_USED, false,
		    _PatientIdentifierType.PATIENT_CLINIC_NUMBER));
		install(patientIdentifierType("PERMANENT_REGISTER_NUMBER", "Assigned to a patient upon first entry to the "
		        + "permanent register", ".{1,14}", "Accepts alphanumeric values only", null, LocationBehavior.NOT_USED,
		    false, _PatientIdentifierType.PERMANENT_REGISTER_NUMBER));
		
		install(personAttributeType("Birthplace", "Location of persons birth", String.class, 0, false, 0,
		    _PersonAttributeType.BIRTHPLACE));
		install(personAttributeType("Citizenship", "Country of which this person is a member", String.class, 0, false, 1,
		    _PersonAttributeType.CITIZENSHIP));
		install(personAttributeType("Telephone contact", "Telephone contact number", String.class, null, false, 1.0,
		    _PersonAttributeType.TELEPHONE_CONTACT));
		install(personAttributeType("Civil Status", "Marriage status of this person", Concept.class, 1054, false, 2,
		    _PersonAttributeType.CIVIL_STATUS));
		install(personAttributeType("Email address", "Email address of person", String.class, null, false, 2.0,
		    _PersonAttributeType.EMAIL_ADDRESS));
		install(personAttributeType("Health Center", "Specific Location of this person's home health center.",
		    Location.class, 0, false, 3, _PersonAttributeType.HEALTH_CENTER));
		
		install(personAttributeType("Subchief name", "Name of subchief or chief of patient's area", String.class, null,
		    false, 3.0, _PersonAttributeType.SUBCHIEF_NAME));
		install(personAttributeType("Health District", "District/region in which this patient' home health center "
		        + "resides", String.class, 0, false, 4, _PersonAttributeType.HEALTH_DISTRICT));
		install(personAttributeType("Next of kin name", "Name of patient's next of kin", String.class, null, false, 4.0,
		    _PersonAttributeType.NEXT_OF_KIN_NAME));
		install(personAttributeType("Next of kin relationship", "Next of kin relationship to the patient", String.class,
		    null, false, 4.1, _PersonAttributeType.NEXT_OF_KIN_RELATIONSHIP));
		install(personAttributeType("Next of kin contact", "Telephone contact of patient's next of kin", String.class, null,
		    false, 4.2, _PersonAttributeType.NEXT_OF_KIN_CONTACT));
		install(personAttributeType("Next of kin address", "Address of patient's next of kin", String.class, null, false,
		    4.3, _PersonAttributeType.NEXT_OF_KIN_ADDRESS));
		install(personAttributeType("Mother's Name", "First or last name of this person's mother", String.class, 0, false,
		    5, _PersonAttributeType.MOTHERS_NAME));
		install(personAttributeType("Race", "Group of persons related by common descent or heredity", String.class, 0,
		    false, 6, _PersonAttributeType.RACE));
		install(personAttributeType("CHW_Name", "This is the name of the patient's Community Health Worker (CHW).",
		    String.class, 0, false, 6.1, _PersonAttributeType.CHW_NAME));
		install(personAttributeType("CHW_Phone_Number",
		    "This is the phone number of the patient's Community Health Worker (CHW).", String.class, 0, false, 6.2,
		    _PersonAttributeType.CHW_PHONE_NUMBER));
		
		install(relationshipType("Grandparent", "Grandchild", "Relationship from a grandparent to the child",
		    _RelationshipType.GRANDPARENT_GRANDCHILD));
	}
}
