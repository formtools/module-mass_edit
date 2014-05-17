  <input type="button" value="{$button_label}" id="mass_edit_button" disabled
	  onclick="{$mass_edit_link}" />

	{literal}
	<script type="text/javascript">
  Event.observe(window, "load", function() {
    // if there's already one or more submission selected, enable the Mass Edit button
	  if (ms.selected_submission_ids.length || ms.all_submissions_in_result_set_selected)
		{
		  $("mass_edit_button").disabled = false;
		}
		
		// in order to detect whether we should enable/disable the Mass Edit button, piggy-back our own 
		// functionality on the Core's ms.update_display_row_count function
		ms.update_display_row_count = ms.update_display_row_count.wrap(
		  function(original_func)
		  { 
		    var num_selected = original_func(); 
		    $("mass_edit_button").disabled = (num_selected > 0) ? false : true;
		    return num_selected;
		  }
		);		
	});
	</script>
	{/literal}
