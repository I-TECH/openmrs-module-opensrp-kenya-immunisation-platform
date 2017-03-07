package org.openmrs.module.kenyaimmunisationplatform.metadata;

import org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle;
import org.springframework.stereotype.Component;

import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.encounterType;
import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.form;

/**
 * Created by amosl on 3/6/17.
 */
@Component
public class CommonMetadata extends AbstractMetadataBundle {
	
	public static final class _EncounterType {
		
		public static final String REGISTRATION = "8a3d7e03-0250-11e7-aef1-54271eac1477";
		
		public static final String TRIAGE = "991b7123-0250-11e7-aef1-54271eac1477";
		
		public static final String VACCINATION = "b5a54d86-0250-11e7-aef1-54271eac1477";
	}
	
	public static final class _Form {
		
		public static final String CHILD_ENROLLMENT = "5295b23d-024f-11e7-aef1-54271eac1477";
		
		public static final String TRIAGE = "6985afe3-024f-11e7-aef1-54271eac1477";
		
		public static final String BCG = "7732c7c5-024f-11e7-aef1-54271eac1477";
		
		public static final String VITAMIN_A = "967647cc-024f-11e7-aef1-54271eac1477";
		
		public static final String VACCINATION = "4c272b32-025c-11e7-aef1-54271eac1477";
	}
	
	@Override
	public void install() {

		install(encounterType("Registration", "Initial data collection for a patient, not specific to any program", _EncounterType.REGISTRATION));
		install(encounterType("Triage", "Collection of limited data prior to a more thorough examination", _EncounterType.TRIAGE));
		install(encounterType("Vaccination", "Collection of information on vaccination given", _EncounterType.VACCINATION));

		install(form("Child Enrollment Form", "The first form that captures basic demographic information on the "
		        + "child and caregiver information", _EncounterType.REGISTRATION, "1", _Form.CHILD_ENROLLMENT));
		install(form("Triage", "This form is the first form filled when a KNOWN patient enters the clinic",
		    _EncounterType.TRIAGE, "1", _Form.TRIAGE));
		install(form("BCG", "This form collects the BCG information", _EncounterType.VACCINATION, "1", _Form.BCG));
		install(form("Vitamin A", "This form collects information on the vitamin A distribution to the child",
		    _EncounterType.VACCINATION, "1", _Form.VITAMIN_A));
		install(form("Vaccination", "This form collects the information on the vaccination that is given.",
		    _EncounterType.VACCINATION, "1", _Form.VACCINATION));
	}
}
