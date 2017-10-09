package org.openmrs.module.kenyaimmunisationplatform.util;

import org.json.JSONObject;
import org.openmrs.Location;

public class KipUtil {
	
	public static JSONObject createLocationJson(Location l) {
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("id", l.getId());
		jsonObject.put("name", l.getName());
		
		return jsonObject;
	}
}
