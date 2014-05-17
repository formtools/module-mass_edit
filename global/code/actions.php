<?php

/**
 * actions.php
 *
 * This is included to securely handle the Ajax delete file functions. The core's action.php file contains a delete
 * submission file option but it's designed specifically for an individual submission - namely, the submission being
 * currently viewed. This has the same functionality - deleting a file - but it checks permissions in a different way.
 */

// -------------------------------------------------------------------------------------------------

$folder = dirname(__FILE__);
require_once("$folder/../../../../global/session_start.php");
ft_check_permission("client");


// the action to take and the ID of the page where it will be displayed (allows for
// multiple calls on same page to load content in unique areas)
$request = array_merge($_GET, $_POST);
$action  = $request["action"];

// Find out if we need to return anything back with the response. This mechanism allows us to pass any information
// between the Ajax submit function and the Ajax return function. Usage:
//   "return_vals[]=question1:answer1&return_vals[]=question2:answer2&..."
$return_val_str = "";
if (isset($request["return_vals"]))
{
  $vals = array();
  foreach ($request["return_vals"] as $pair)
  {
    list($key, $value) = split(":", $pair);
    $vals[] = "$key: \"$value\"";
  }
  $return_val_str = ", " . join(", ", $vals);
}


switch ($action)
{
  case "delete_submission_file":
    $form_id       = $_SESSION["ft"]["curr_form_id"];
    $submission_id = $request["submission_id"];
    $field_id      = $request["field_id"];
    $force_delete  = ($request["force_delete"] == "true") ? true : false;

    if (empty($form_id) || empty($submission_id))
    {
      echo "{ success: false, message: \"{$LANG["notify_invalid_session_values_re_login"]}\" } ";
      exit;
    }

    list($success, $message) = ft_delete_file_submission($form_id, $submission_id, $field_id, $force_delete);
    $success = ($success) ? 1 : 0;
    $message = ft_sanitize($message);
    echo "{ success: $success, message: \"$message\"{$return_val_str} }";
    break;
}
