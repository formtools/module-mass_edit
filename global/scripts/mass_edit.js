/**
 * Our Mass Edit namespace.
 */
var me = {};


/**
 * Deletes a submission file or image.
 *
 * @param field_id
 * @param force_delete
 */
me.delete_submission_file = function(field_id, submission_id)
{
	var page_url = g.root_url + "/modules/mass_edit/global/code/actions.php?action=delete_submission_file&field_id=" + field_id
		+ "&submission_id=" + submission_id
		+ "&return_vals[]=target_message_id:file_field_" + field_id + "_message_id_" + submission_id
		+ "&return_vals[]=field_id:" + field_id
		+ "&return_vals[]=submission_id:" + submission_id
		+ "&force_delete=" + true;

  new Ajax.Request(page_url, {
    method: 'get',
    onSuccess: me.delete_submission_file_response,
    onFailure: function() { alert("Couldn't load page: " + page_url); }
  });
}


/**
 * Handles the successful responses for the delete file feature. Whether or not the file was *actually*
 * deleted is a separate matter. If the file couldn't be delete, the user is provided the option of deleting
 * the database record anyway.
 */
me.delete_submission_file_response = function(transport)
{
  var info = transport.responseText.evalJSON();

  // if it was a success, remove the link from the page
  if (info.success == 1)
  {
    var field_id      = info.field_id;
    var submission_id = info.submission_id;

    $("field_" + field_id + "_link_" + submission_id).innerHTML = "";
    $("field_" + field_id + "_upload_field_" + submission_id).show();
  }

  ft.display_message(info.target_message_id, info.success, info.message);
}

