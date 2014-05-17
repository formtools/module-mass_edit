{include file='header.tpl'}

  {if $account.account_type == "admin"}
  	<div style="float:right; padding-left: 6px;">
  		<a href="../../admin/forms/edit.php?form_id={$form_id}"><img src="{$images_url}/edit_small.gif" border="0" alt="{$LANG.phrase_edit_form}"
  			title="{$LANG.phrase_edit_form}" /></a>
  	</div>
  {/if}

  <div class="title">{$module_settings.edit_submissions_page_title|upper}</div>

  {if $module_settings.tab_index_direction_change == "yes"}
		<div style="float:right">
			{$LANG.mass_edit.phrase_tab_direction_c}
			<input type="radio" name="tab_direction" id="td1" value="horizontal" onchange="TI.setTabIndexDir(this.value)"
				{if $module_settings.default_tab_index_direction == "horizontal"}checked{/if} />
				<label for="td1">{$LANG.word_horizontal}</label>
			<input type="radio" name="tab_direction" id="td2" value="vertical" onchange="TI.setTabIndexDir(this.value)"
				{if $module_settings.default_tab_index_direction == "vertical"}checked{/if} />
				<label for="td2">{$LANG.word_vertical}</label>
		</div>
  {/if}

  <div><a href="{$back_link}">{$LANG.mass_edit.phrase_search_results}</a></div>

	<div style="clear:both">
    {include file="messages.tpl"}
  </div>

	{* always show an option to open in full screen *}
	<div style="float:right">
    <a href="#" onclick="window.open('fullscreen.php', 'fullscreen', 'width={$module_settings.popup_width},height={$module_settings.popup_height},scrollbars=1'); return false"><img src="images/icon_fullscreen.gif" border="0" title="{$LANG.mass_edit.phrase_full_screen_view}" /></a>
	</div>

  {$pagination}

  <form action="{$same_page}" id="mass_edit_form" method="post" enctype="multipart/form-data">

    <div style="overflow-x: scroll; overflow-y: hidden; margin-top: 14px; border: 1px solid #999999; width: 740px;">

  		<table cellspacing="1" cellpadding="1" class="list_table" id="mass_edit_table">
        {foreach from=$display_fields key=k item=i}
          <th>{$i.field_title}</th>
        {/foreach}
      </tr>

      {assign var='submission_ids' value=''}
      {foreach from=$search_rows key=k item=search_row}
        {assign var=submission_id value=$search_row.submission_id}
        {assign var=submission_ids value="$submission_ids,`$submission_id`"}

        <tr>
          {* for each search row, loop through the display fields and display the appropriate content for the submission field *}
          {foreach from=$display_fields key=k2 item=curr_field}
            <td nowrap valign="top">
            {assign var=field_id value=$curr_field.field_id}
            {assign var=field_type value=$curr_field.field_info.field_type}
            {assign var=col_name value=$curr_field.col_name}
            {assign var=val value=$search_row.$col_name}
						{assign var=is_editable value=$curr_field.view_info.is_editable}

            {* select and radio buttons show the appropriate display value *}
            {if $field_type == "select"}
              {submission_dropdown name="`$col_name`_`$submission_id`" field_id=$field_id selected=$val is_editable=$is_editable}
            {elseif $field_type == "radio-buttons"}
              {submission_radios name="`$col_name`_`$submission_id`" field_id=$field_id selected=$val is_editable=$is_editable}
            {elseif $field_type == "checkboxes"}
              {submission_checkboxes name="`$col_name`_`$submission_id`" field_id=$field_id selected=$val is_editable=$is_editable}
            {elseif $field_type == "multi-select"}
              {submission_dropdown_multiple name="`$col_name`_`$submission_id`" field_id=$field_id selected=$val is_editable=$is_editable}
            {elseif $field_type == "wysiwyg"}

              {if $is_editable == "yes"}
                <textarea name="{$col_name}_{$submission_id}" id="field_{$field_id}_wysiwyg_{$submission_id}" style="width: 100%; height: 160px">{$val}</textarea>
              {else}
                {$val}
              {/if}

            {elseif $field_type == "password"}

              {if $is_editable == "yes"}
                <input type="password" name="{$col_name}_{$submission_id}" value="{$val|escape}" style="width: 150px;" />
              {/if}

            {elseif $field_type == "file"}

              <span id="field_{$field_id}_link_{$submission_id}" {if $val == ""}style="display:none"{/if}>
                {display_file_field field_id=$field_id filename=$val}
                {if $is_editable == "yes"}
                  <input type="button" class="pad_left_large" value="{$LANG.phrase_delete_file|upper}"
									  onclick="me.delete_submission_file({$field_id}, {$submission_id})" />
                {/if}
              </span>
              <span id="field_{$field_id}_upload_field_{$submission_id}" {if $val != ""}style="display:none"{/if}>
                {if $is_editable == "yes"}
                  <input type="file" name="{$col_name}_{$submission_id}" />
                {/if}
              </span>
              <span id="file_field_{$field_id}_message_id_{$submission_id}"></span>

            {elseif $field_type == "system"}

              {if $col_name == "submission_id"}
                <span class="medium_grey">{$submission_id}</span>
              {elseif $col_name == "submission_date"}

                {if $is_editable == "yes"}
                  <table cellspacing="0" cellpadding="0">
                  <tr>
                    <td><input type="text" style="width: 110px;" name="{$col_name}_{$submission_id}" id="{$col_name}_{$submission_id}" value="{$val}" /></td>
                    <td><img src="{$theme_url}/images/calendar_icon.gif" id="date_image_{$col_name}_{$submission_id}" style="cursor:pointer" /></td>
                  </tr>
                  </table>
                  <script type="text/javascript">
                  {literal}Calendar.setup({{/literal}
                     inputField     :    "{$col_name}_{$submission_id}",
                     showsTime      :    true,
                     timeFormat     :    "24",
                     ifFormat       :    "%Y-%m-%d %H:%M:00",
                     button         :    "date_image_{$col_name}_{$submission_id}",
                     align          :    "tr",
                     singleClick    :    true
                  {literal}});{/literal}
                  </script>
                {else}
                  {$val|custom_format_date:$SESSION.account.timezone_offset:$SESSION.account.date_format}
                {/if}

              {elseif $col_name == "last_modified_date"}
                {$search_row.last_modified_date|custom_format_date:$SESSION.settings.timezone_offset:$SESSION.account.date_format}
              {elseif $col_name == "ip_address"}

                {if $is_editable == "yes"}
                  <input type="text" style="width: 100px;" name="{$col_name}_{$submission_id}" value="{$val}" />
                {else}
                  {$val}
                {/if}
              {/if}

              {elseif $field_type == "textbox"}
                <input type="text" name="{$col_name}_{$submission_id}" value="{$val|escape}" />
              {elseif $field_type == "textarea"}
                <textarea name="{$col_name}_{$submission_id}" style="width:200px; height: 60px">{$val|escape}</textarea>
              {/if}
            </td>
          {/foreach}
        </tr>
      {/foreach}
  		</table>
    </div>

		<input type="hidden" name="submission_ids" value="{$submission_ids}" />

		<p>
	    <input type="submit" name="mass_update" value="{$LANG.word_update}" />
		</p>

  </form>

{include file='modules_footer.tpl'}