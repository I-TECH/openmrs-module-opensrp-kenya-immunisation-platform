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

package org.openmrs.module.kenyaimmunisationplatform.metadata.sync;

import org.apache.commons.lang3.StringUtils;
import org.openmrs.Location;
import org.openmrs.LocationAttribute;
import org.openmrs.LocationAttributeType;
import org.openmrs.LocationTag;
import org.openmrs.api.LocationService;
import org.openmrs.api.context.Context;
import org.openmrs.module.kenyaimmunisationplatform.metadata.LocationMetadata;
import org.openmrs.module.metadatadeploy.MetadataUtils;
import org.openmrs.module.metadatadeploy.source.AbstractCsvResourceSource;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

/**
 * Location source from Master Facility CSV resource
 */
public class LocationMflCsvSource extends AbstractCsvResourceSource<Location> {
	
	private LocationService locationService = Context.getLocationService();
	
	private LocationAttributeType codeAttrType, landlineAttrType, mobileAttrType, faxAttrType;
	
	/**
	 * Constructs a new location source
	 * 
	 * @param csvFile the csv resource path
	 */
	public LocationMflCsvSource(String csvFile) throws IOException {
		super(csvFile, true);
		
		this.codeAttrType = MetadataUtils.existing(LocationAttributeType.class,
		    LocationMetadata._LocationAttributeType.MASTER_FACILITY_CODE);
		this.landlineAttrType = MetadataUtils.existing(LocationAttributeType.class,
		    LocationMetadata._LocationAttributeType.OFFICIAL_LANDLINE);
		this.faxAttrType = MetadataUtils.existing(LocationAttributeType.class,
		    LocationMetadata._LocationAttributeType.OFFICIAL_FAX);
		this.mobileAttrType = MetadataUtils.existing(LocationAttributeType.class,
		    LocationMetadata._LocationAttributeType.OFFICIAL_MOBILE);
	}
	
	/**
	 * @see org.openmrs.module.metadatadeploy.source.AbstractCsvResourceSource#parseLine(String[])
	 */
	@Override
	public Location parseLine(String[] line) {
		
		String mflCode = line[0];
		String name = line[1];
		
		String countyName = line[9];
		String constituencyName = line[10].equals(countyName) ? line[10] + " sub county" : line[10];
		String subCountyName = line[11];
		String wardName = line[12].equals(countyName) || line[12].equals(constituencyName) ? line[12] + " ward" : line[12];
		String type = line[4];
		
		Set<LocationTag> locationTags;
		
		Location county = locationService.getLocation(countyName);
		if (county == null) {
			county = new Location();
			county.setName(countyName);
			county.setDescription(countyName + " county");
			county.setCountry("Kenya");
			locationTags = new HashSet<LocationTag>();
			locationTags.add(MetadataUtils.existing(LocationTag.class, LocationMetadata._LocationTag.COUNTY));
			county.setTags(locationTags);
			locationService.saveLocation(county);
		}
		
		Location subCounty = locationService.getLocation(constituencyName);
		if (subCounty == null) {
			subCounty = new Location();
			subCounty.setName(constituencyName);
			subCounty.setParentLocation(county);
			subCounty.setDescription(constituencyName + " sub county");
			subCounty.setCountry("Kenya");
			locationTags = new HashSet<LocationTag>();
			locationTags.add(MetadataUtils.existing(LocationTag.class, LocationMetadata._LocationTag.SUB_COUNTY));
			subCounty.setTags(locationTags);
			locationService.saveLocation(subCounty);
		}
		
		Location ward = locationService.getLocation(wardName);
		if (ward == null) {
			ward = new Location();
			ward.setName(wardName);
			ward.setParentLocation(subCounty);
			ward.setDescription(wardName + " ward");
			ward.setCountry("Kenya");
			locationTags = new HashSet<LocationTag>();
			locationTags.add(MetadataUtils.existing(LocationTag.class, LocationMetadata._LocationTag.WARD));
			ward.setTags(locationTags);
			locationService.saveLocation(ward);
		}
		
		Location healthFacility = new Location();
		healthFacility.setName(name);
		healthFacility.setDescription(type);
		healthFacility.setParentLocation(ward);
		healthFacility.setCountry("Kenya");
		setAsAttribute(healthFacility, codeAttrType, mflCode);
		
		locationTags = new HashSet<LocationTag>();
		locationTags.add(MetadataUtils.existing(LocationTag.class, LocationMetadata._LocationTag.HEALTH_FACILITY));
		healthFacility.setTags(locationTags);
		
		return healthFacility;
	}
	
	/**
	 * Adds a value as an attribute if it's not blank
	 * 
	 * @param location the location
	 * @param type the attribute type
	 * @param value the value
	 */
	protected void setAsAttribute(Location location, LocationAttributeType type, String value) {
		if (StringUtils.isNotBlank(value)) {
			LocationAttribute attr = new LocationAttribute();
			attr.setAttributeType(type);
			attr.setValue(value.trim());
			attr.setOwner(location);
			location.addAttribute(attr);
		}
	}
}
