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

import org.openmrs.Location;
import org.openmrs.customdatatype.datatype.FreeTextDatatype;
import org.openmrs.customdatatype.datatype.RegexValidatedTextDatatype;
import org.openmrs.module.kenyaimmunisationplatform.metadata.sync.LocationMflCsvSource;
import org.openmrs.module.kenyaimmunisationplatform.metadata.sync.LocationMflSynchronization;
import org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle;
import org.openmrs.module.metadatadeploy.source.ObjectSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.location;
import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.locationAttributeType;
import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.locationTag;

/**
 * Created by amosl on 3/7/17.
 * <p>
 * Locations metadata bundle
 */
@Component
public class LocationMetadata extends AbstractMetadataBundle {
	
	@Autowired
	private LocationMflSynchronization mflSynchronization;
	
	public static final class _Location {
		
		public static final String UNKNOWN = "8d6c993e-c2cc-11de-8d13-0010c6dffd0f";
	}
	
	public static final class _LocationAttributeType {
		
		public static final String MASTER_FACILITY_CODE = "1fb2c933-0323-11e7-b443-54271eac1477";
		
		public static final String OFFICIAL_LANDLINE = "2cc86d22-0323-11e7-b443-54271eac1477";
		
		public static final String OFFICIAL_MOBILE = "30aede1c-0323-11e7-b443-54271eac1477";
		
		public static final String OFFICIAL_FAX = "3f04a0be-0323-11e7-b443-54271eac1477";
	}
	
	public static final class _LocationTag {
		
		public static final String COUNTRY = "b4d81cef-3b35-45f3-b673-500fc6db8722";
		
		public static final String COUNTY = "840dc839-f23e-442c-9776-537ca65890ab";
		
		public static final String SUB_COUNTY = "c541ecd9-8446-4661-b1a3-2502a8b881cd";
		
		public static final String WARD = "db487fb4-986c-4549-960d-2ad24dbda493";
		
		public static final String HEALTH_FACILITY = "b0e8aa74-0991-4751-8e5d-eb0d9b6b0306";
	}
	
	/**
	 * @see org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle#install()
	 */
	@Override
	public void install() throws Exception {
		
		install(locationAttributeType("Master Facility Code", "Unique facility code allocated by the Ministry of "
		        + "Health", RegexValidatedTextDatatype.class, "\\d{5}", 0, 1, _LocationAttributeType.MASTER_FACILITY_CODE));
		
		install(locationAttributeType("Official Landline", "Landline telephone contact number", FreeTextDatatype.class, "",
		    0, 1, _LocationAttributeType.OFFICIAL_LANDLINE));
		
		install(locationAttributeType("Official Mobile", "Mobile telephone contact number", FreeTextDatatype.class, "", 0,
		    1, _LocationAttributeType.OFFICIAL_MOBILE));
		
		install(locationAttributeType("Official Fax", "Fax telephone number", FreeTextDatatype.class, "", 0, 1,
		    _LocationAttributeType.OFFICIAL_FAX));
		
		install(locationTag("Country", "Country", _LocationTag.COUNTRY));
		install(locationTag("County", "County", _LocationTag.COUNTY));
		install(locationTag("Sub County", "Sub County", _LocationTag.SUB_COUNTY));
		install(locationTag("Ward", "Ward", _LocationTag.WARD));
		install(locationTag("Health Facility", "Health Facility", _LocationTag.HEALTH_FACILITY));
		
		install(true);
		
		install(location("Unknown Location", "Unknown Location", _Location.UNKNOWN));
	}
	
	/**
	 * @see AbstractMetadataBundle#install()
	 */
	public void install(boolean full) throws Exception {
		if (full) {
			ObjectSource<Location> source = new LocationMflCsvSource("metadata/siayacounty-2018-dhis2-1607.csv");
			sync(source, mflSynchronization);
		}
	}
	
}
