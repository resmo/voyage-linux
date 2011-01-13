<?php
/*
 *  Copyright (C) 2008 Libelium Comunicaciones Distribuidas S.L.
 *  http://www.libelium.com
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Version 0.1
 *  Author: Octavio Benedi Sanchez
 */

// Predefined variables:
// $section contains the section folder name.
// echo "section=".$section."<br>";
// $plugin contains the plugin folder name.
// echo "plugin=".$plugin."<br>";
// $section and $plugin can be used to make a link to this plugin by just reference
// echo "<a href=\"index.php?section=$section&plugin=$plugin\">This plugin</a>"."<br>";
// $base_plugin contains the path that must be used as start to includes for
// plugin includes that need the local path.
// example: include_once $base_plugin.'php/my_include.php';
// echo "base_plugin=".$base_plugin."<br>";
// $url_plugin contains the url base that must be used to include html items
// such as images.
// example: <img src="'.url_plugin.'images/my_image.png">
// echo "url_plugin=".$url_plugin."<br>";
// $API_core contains the path to the core API folder.
// example: include_once $API_core.'is_active.php';
// echo "API_core=".$API_core."<br>";

// Plugin server produced data will returned to the ajax call that made the
// request.
include_once $API_core.'complex_ajax_return_functions.php';

if ($_POST['type']=="complex")
{
    // Prepare the response
    // We will launch a javascript function
    response_additem("script", 'alert("This is a javascript call.");');
    // Output some html
    response_additem("return", "<div> This is html code shown in the default output</div>");
    // And more html to a div with an id that we specify.
    response_additem("append", "<div>This is html code shown in a tag with id specified by server.php</div>","direct_assign");
    // Return the response to javascript
    response_return();
}
else
{
    if ($_POST['cmd']=="info")
    {
	exec ('mpc status', $cur_play);
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="play")
    {
	exec ('mpc play', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="pause")
    {
	exec ('mpc pause', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="stop")
    {
	exec ('mpc stop', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="next")
    {
	exec ('mpc next', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="prev")
    {
	exec ('mpc prev', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="repeat")
    {
	exec ('mpc repeat', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="shuffle")
    {
	exec ('mpc shuffle', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="random")
    {
	exec ('mpc random', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="louder")
    {
	exec ('mpc volume +2', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else if ($_POST['cmd']=="softer")
    {
	exec ('mpc volume -2', $cur_play);    
	$html=implode("<br/>",$cur_play);
    }
    else
    {
	$html="<pre>".print_r($_POST,true)."</pre>";
	$html=implode("<br/>",$cur_play);
    }
    echo $html;
}

?>
