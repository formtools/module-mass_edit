{include file='modules_header.tpl'}

  <table cellpadding="0" cellspacing="0">
  <tr>
    <td width="45"><img src="images/icon_mass_edit.gif" width="34" height="34" /></td>
    <td class="title">{$L.module_name|upper}</td>
  </tr>
  </table>

  {include file='messages.tpl'}

  <div class="margin_bottom_large">
	  {$L.text_summary}
  </div>

  <form action="{$same_page}" method="post" onsubmit="return rsv.validate(this, rules)">
  
    <table cellspacing="1" cellpadding="0" width="100%" class="list_table">
    <tr>
      <td width="15" class="red" align="center">*</td>
      <td width="280" class="pad_left_small">{$L.phrase_submissions_per_page}</td>
      <td><input type="text" size="5" name="submissions_per_page" value="{$module_settings.submissions_per_page|escape}" /></td>
    </tr>
    <tr>
      <td class="red" align="center">*</td>
      <td class="pad_left_small">{$L.phrase_mass_edit_button_label}</td>
      <td><input type="text" style="width:200px" name="mass_edit_button_label" value="{$module_settings.mass_edit_button_label|escape}" /></td>
    </tr>
    <tr>
      <td class="red" align="center">*</td>
      <td class="pad_left_small">{$L.phrase_mass_edit_button_action}</td>
      <td>
			  <table cellspacing="0" cellpadding="0" width="100%">
				<tr>
				  <td colspan="2">
            <input type="radio" name="default_behaviour" id="db1" value="separate_page" {if $module_settings.default_behaviour == "separate_page"}checked{/if} />
              <label for="db1">{$L.phrase_show_separate_page}</label>
					</td>
				</tr>
				<tr> 
					<td widtg="120"> 							
            <input type="radio" name="default_behaviour" id="db2" value="popup" {if $module_settings.default_behaviour == "popup"}checked{/if} />
              <label for="db2">{$L.phrase_open_in_popup}</label>
					</td>
					<td class="medium_grey">
					  {$LANG.mass_edit.word_width} <input type="text" name="popup_width" size="5" value="{$module_settings.popup_width}" />
						{$LANG.mass_edit.word_height} <input type="text" name="popup_height" size="5" value="{$module_settings.popup_height}" /> 
					</td>
				</tr>
				</table>
      </td>
    </tr>
    <tr>
      <td class="red" align="center">*</td>
      <td class="pad_left_small">{$L.phrase_default_tab_index_dir}</td>
      <td>
        <input type="radio" name="default_tab_index_direction" id="dtid1" value="horizontal" 
				  {if $module_settings.default_tab_index_direction == "horizontal"}checked{/if} />
          <label for="dtid2">{$LANG.word_horizontal}</label><br />
        <input type="radio" name="default_tab_index_direction" id="dtid2" value="vertical"
				  {if $module_settings.default_tab_index_direction == "vertical"}checked{/if} />				
          <label for="dtid2">{$LANG.word_vertical}</label>
      </td>
    </tr>
    <tr>
      <td class="red" align="center">*</td>
      <td class="pad_left_small">{$L.phrase_provide_option_to_switch_tab_index_dir}</td>
      <td>
        <input type="radio" name="tab_index_direction_change" id="tidc1" value="yes" 
  			  {if $module_settings.tab_index_direction_change == "yes"}checked{/if} />
          <label for="tidc1">{$LANG.word_yes}</label><br />
        <input type="radio" name="tab_index_direction_change" id="tidc2" value="no"
  			  {if $module_settings.tab_index_direction_change == "no"}checked{/if} />				
          <label for="tidc2">{$LANG.word_no}</label>
      </td>
    </tr>
    <tr>
      <td class="red" align="center">*</td>
      <td class="pad_left_small">{$L.phrase_edit_submissions_page_title}</td>
      <td><input type="text" style="width:200px" name="edit_submissions_page_title" value="{$module_settings.edit_submissions_page_title|escape}" /></td>
    </tr>
    </table>
    
		<p>
		  <input type="submit" name="update" value="{$LANG.word_update}" />
		</p>

  </form>

{include file='modules_footer.tpl'}