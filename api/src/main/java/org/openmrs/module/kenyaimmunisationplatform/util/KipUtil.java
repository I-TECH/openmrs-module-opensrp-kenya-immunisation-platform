package org.openmrs.module.kenyaimmunisationplatform.util;

import org.json.JSONObject;
import org.openmrs.Location;

import java.util.Calendar;

public class KipUtil {
	
	public static JSONObject createLocationJson(Location l) {
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("id", l.getId());
		jsonObject.put("name", l.getName());
		
		return jsonObject;
	}
	
	public static String getCodedYears() {
		int year = Calendar.getInstance().get(Calendar.YEAR);
		StringBuilder sb = new StringBuilder();
		
		for (int i = year; i >= 2015; i--) {
			sb.append(String.valueOf(i).concat(":").concat(String.valueOf(i)).concat(","));
		}
		
		String codedYears = sb.toString();
		codedYears = codedYears.substring(0, codedYears.lastIndexOf(","));
		
		return codedYears;
	}
	
	public static String getCodedMonths() {
		StringBuilder sb = new StringBuilder();
		sb.append(String.valueOf(1).concat(":").concat("January").concat(","));
		sb.append(String.valueOf(2).concat(":").concat("February").concat(","));
		sb.append(String.valueOf(3).concat(":").concat("March").concat(","));
		sb.append(String.valueOf(4).concat(":").concat("April").concat(","));
		sb.append(String.valueOf(5).concat(":").concat("May").concat(","));
		sb.append(String.valueOf(6).concat(":").concat("June").concat(","));
		sb.append(String.valueOf(7).concat(":").concat("July").concat(","));
		sb.append(String.valueOf(8).concat(":").concat("August").concat(","));
		sb.append(String.valueOf(9).concat(":").concat("September").concat(","));
		sb.append(String.valueOf(10).concat(":").concat("October").concat(","));
		sb.append(String.valueOf(11).concat(":").concat("November").concat(","));
		sb.append(String.valueOf(12).concat(":").concat("December"));
		
		String codedMonths = sb.toString();
		
		return codedMonths;
	}
}
