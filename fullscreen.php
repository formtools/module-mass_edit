<?php

require_once("../../global/library.php");
ft_init_module_page("client");

$folder = dirname(__FILE__);
require_once("$folder/library.php");

$module_settings = ft_get_module_settings("", "mass_edit");
$page_num = ft_load_module_field("mass_edit", "page", "page", 1);

// build the "<< search results" link (depends on user account type)
if ($_SESSION["ft"]["account"]["account_type"] == "admin")
  $back_link = "../../admin/forms/submissions.php";
else
  $back_link = "../../clients/forms/index.php";

// get the list of selected submissions that we need to show
$form_id = $_SESSION["ft"]["curr_form_id"];
$view_id = $_SESSION["ft"]["form_{$form_id}_view_id"];

// all submissions are selected
$submission_ids = array();
if (!$_SESSION["ft"]["form_{$form_id}_select_all_submissions"])
{
  $submission_ids = $_SESSION["ft"]["form_{$form_id}_selected_submissions"];
}

$results_per_page = $module_settings["submissions_per_page"];
$order            = $_SESSION["ft"]["current_search"]["order"];
$search_fields    = $_SESSION["ft"]["current_search"]["search_fields"];

// get the list of columns to show
$columns = array();
$field_ids = array();
$view_info = ft_get_view($view_id);

foreach ($view_info["fields"] as $field_info)
{
  $columns[]   = $field_info["col_name"];
	$field_ids[] = $field_info["field_id"];
}

if (isset($_POST["mass_update"]))
{
  $infohash = $_POST;

  // get a list of all editable fields in the View. This is used both for security purposes
  // for the update function and to determine whether the page contains any editable fields
  $editable_field_ids = _ft_get_editable_view_fields($view_id);

	// we pass this to the update function to ensure only the fields in the page are updated
	$infohash["field_ids"] = $field_ids;
	$infohash["editable_field_ids"] = $editable_field_ids;
  list($g_success, $g_message) = mass_edit_update_submission_data($form_id, $infohash);
}

$search_results = ft_search_submissions($form_id, $view_id, $results_per_page, $page_num, $order, $columns, $search_fields, $submission_ids);
$num_results = $search_results["search_num_results"];
$display_fields = ft_get_submission_field_info($view_info["fields"], true);
$search_rows = $search_results["search_rows"];

$updated_display_fields = array();
$wysiwyg_field_ids = array();
foreach ($display_fields as $field_info)
{
  $field_id = $field_info["field_id"];
	$field_info["view_info"] = ft_get_view_field($view_id, $field_id);

	if ($field_info["field_info"]["field_type"] == "wysiwyg")
	{
	  foreach ($search_rows as $submission_row_info)
		{
		  $submission_id = $submission_row_info["submission_id"];
	    $wysiwyg_field_ids[] = "field_{$field_id}_wysiwyg_{$submission_id}";
		}
  }
	$updated_display_fields[] = $field_info;
}

$wysiwyg_field_id_list = join(",", $wysiwyg_field_ids);

// ------------------------------------------------------------------------------------------------

$page_vars = array();
$page_vars["form_id"] = $form_id;
$page_vars["module_settings"] = $module_settings;
$page_vars["back_link"] = $back_link;
$page_vars["num_results"] = $num_results;
$page_vars["search_rows"] = $search_rows;
$page_vars["pagination"]  = ft_get_page_nav($num_results, $results_per_page, $page_num, "");
$page_vars["view_info"] = $view_info;
$page_vars["display_fields"] = $updated_display_fields;
$page_vars["head_string"] =<<<EOF
<script type="text/javascript" src="$g_root_url/modules/mass_edit/global/scripts/mass_edit.js"></script>
<script type="text/javascript" src="$g_root_url/modules/mass_edit/global/scripts/prototype.tableindexer.js"></script>
<script type="text/javascript" src="$g_root_url/global/tiny_mce/tiny_mce.js"></script>
<script type="text/javascript" src="$g_root_url/global/scripts/wysiwyg_settings.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="$g_root_url/global/jscalendar/skins/aqua/theme.css" title="Aqua" />
<script type="text/javascript" src="$g_root_url/global/jscalendar/calendar.js"></script>
<script type="text/javascript" src="$g_root_url/global/jscalendar/calendar-setup.js"></script>
<script type="text/javascript" src="$g_root_url/global/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="$g_root_url/global/scripts/lightbox.js"></script>
<link rel="stylesheet" href="$g_root_url/global/css/lightbox.css" type="text/css" media="screen" />
EOF;

$tiny_resize = ($_SESSION["ft"]["settings"]["tinymce_resize"] == "yes") ? "true" : "false";
$content_css = "$g_root_url/global/css/tinymce.css";

$page_vars["head_js"] =<<<EOF

  // load up any WYWISYG editors in the page
  g_content_css = "$content_css";
  editors["{$_SESSION["ft"]["settings"]["tinymce_toolbar"]}"].elements = "$wysiwyg_field_id_list";
  editors["{$_SESSION["ft"]["settings"]["tinymce_toolbar"]}"].theme_advanced_toolbar_location = "{$_SESSION["ft"]["settings"]["tinymce_toolbar_location"]}";
  editors["{$_SESSION["ft"]["settings"]["tinymce_toolbar"]}"].theme_advanced_toolbar_align = "{$_SESSION["ft"]["settings"]["tinymce_toolbar_align"]}";
  editors["{$_SESSION["ft"]["settings"]["tinymce_toolbar"]}"].theme_advanced_path_location = "{$_SESSION["ft"]["settings"]["tinymce_path_info_location"]}";
  editors["{$_SESSION["ft"]["settings"]["tinymce_toolbar"]}"].theme_advanced_resizing = $tiny_resize;
  editors["{$_SESSION["ft"]["settings"]["tinymce_toolbar"]}"].content_css = "$content_css";
  tinyMCE.init(editors["{$_SESSION["ft"]["settings"]["tinymce_toolbar"]}"]);

	var TI;
  Event.observe(window, "load", function() {
    TI = new TableIndexer({
      formId:     "mass_edit_form",
      tableId:    "mass_edit_table",
      defaultDir: "horizontal",
      defaultTabIndex: 3
    });

		// ensure the tab index is correct on page load
		if ($("td1") && $("td1").checked)
		  TI.setTabIndexDir($("td1").value);
		if ($("td2") && $("td2").checked)
		  TI.setTabIndexDir($("td2").value);
  });
EOF;

ft_display_page("../../modules/mass_edit/templates/fullscreen.tpl", $page_vars);