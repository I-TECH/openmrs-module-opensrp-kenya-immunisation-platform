/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 *
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.kenyaimmunisationplatform.api.impl;

import org.json.JSONArray;
import org.json.JSONObject;
import org.openmrs.Location;
import org.openmrs.LocationTag;
import org.openmrs.api.APIException;
import org.openmrs.api.LocationService;
import org.openmrs.api.UserService;
import org.openmrs.api.db.LocationDAO;
import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.module.kenyaimmunisationplatform.Item;
import org.openmrs.module.kenyaimmunisationplatform.api.KenyaImmunisationPlatformService;
import org.openmrs.module.kenyaimmunisationplatform.api.dao.KenyaImmunisationPlatformDao;
import org.openmrs.module.kenyaimmunisationplatform.util.KipConstants;
import org.openmrs.module.kenyaimmunisationplatform.util.KipUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service("kenyaimmunisationplatform.KenyaImmunisationPlatformService")
public class KenyaImmunisationPlatformServiceImpl extends BaseOpenmrsService implements KenyaImmunisationPlatformService {
	
	@Autowired
	KenyaImmunisationPlatformDao dao;
	
	@Autowired
	LocationService locationService;
	
	UserService userService;
	
	/**
	 * Injected in moduleApplicationContext.xml
	 */
	public void setDao(KenyaImmunisationPlatformDao dao) {
		this.dao = dao;
	}
	
	/**
	 * Injected in moduleApplicationContext.xml
	 */
	public void setUserService(UserService userService) {
		this.userService = userService;
	}
	
	@Override
	public Item getItemByUuid(String uuid) throws APIException {
		return dao.getItemByUuid(uuid);
	}
	
	@Override
	public Item saveItem(Item item) throws APIException {
		if (item.getOwner() == null) {
			item.setOwner(userService.getUser(1));
		}
		
		return dao.saveItem(item);
	}
	
	@Override
	public JSONArray getChildLocations(int parentLocationId) {
		Location parent = locationService.getLocation(parentLocationId);
		
		List<Location> locations = locationService.getLocations("", parent, null, false, null, null);
		
		JSONArray jsonArray = new JSONArray();
		for (Location l : locations) {
			jsonArray.put(KipUtil.createLocationJson(l));
		}
		
		return jsonArray;
	}
	
	@Override
	public JSONArray getAllCounties() {
		LocationTag locationTag = locationService.getLocationTagByName(KipConstants.LOCATION_TAG_COUNTY);
		
		List<Location> locations = locationService.getLocationsByTag(locationTag);
		
		JSONArray jsonArray = new JSONArray();
		for (Location l : locations) {
			jsonArray.put(KipUtil.createLocationJson(l));
		}
		
		return jsonArray;
	}
}
