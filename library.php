<?php


function mass_edit_update_settings($info)
{
  global $g_table_prefix, $L;

	$settings = array(
	  "submissions_per_page"        => $info["submissions_per_page"],
	  "default_behaviour"           => $info["default_behaviour"],
	  "popup_height"                => $info["popup_height"],
    "popup_width"                 => $info["popup_width"],
	  "default_tab_index_direction" => $info["default_tab_index_direction"],
	  "tab_index_direction_change"  => $info["tab_index_direction_change"],
	  "mass_edit_button_label"      => $info["mass_edit_button_label"],
	  "edit_submissions_page_title" => $info["edit_submissions_page_title"]
	);

	ft_set_module_settings($settings);

	return array(true, $L["notify_settings_updated"]);
}


function mass_edit_display_button($location, $template_vars)
{
  global $g_table_prefix, $g_root_dir, $g_root_url;

  if (!ft_check_module_enabled("mass_edit"))
	  return;

	$settings = ft_get_module_settings("", "mass_edit");
	$width  = $settings["popup_width"];
	$height = $settings["popup_height"];

	$smarty = new Smarty();
	$smarty->template_dir  = "$g_root_dir/modules/mass_edit/templates/";
	$smarty->compile_dir   = "$g_root_dir/themes/default/cache/";

	$smarty->assign("button_label", $settings["mass_edit_button_label"]);

  if ($settings["default_behaviour"] == "separate_page")
	{
    $edit_url = "window.location='{$g_root_url}/modules/mass_edit/edit.php'";
    $smarty->assign("mass_edit_link", $edit_url);
	}
  else
	{
    $edit_url = "window.open('{$g_root_url}/modules/mass_edit/fullscreen.php', 'mass_edit_popup', 'width={$width},height={$height},scrollbars=1')";
    $smarty->assign("mass_edit_link", $edit_url);
	}

	$output = $smarty->fetch("$g_root_dir/modules/mass_edit/templates/submission_page_button.tpl");

	echo $output;
}


/**
 * Called from the mass edit page. This actually does the work of updating the submissions
 * listed on the page.
 */
function mass_edit_update_submission_data($form_id, $infohash)
{
  global $g_table_prefix, $g_multi_val_delimiter, $LANG, $L;

	$infohash = ft_sanitize($infohash);

	// get the submission IDs and the field IDs on the page
  $submission_ids = split(",", $infohash["submission_ids"]);
  $field_ids      = $infohash["field_ids"];

  $form_fields = ft_get_form_fields($form_id);
  $db_column_names = array();

  $now = ft_get_current_datetime();

	// keeps track of which submissions were successfully update and which were not [basic!]
	$submissions_updated = array();
	$submissions_not_updated = array();


	// now loop through each submission and update each row individually
	foreach ($submission_ids as $submission_id)
	{
	  if (empty($submission_id) || !is_numeric($submission_id))
		  continue;

    $query = array();
    $query[] = "last_modified_date = '$now'";

    $file_fields = array();
    $submission_date_changed = false;

	  // now loop through all form fields in this form and update those fields in this particular page
    foreach ($form_fields as $row)
    {
      // if the field ID isn't on the page, ignore it
      if (!in_array($row["field_id"], $field_ids))
        continue;

      // if the field ID isn't editable, the person's being BAD and trying to hack a field value. Ignore it.
      if (!in_array($row["field_id"], $infohash["editable_field_ids"]))
        continue;

      // if this is a file, keep track of the IDs. These will be used to upload the files (if need be)
      if ($row["field_type"] == "file")
        $file_fields[] = array("field_id" => $row['field_id'], "col_name" => $row['col_name'], "field_type" => "file");
      else
      {
        // if this is the Submission Date or Last Modified Date fields, check that the information the user has
        // supplied is a valid MySQL datetime. If it's invalid or empty, we DON'T update the value
        if ($row["col_name"] == "submission_date" || $row["col_name"] == "last_modified_date")
        {
          if (!isset($infohash[$row["col_name"]]) || empty($infohash[$row["col_name"]]) || !ft_is_valid_datetime($infohash[$row["col_name"]]))
            continue;

          $submission_date_changed = true;
        }

        if (isset($infohash[$row["col_name"] . "_" . $submission_id]))
        {
          if (is_array($infohash[$row["col_name"] . "_" . $submission_id]))
            $query[] = $row["col_name"] . " = '" . join("$g_multi_val_delimiter", $infohash[$row["col_name"] . "_" . $submission_id]) . "'";
          else
            $query[] = $row["col_name"] . " = '" . $infohash[$row["col_name"] . "_" . $submission_id] . "'";
        }
        else
          $query[] = $row["col_name"] . " = ''";
      }
    }

    $set_query = join(",\n", $query);

    $set_query_str = "
      UPDATE {$g_table_prefix}form_{$form_id}
      SET    $set_query
      WHERE  submission_id = $submission_id
             ";

    $result = mysql_query($set_query_str);

    // now update any files for this submission
    if (!empty($file_fields))
    {
      $problem_files = array();

      while (list($form_field_name, $fileinfo) = each($_FILES))
      {
        // if nothing was included in this field, just ignore it
        if (empty($fileinfo['name']))
          continue;

      	foreach ($submission_ids as $submission_id)
      	{
      	  if (empty($submission_id) || !is_numeric($submission_id))
      		  continue;

          foreach ($file_fields as $field_info)
          {
            $field_id   = $field_info["field_id"];
            $col_name   = $field_info["col_name"];
            $field_type = $field_info["field_type"];

            if ("{$col_name}_{$submission_id}" == $form_field_name)
            {
              if ($field_type == "file")
              {
                list($success2, $message2) = ft_upload_submission_file($form_id, $submission_id, $field_id, $fileinfo);
                if (!$success2)
                  $problem_files[] = array($fileinfo['name'], $message2);
              }
            }
          }
				}
      }
/*
      if (!empty($problem_files))
      {
        $message = $LANG["notify_submission_updated_file_problems"] . "<br /><br />";
        foreach ($problem_files as $problem)
          $message .= "&bull; <b>{$problem[0]}</b>: $problem[1]<br />\n";

        return array(false, $message);
      }
*/
    }

    if ($result)
      $submissions_updated[] = $submission_id;
		else
		  $submissions_not_updated[] = $submission_id;


		// send any emails for this submission
    ft_send_emails("on_edit", $form_id, $submission_id);
  }

  // if the submission date changed on any of the submissions just updated, update sessions in case one of them
	// was the FIRST submission (this updates the search date dropdown)
  if ($submission_date_changed)
    _ft_cache_form_stats($form_id);

  if (empty($submissions_not_updated))
	{
    $success = true;
		$num_submissions_updated = count($submissions_updated);

		if ($num_submissions_updated == 1)
	    $message = $L["notify_form_submission_updated"];
		else
		{
      $placeholders = array("num_submissions" => $num_submissions_updated);
		  $message = ft_eval_smarty_string($L["notify_form_submissions_updated"], $placeholders);
    }
	}
  else
	{
	  $success = false;
    $message = $L["notify_form_submissions_not_updated"];
	}

  return array($success, $message);
}


/**
 * Our installation function. Note that two of the strings are hardcoded rather than pulled in from the lang file. It looks
 * like $L isn't made available to this function by the Core. Need to remedy!
 */
function mass_edit__install($module_id)
{
  global $g_table_prefix;

	$queries = array();
  $queries[] = "INSERT INTO {$g_table_prefix}settings (setting_name, setting_value, module) VALUES ('submissions_per_page', '10', 'mass_edit')";
  $queries[] = "INSERT INTO {$g_table_prefix}settings (setting_name, setting_value, module) VALUES ('default_behaviour', 'separate_page', 'mass_edit')";
  $queries[] = "INSERT INTO {$g_table_prefix}settings (setting_name, setting_value, module) VALUES ('default_tab_index_direction', 'horizontal', 'mass_edit')";
  $queries[] = "INSERT INTO {$g_table_prefix}settings (setting_name, setting_value, module) VALUES ('tab_index_direction_change', 'yes', 'mass_edit')";
  $queries[] = "INSERT INTO {$g_table_prefix}settings (setting_name, setting_value, module) VALUES ('mass_edit_button_label', 'Mass Edit', 'mass_edit')";
  $queries[] = "INSERT INTO {$g_table_prefix}settings (setting_name, setting_value, module) VALUES ('edit_submissions_page_title', 'Edit Submissions', 'mass_edit')";
  $queries[] = "INSERT INTO {$g_table_prefix}settings (setting_name, setting_value, module) VALUES ('popup_height', '600', 'mass_edit')";
  $queries[] = "INSERT INTO {$g_table_prefix}settings (setting_name, setting_value, module) VALUES ('popup_width', '800', 'mass_edit')";

	$has_problem = false;
	foreach ($queries as $query)
  {
  	$result = @mysql_query($query);
	  if (!$result)
	  {
	    $has_problem = true;
	    break;
	  }
  }

  ft_register_hook("template", "mass_edit", "client_submission_listings_buttons3", "", "mass_edit_display_button");
  ft_register_hook("template", "mass_edit", "admin_submission_listings_buttons3", "", "mass_edit_display_button");

	return array(true, "");
}


/**
 * The uninstallation script for the module.
 *
 * @return array [0] T/F, [1] success message
 */
function mass_edit__uninstall($module_id)
{
	global $g_table_prefix;

  mysql_query("DELETE FROM {$g_table_prefix}settings WHERE module = 'mass_edit'");

	return array(true, "");
}
