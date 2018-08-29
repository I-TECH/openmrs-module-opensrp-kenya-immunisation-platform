package org.openmrs.module.kenyaimmunisationplatform.reporting.reports;

import org.openmrs.Location;
import org.openmrs.module.kenyaimmunisationplatform.util.KipUtil;
import org.openmrs.module.reporting.dataset.definition.SqlDataSetDefinition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.module.reporting.report.ReportDesign;
import org.openmrs.module.reporting.report.ReportRequest;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.reporting.report.manager.ReportManager;
import org.openmrs.module.reporting.report.manager.ReportManagerUtil;
import org.openmrs.module.reporting.report.util.ReportUtil;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

/**
 * @author amos.laboso
 */

@Component
public class Moh710Report implements ReportManager {
	
	public static final String EXCEL_REPORT_DESIGN_UUID = "f9001282-a3e9-11e8-906a-080027b84a73";
	
	public static final String EXCEL_REPORT_RESOURCE_NAME = "moh-710.xls";
	
	@Override
	public String getUuid() {
		return "013f986f-a3ea-11e8-906a-080027b84a73";
	}
	
	@Override
	public String getName() {
		return "MOH 710 Report";
	}
	
	@Override
	public String getDescription() {
		return "MOH 710";
	}
	
	@Override
	public List<Parameter> getParameters() {
		
		Parameter year = new Parameter("year", "Year", String.class);
		year.addToWidgetConfiguration("codedOptions", KipUtil.getCodedYears());
		
		Parameter month = new Parameter("month", "Month", String.class);
		month.addToWidgetConfiguration("codedOptions", KipUtil.getCodedMonths());
		
		Parameter county = new Parameter("county", "County", Location.class);
		county.setRequired(false);
		
		Parameter subCounty = new Parameter("subCounty", "Sub County", Location.class);
		subCounty.setRequired(false);
		
		Parameter ward = new Parameter("ward", "Ward", Location.class);
		ward.setRequired(false);
		
		Parameter healthFacility = new Parameter("healthFacility", "Health Facility", Location.class);
		healthFacility.setRequired(false);
		
		return Arrays.asList(year, month, county, subCounty, ward, healthFacility);
	}
	
	@Override
	public ReportDefinition constructReportDefinition() {
		ReportDefinition reportDefinition = new ReportDefinition();
		reportDefinition.setUuid(getUuid());
		reportDefinition.setName(getName());
		reportDefinition.setDescription(getDescription());
		reportDefinition.setParameters(getParameters());
		
		SqlDataSetDefinition sqlDataSetDefinition = new SqlDataSetDefinition();
		sqlDataSetDefinition.addParameters(getParameters());
		
		StringBuilder sb = new StringBuilder();
		sb.append("SELECT sum(bcg_lt_1) as bcg_lt_1, sum(bcg_gt_1) as bcg_gt_1, sum(opv_0) as opv_0, "
		        + "sum(opv_1_lt_1) as opv_1_lt_1, sum(opv_1_gt_1) as opv_1_gt_1, sum(opv_2_lt_1) as opv_2_lt_1, "
		        + "sum(opv_2_gt_1) as opv_2_gt_1, sum(opv_3_lt_1) as opv_3_lt_1, sum(opv_3_gt_1) as opv_3_gt_1, "
		        + "sum(ipv_lt_1) as ipv_lt_1, sum(ipv_gt_1) as ipv_gt_1, sum(penta_1_lt_1) as penta_1_lt_1, "
		        + "sum(penta_1_gt_1) as penta_1_gt_1, sum(penta_2_lt_1) as penta_2_lt_1, sum(penta_2_gt_1) as penta_2_gt_1, "
		        + "sum(penta_3_lt_1) as penta_3_lt_1, sum(penta_3_gt_1) as penta_3_gt_1, sum(pcv_1_lt_1) as pcv_1_lt_1, "
		        + "sum(pcv_1_gt_1) as pcv_1_gt_1, sum(pcv_2_lt_1) as pcv_2_lt_1, sum(pcv_2_gt_1) as pcv_2_gt_1, "
		        + "sum(pcv_3_lt_1) as pcv_3_lt_1, sum(pcv_3_gt_1) as pcv_3_gt_1, sum(rota_1_lt_1) as rota_1_lt_1, "
		        + "sum(rota_2_lt_1) as rota_2_lt_1, sum(vit_at_6) as vit_at_6, sum(yf_lt_1) as yf_lt_1, sum(yf_gt_1) as yf_gt_1, "
		        + "sum(mr_1_lt_1) as mr_1_lt_1, sum(mr_1_gt_1) as mr_1_gt_1, sum(fic) as fic, sum(vit_1) as vit_1, "
		        + "sum(vit_1_half) as vit_1_half, sum(mr_2_1_half_2) as mr_2_1_half_2, sum(mr_2_gt_2) as mr_2_gt_2, "
		        + "sum(vit_2_to_5) as vit_2_to_5 FROM openmrs_etl.etl_moh_710 t WHERE t.year=:year and t.month=:month "
		        + "AND CASE WHEN :healthFacility IS NOT NULL THEN t.health_facility_id=:healthFacility "
		        + "WHEN :ward IS NOT NULL THEN t.ward_id=:ward WHEN :subCounty IS NOT NULL THEN t.sub_county_id=:subCounty "
		        + "WHEN :county IS NOT NULL THEN t.county_id=:county END "
		        + "GROUP BY CASE WHEN :healthFacility IS NOT NULL THEN t.health_facility_id WHEN :ward IS NOT NULL THEN t.ward_id "
		        + "WHEN :subCounty IS NOT NULL THEN t.sub_county_id WHEN :county IS NOT NULL THEN t.county_id END");
		
		sqlDataSetDefinition.setSqlQuery(sb.toString());
		reportDefinition.addDataSetDefinition("dataset", Mapped.mapStraightThrough(sqlDataSetDefinition));
		
		return reportDefinition;
	}
	
	@Override
	public List<ReportDesign> constructReportDesigns(ReportDefinition reportDefinition) {
		String resourcePath = ReportUtil.getPackageAsPath(getClass()) + "/" + EXCEL_REPORT_RESOURCE_NAME;
		
		ReportDesign design = ReportManagerUtil.createExcelTemplateDesign(EXCEL_REPORT_DESIGN_UUID, reportDefinition,
		    resourcePath);
		
		return Arrays.asList(design);
	}
	
	@Override
	public List<ReportRequest> constructScheduledRequests(ReportDefinition reportDefinition) {
		return null;
	}
	
	@Override
	public String getVersion() {
		return "1.0-SNAPSHOT";
	}
	
}
