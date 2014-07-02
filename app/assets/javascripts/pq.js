
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

            //get value from select list in current form
            var newVal = $(this).children('select').val();
            $(this).data('current',newVal);
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

            //get value from select list in current form
            var newVal = $(this).children('select').val();
            $(this).data('current',newVal);
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
        var prevMinId = $(this).parents('form').data('current') || "";
        console.log('control=',$(this).attr('id'),',data(current)=', prevMinId, ', changed to=',$(this).val(), ',equals change=', $(this).val()!=prevMinId)
        if($(this).val()!=prevMinId) {
            $(this).siblings('input[type="submit"]').val("Update Minister").show();
        }
        else
        {
            $(this).siblings('input[type="submit"]').val("Update Minister").hide();
        }

    });


    $('body')
        .on('click', '.trim-links-header', function () {
            console.log($(this));
            $(this).children('.trim-links-form').show();
        })
        .on('click', '.trim-links-cancel', function (e) {
            e.stopPropagation();
            var $par = $(this).parent('.trim-links-form').first().hide();
        })
        .on('change', '.file-chooser', function () {
            var fileName = $(this).val();
            if (fileName.length > 0) {
                $(this).siblings('input:submit').show();
                $(this).prev('.file-choose-replace').text('Selected');
            } else {
                $(this).siblings('input:submit').hide();
                $(this).prev('.file-choose-replace').text('Choose file');
            }
        })
        .on('click', '.file-choose-replace', function () {
            $(this).next('.file-chooser').click();
        })
        .on('ajax:success', '.form-add-trim-link', function(e, data, status, xhr) {
            console.log('ajax:success');
            //get the pq_id
            var pqid = $(this).data('pqid');
            console.log('pqid',pqid);
            //get the div to replace
            var $divToFill = $('#trim_area_' + pqid);
            //put the data returned into the div
            $divToFill.html(data);
        })
        .on('ajax:error', '.form-add-trim-link', function(e, xhr, status, error) {
            console.log('ajax:fail');
            //get the pq_id
            var pqid = $(this).data('pqid');
            console.log('pqid',pqid);
            //get the div to replace
            var $divToFill = $('#trim_area_' + pqid);
            //put the data returned into the div
            console.log('set html of', $divToFill.attr('id'), 'to', xhr.responseText);
            $divToFill.html(xhr.responseText);
        });

});  
