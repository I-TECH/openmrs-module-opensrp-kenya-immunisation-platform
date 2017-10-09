package org.openmrs.module.kenyaimmunisationplatform.extension.html;

import org.openmrs.module.web.extension.HeaderIncludeExt;

import java.util.Arrays;
import java.util.List;

public class KipHeaderIncludeExt extends HeaderIncludeExt {
	
	@Override
	public List<String> getHeaderFiles() {
		return Arrays.asList("/scripts/jquery/jquery.min.js", "/moduleResources/kenyaimmunisationplatform/js/omokip.js");
	}
}
