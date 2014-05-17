{*
  This page is included in every administration page to generate the start of each the HTML pages, from the
  opening DOCTYPE to the head, and the opening structure of the pages.

  $head_title  - the <title> of the page
  $theme       - the theme folder name
  $logo_link   -
  $head_js     - anything that will be included within <script></script> tags.
  $head_css    - any CSS to be included within <style> tags.
  $nav_page    - the current page, used for the navigation column on the left
  $head_string - anything else to be outputted as is within the <head></head>
  $version     - the program version
*} 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html dir="{$LANG.special_text_direction}">
<head>
  <title>{$head_title}</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <link rel="shortcut icon" href="{$theme_url}/images/favicon.ico" >

  <script type="text/javascript">
  //<![CDATA[
  var g = {literal}{}{/literal};
  g.root_url = "{$g_root_url}";
  g.error_colours = ["ffbfbf", "ffeded"];
  g.notify_colours = ["c6e2ff", "f2f8ff"];
  //]]>
  </script>

  <link type="text/css" rel="stylesheet" href="{$g_root_url}/global/css/main.css">
  <link type="text/css" rel="stylesheet" href="global/css/styles.css">
  <script type="text/javascript" src="{$g_root_url}/global/scripts/prototype.js"></script>
  <script type="text/javascript" src="{$g_root_url}/global/scripts/scriptaculous.js?load=effects"></script>
  <script type="text/javascript" src="{$g_root_url}/global/scripts/effects.js"></script>
  <script type="text/javascript" src="{$g_root_url}/global/scripts/general.js"></script>
  <script type="text/javascript" src="{$g_root_url}/global/scripts/rsv.js"></script>

  {$head_string}
  {$head_js}
  {$head_css}

</head>
<body>

	{* if this was opened in a popup, provide the option of closing it *}
	<div style="float:right">
	  <a href="#" onclick="window.close()"><img src="images/icon_close_fullscreen.gif" border="0" title="{$LANG.mass_edit.phrase_close_window}" /></a>
	</div>

  <div class="title">{$module_settings.edit_submissions_page_title|upper}</div>

	<div style="clear:both">
    {include file="messages.tpl"}
  </div>

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

  {$pagination}

  <form action="{$same_page}" id="mass_edit_form" method="post">

    <div style="margin-top: 14px; width: 100%;">

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
  
</body>
</html>
