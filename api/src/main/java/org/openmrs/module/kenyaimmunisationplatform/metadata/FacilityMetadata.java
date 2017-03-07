/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 * <p>
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * <p>
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */

package org.openmrs.module.kenyaimmunisationplatform.metadata;

import org.openmrs.customdatatype.datatype.FreeTextDatatype;
import org.openmrs.customdatatype.datatype.RegexValidatedTextDatatype;
import org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle;
import org.springframework.stereotype.Component;

import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.locationAttributeType;

/**
 * Created by amosl on 3/7/17.
 * <p>
 * Locations metadata bundle
 */
@Component
public class FacilityMetadata extends AbstractMetadataBundle {
	
	public static final class _LocationAttributeType {
		
		public static final String MASTER_FACILITY_CODE = "1fb2c933-0323-11e7-b443-54271eac1477";
		
		public static final String OFFICIAL_LANDLINE = "2cc86d22-0323-11e7-b443-54271eac1477";
		
		public static final String OFFICIAL_MOBILE = "30aede1c-0323-11e7-b443-54271eac1477";
		
		public static final String OFFICIAL_FAX = "3f04a0be-0323-11e7-b443-54271eac1477";
	}
	
	/**
	 * @see org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle#install()
	 */
	@Override
	public void install() throws Exception {
		install(locationAttributeType("Master Facility Code", "Unique facility code allocated by the Ministry of Health",
		    RegexValidatedTextDatatype.class, "\\d{5}", 0, 1, _LocationAttributeType.MASTER_FACILITY_CODE));
		
		install(locationAttributeType("Official Landline", "Landline telephone contact number", FreeTextDatatype.class, "",
		    0, 1, _LocationAttributeType.OFFICIAL_LANDLINE));
		
		install(locationAttributeType("Official Mobile", "Mobile telephone contact number", FreeTextDatatype.class, "", 0,
		    1, _LocationAttributeType.OFFICIAL_MOBILE));
		
		install(locationAttributeType("Official Fax", "Fax telephone number", FreeTextDatatype.class, "", 0, 1,
		    _LocationAttributeType.OFFICIAL_FAX));
	}
	
}
