
$(function() {
    $('select[name="userEnteredParams[county]"]').css("width","100%").empty();
    KIP.getAllCounties('select[name="userEnteredParams[county]"]');

    $('input.userEnteredParamyear,input.userEnteredParammonth').hide();
    $('input.userEnteredParamyear,input.userEnteredParammonth').css('display', 'None');
    $('select[name="userEnteredParams[subCounty]"]').attr("disabled", true).css("width","100%").empty();
    $('select[name="userEnteredParams[ward]"]').attr("disabled", true).css("width","100%").empty();
    $('select[name="userEnteredParams[healthFacility]"]').attr("disabled", true).css("width","100%").empty();

    $('select[name="userEnteredParams[county]"]').change(function () {
        KIP.getChildLocationsAndEnableCombo($(this).val(), "userEnteredParams[subCounty]");
    });

    $('select[name="userEnteredParams[subCounty]"]').change(function () {
        KIP.getChildLocationsAndEnableCombo($(this).val(), "userEnteredParams[ward]");
    });

    $('select[name="userEnteredParams[ward]"]').change(function () {
        KIP.getChildLocationsAndEnableCombo($(this).val(), "userEnteredParams[healthFacility]");
    });

});

var KIP = {
    getChildLocationsAndEnableCombo: function (locationId, updateCombo) {
        //Call controller fetch locations and update child combo
        $.ajax({
            url: "/openmrs/module/kenyaimmunisationplatform/location.htm",
            type: "get",
            data: {locationId: locationId},
            dataType: 'json'
        }).done(function (data, textStatus, jqXHR) {
            $('select[name="'+updateCombo+'"]').empty();
            $('select[name="'+updateCombo+'"]').append($('<option></option>'));
            data = data.data;
            $.each(data, function(idx, it) {
                $('select[name="'+updateCombo+'"]').append($('<option></option>').attr('value', it.id).text(it.name));
            });
        }).fail(function (jqXHR, textStatus, errorThrown) {
            console.log(textStatus);
            console.log(errorThrown);
        }).always(function () {
            $('select[name="'+updateCombo+'"]').removeAttr("disabled");
        });
    },
    getAllCounties: function (updateCombo) {
        //Call controller fetch locations and update child combo
        $.ajax({
            url: "/openmrs/module/kenyaimmunisationplatform/counties.htm",
            type: "get",
            dataType: 'json'
        }).done(function (data, textStatus, jqXHR) {
            $(updateCombo).empty();
            $(updateCombo).append($('<option></option>'));
            data = data.data;
            $.each(data, function(idx, it) {
                $(updateCombo).append($('<option></option>').attr('value', it.id).text(it.name));
            });
        }).fail(function (jqXHR, textStatus, errorThrown) {
            console.log(textStatus);
            console.log(errorThrown);
        }).always(function () {
            $(updateCombo).removeAttr("disabled");
        });
    },

};
