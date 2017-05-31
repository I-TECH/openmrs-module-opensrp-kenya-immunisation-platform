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

import org.openmrs.Location;
import org.openmrs.LocationAttribute;
import org.openmrs.api.LocationService;
import org.openmrs.module.kenyaimmunisationplatform.metadata.LocationMetadata;
import org.openmrs.module.metadatadeploy.sync.ObjectSynchronization;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Iterator;
import java.util.List;

/**
 * Synchronization operation to sync locations with a CSV copy of the Kenya Master Facility List
 */
@Component
public class LocationMflSynchronization implements ObjectSynchronization<Location> {
	
	@Autowired
	private LocationService locationService;
	
	/**
	 * @see org.openmrs.module.metadatadeploy.sync.ObjectSynchronization#fetchAllExisting()
	 */
	@Override
	public List<Location> fetchAllExisting() {
		return locationService.getAllLocations(true);
	}
	
	/**
	 * @see org.openmrs.module.metadatadeploy.sync.ObjectSynchronization#getObjectSyncKey(org.openmrs.OpenmrsObject)
	 */
	@Override
	public Object getObjectSyncKey(Location obj) {
		return getAsAttribute(obj, LocationMetadata._LocationAttributeType.MASTER_FACILITY_CODE);
	}
	
	/**
	 * @see org.openmrs.module.metadatadeploy.sync.ObjectSynchronization#updateRequired(org.openmrs.OpenmrsObject,
	 *      org.openmrs.OpenmrsObject)
	 */
	@Override
	public boolean updateRequired(Location incoming, Location existing) {
		boolean objectsMatch = OpenmrsUtil.nullSafeEquals(incoming.getName(), existing.getName())
		        && OpenmrsUtil.nullSafeEquals(incoming.getDescription(), existing.getDescription())
		        && OpenmrsUtil.nullSafeEquals(incoming.getStateProvince(), existing.getStateProvince())
		        && OpenmrsUtil.nullSafeEquals(incoming.getCountyDistrict(), existing.getCountyDistrict())
		        && OpenmrsUtil.nullSafeEquals(incoming.getCityVillage(), existing.getCityVillage())
		        && OpenmrsUtil.nullSafeEquals(
		            getAsAttribute(incoming, LocationMetadata._LocationAttributeType.OFFICIAL_FAX),
		            getAsAttribute(existing, LocationMetadata._LocationAttributeType.OFFICIAL_FAX))
		        && OpenmrsUtil.nullSafeEquals(
		            getAsAttribute(incoming, LocationMetadata._LocationAttributeType.OFFICIAL_LANDLINE),
		            getAsAttribute(existing, LocationMetadata._LocationAttributeType.OFFICIAL_LANDLINE))
		        && OpenmrsUtil.nullSafeEquals(
		            getAsAttribute(incoming, LocationMetadata._LocationAttributeType.OFFICIAL_MOBILE),
		            getAsAttribute(existing, LocationMetadata._LocationAttributeType.OFFICIAL_MOBILE))
		        && OpenmrsUtil.nullSafeEquals(incoming.getPostalCode(), existing.getPostalCode());
		
		return !objectsMatch;
	}
	
	protected Object getAsAttribute(Location location, String attrTypeUuid) {
		LocationAttribute attr = this.findFirstAttribute(location, attrTypeUuid);
		return attr != null ? attr.getValue() : null;
	}
	
	protected LocationAttribute findFirstAttribute(Location location, String attrTypeUuid) {
		if (location.getAttributes() != null) {
			Iterator i$ = (location.getAttributes().iterator());
			
			while (i$.hasNext()) {
				LocationAttribute attr = (LocationAttribute) i$.next();
				if (attr.getAttributeType().getUuid().equals(attrTypeUuid) && !attr.isVoided().booleanValue()) {
					return attr;
				}
			}
		}
		return null;
	}
}
