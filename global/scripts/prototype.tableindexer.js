/**
 * Table Indexer
 * ~~~~~~~~~~~~~
 *
 * A Prototype extension that changes the tab index for tabulated data between horizontal and
 * vertical. In other words, when the user clicks the "tab" key, the next selected field is
 * either the table cell *beneath* the current selected field or to the *right* of the next
 * selected field.
 *
 * Limitations: doesn't work with colspans and rowspans.
 *
 * @author  Ben Keen, http://www.benjaminkeen.com/software/toggletableindex/
 * @version 1.0.0
 * @date    May 3rd 2009
 */

var TableIndexer = Class.create();

TableIndexer.prototype = {
  options:           {},   // stores all options defined for this TabIndexer

  initialize: function() {
    var options = Object.extend({
      formId:          null,
      tableId:         null,
      defaultDir:      "horizontal",
      numCols:         null,
      defaultTabIndex: 1
    }, arguments[0] || {});

    // if the user didn't specify the number of columns, try to figure it out based on
    // the first row: tot up the td and th's
    if (options.numCols == null)
    {
      var rows = $$("#" + options.tableId + " tbody tr");
      var td_nodes = rows[0].getElementsBySelector("td");
      var th_nodes = rows[0].getElementsBySelector("th");
      options.numCols = td_nodes.length + th_nodes.length;
    }

    this.options = options;
    this.setTabIndexDir(this.options.defaultDir);
  },


  /**
   * Does the job of switching the tab index direction.
   */
  setTabIndexDir: function(dir)
  {
    // this stores the form elements in the form, ordered horizontally or vertically. We apply
    // the tab index to them after determining the order
    var orderedElements = [];

    if (dir == "horizontal")
    {
      var formElements = $(this.options.formId).getElements();

      // only add those form fields within the table
      for (var i=0; i<formElements.length; i++)
      {
        if (formElements[i].descendantOf($(this.options.tableId)))
          orderedElements.push(formElements[i]);
      }
    }

    else if (dir == "vertical")
    {
      // find the number of rows
      var rows    = $$("#" + this.options.tableId + " tr");
      var numRows = rows.length;
      this._currentNodes = [];

      for (var col=1; col<=this.options.numCols; col++)
      {
        for (var row=0; row<numRows; row++)
        {
          // find the row table cell for this column (td or th)
          //var row_els = $$("#" + table_id + " tbody tr td:nth(" + col + ")");
          var nodes = rows[row].getElementsBySelector("td");

          if (!nodes.length)
            continue;

          var node = nodes[col-1];

          // this stores the relevant form field nodes in this._currentNodes
          this._getTableFormFieldNodes(node);
        }
      }
      orderedElements = this._currentNodes;
    }

    var currTabIndex = this.options.defaultTabIndex;
    orderedElements.each(function(el) { el.tabIndex = currTabIndex++; });
  },


  /**
   * Stores all form fields within a particular node in this._currentNodes.
   */
  _getTableFormFieldNodes: function(n)
  {
	  if (typeof n == "undefined")
		  return; 
		
    if (n.form && n.nodeName != "LABEL")
    {
      this._currentNodes.push(n);
      return;
    }

    var children = n.childNodes;
    for (var i=0; i<children.length; i++)
    {
      if (children[i].nodeType != 1)
        continue;

      this._getTableFormFieldNodes(children[i]);
    }
  }
}