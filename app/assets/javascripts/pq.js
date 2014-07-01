
$(document).ready(function () {
	$('.datetimepicker').datetimepicker();
	$(".multi-select-action-officers").select2({width:'250px'});

    $(".single-select-dropdown").select2({width:'250px', allowClear: true});

    $('#allocation_response_response_action_accept').click(function (){
		$('#reason-textarea').addClass('hide');
	});
	$('#allocation_response_response_action_reject').click(function (){
		$('#reason-textarea').removeClass('hide');
	});
	$(".form-commission")
	.on("ajax:success", function(e, data, status, xhr){
		var pqid = $(this).data('pqid');
		$('#commission'+pqid).click();
		//get the div to refresh
		var divToFill = "question_allocation_" + $(this).data('pqid');
		//put the dat returned into the div
		$('#'+divToFill).html(data);
		//clear select list
		$('#action_officers_pq_action_officer_id-'+pqid).select2('data', null);
	}).on("ajax:error", function(e, xhr, status, error) {
		alert('fail');
		//TODO how should ux handle error? Add it to the list, alert, flash, etc...

	});



    $('#search_member').bind('ajax:before', function() {
        $(this).data('params', { name: $("#minister_name").val() });
    });

    $('#search_member').bind('ajax:success', function(e, data, status, xhr){
        $( "#members_result" ).replaceWith(data);
        $("#members_result_select").select2({width:'250px'});
        $('#members_result_select_link').bind('ajax:before', function() {
            m_id = $("#members_result_select").val();
            m_name = $("#members_result_select option:selected").data('name');
            $("#minister_member_id").val(m_id);
            $("#minister_name").val(m_name);
            return false;
        });
    });

    $('.answer-pq-link').on('ajax:success', function(e, data, status, xhr){
        var pq_id = $(this).data('id');
        var divToFill = "#answer-pq-" + pq_id;
        $( divToFill ).html(data);
    });

    $(".policy-minister-form")
        .on("ajax:success", function(e, data, status, xhr){

            var pqid = $(this).data('pqid');

            //get the div to refresh
            var divToUpdate = "btn-policy-minister" + pqid;
            //put the dat returned into the div
            $('#'+divToUpdate).val("Updated").fadeOut(1000);

        }).on("ajax:error", function(e, xhr, status, error) {
            alert(error);
            //TODO how should ux handle error? Add it to the list, alert, flash, etc...

        });

    $(".answering-minister-form")
        .on("ajax:success", function(e, data, status, xhr){

            var pqid = $(this).data('pqid');

            //get the div to refresh

            var divToUpdate = "btn-answering-minister" + pqid;
            //put the dat returned into the div
            $('#'+divToUpdate).val("Updated").fadeOut(1000);

        }).on("ajax:error", function(e, xhr, status, error) {
            alert(error + ' In Answering Minister');
            //TODO how should ux handle error? Add it to the list, alert, flash, etc...

        });


    $('.change-policy-minister').on('change',function(e ){
        e.stopPropagation();
        if($(this).val()!='') {
            $(this).siblings('input[type="submit"]').val("Update Minister").show();
        }
        else
        {
            $(this).siblings('input[type="submit"]').val("Update Minister").hide();
        }

    });

});  
