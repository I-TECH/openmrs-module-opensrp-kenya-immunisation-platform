package org.openmrs.module.kenyaimmunisationplatform.api.dao;

import org.openmrs.module.kenyaimmunisationplatform.Item;

public interface KenyaImmunisationPlatformDao {
	
	Item getItemByUuid(String uuid);
	
	Item saveItem(Item item);
}
