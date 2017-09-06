package org.openmrs.module.kenyaimmunisationplatform.reporting.reports;

import org.openmrs.Location;
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
import java.util.Date;
import java.util.List;

@Component
public class Moh510Report implements ReportManager{

    public static final String EXCEL_REPORT_DESIGN_UUID = "5e1596c8-8bee-11e7-a7dd-080027b84a73";
    public static final String EXCEL_REPORT_RESOURCE_NAME = "moh-510-permanent-register.xlsx";

    @Override
    public String getUuid() {
        return "17f4664f-8be7-11e7-a7dd-080027b84a73";
    }

    @Override
    public String getName() {
        return "MOH 510 Report";
    }

    @Override
    public String getDescription() {
        return "MOH 510 - Permanent Register";
    }

    @Override
    public List<Parameter> getParameters() {
        return Arrays.asList(
                new Parameter("startDate", "Start Date", Date.class),
                new Parameter("endDate", "End Date", Date.class),
                new Parameter("county", "County", Location.class),
                new Parameter("subCounty", "Sub County", Location.class),
                new Parameter("ward", "Ward", Location.class),
                new Parameter("healthFacility", "Health Facility", Location.class)
        );
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
        sb.append("SELECT d.kip_id, d.permanent_register_number, d.cwc_number, " +
                " concat(d.given_name, ' ', d.middle_name, ' ', d.family_name) as name," +
                " d.gender, d.dob, i.bcg_vx_date, i.opv_0_vx_date, i.opv_1_vx_date, i.pcv_1_vx_date, " +
                " i.penta_1_vx_date, i.rota_1_vx_date, i.opv_2_vx_date, i.pcv_2_vx_date, i.penta_2_vx_date, " +
                " i.rota_2_vx_date, i.opv_3_vx_date, i.pcv_3_vx_date, i.penta_3_vx_date, i.ipv_vx_date, " +
                " i.mr_1_vx_date, i.mr_2_vx_date, i.mr_at_6_vx_date, i.yf_vx_date, i.vit_at_6_vx_date" +
                " from openmrs_etl.etl_patient_demographics d left join openmrs_etl.etl_immunisations i " +
                " on d.patient_id = i.patient_id");

        sqlDataSetDefinition.setSqlQuery(sb.toString());
        reportDefinition.addDataSetDefinition("dataset", Mapped.mapStraightThrough(sqlDataSetDefinition));

        return reportDefinition;
    }

    @Override
    public List<ReportDesign> constructReportDesigns(ReportDefinition reportDefinition) {
        String resourcePath = ReportUtil.getPackageAsPath(getClass()) + "/" + EXCEL_REPORT_RESOURCE_NAME;
        return Arrays.asList(
                ReportManagerUtil.createExcelTemplateDesign(EXCEL_REPORT_DESIGN_UUID, reportDefinition, resourcePath)
        );
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
