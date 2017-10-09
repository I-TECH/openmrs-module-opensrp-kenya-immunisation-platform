/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 *
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.kenyaimmunisationplatform.web.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.JSONArray;
import org.json.JSONObject;
import org.openmrs.module.kenyaimmunisationplatform.api.KenyaImmunisationPlatformService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 *
 */
@Controller
public class KenyaImmunisationPlatformController {
	
	/** Logger for this class and subclasses */
	protected final Log log = LogFactory.getLog(getClass());
	
	@Autowired
	KenyaImmunisationPlatformService kenyaImmunisationPlatformService;
	
	@RequestMapping(value = "/module/kenyaimmunisationplatform/location", method = RequestMethod.GET)
	@ResponseBody
	public String getChildLocations(@RequestParam("locationId") int locationId) {
		JSONObject result = new JSONObject();
		result.put("data", kenyaImmunisationPlatformService.getChildLocations(locationId));
		
		return result.toString();
	}
	
	@RequestMapping(value = "/module/kenyaimmunisationplatform/counties", method = RequestMethod.GET)
	@ResponseBody
	public String getAllCounties() {
		JSONObject result = new JSONObject();
		result.put("data", kenyaImmunisationPlatformService.getAllCounties());
		
		return result.toString();
	}
	
}
