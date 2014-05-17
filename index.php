<?php

require_once("../../global/library.php");
ft_init_module_page();

$folder = dirname(__FILE__);
require_once("$folder/library.php");

if (isset($_POST["update"]))
  list($g_success, $g_message) = mass_edit_update_settings($_POST);

$module_settings = ft_get_module_settings("", "mass_edit");

// ------------------------------------------------------------------------------------------------

$page_vars = array();
$page_vars["module_settings"] = $module_settings;
$page_vars["head_js"] =<<<EOF
var rules = [];
rules.push("required,submissions_per_page,{$L["validation_no_num_submissions_per_page"]}");
rules.push("required,mass_edit_button_label,{$L["validation_no_mass_edit_button_label"]}");
rules.push("required,default_behaviour,{$L["validation_no_default_behaviour"]}");
rules.push("if:default_behaviour=popup,required,popup_width,{$L["validation_no_popup_width"]}");
rules.push("if:default_behaviour=popup,digits_only,popup_width,{$L["validation_invalid_popup_width"]}");
rules.push("if:default_behaviour=popup,required,popup_height,{$L["validation_no_popup_height"]}");
rules.push("if:default_behaviour=popup,digits_only,popup_height,{$L["validation_invalid_popup_height"]}");
rules.push("required,default_tab_index_direction,{$L["validation_no_default_tab_index_dir"]}");
rules.push("required,tab_index_direction_change,{$L["validation_no_change_tab_index_dir_option"]}");
rules.push("required,edit_submissions_page_title,{$L["validation_no_edit_submissions_page_title"]}");
EOF;

ft_display_module_page("templates/index.tpl", $page_vars);
