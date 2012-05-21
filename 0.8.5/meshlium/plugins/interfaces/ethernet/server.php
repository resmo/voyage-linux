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
include_once $API_core.'json_api.php';
include_once $API_core.'save_interfaces.php';
include_once $API_core.'form_fields_check.php';

if (($_POST['type']=="save")||($_POST['type']=="save_restart"))
{
    $post_data=jsondecode($_POST['form_fields']);
    if($post_data['iface_sel']=='static')
    {
        $fields_check_types = Array (
            'address'  => Array ('ms_ip','ms_mandatory'),
            'netmask'  => Array ('ms_ip','ms_mandatory'),
            'gateway'  => Array ('ms_ip','ms_mandatory'),
            'DNS1'  => Array ('ms_ip'),
            'DNS2'  => Array ('ms_ip'),
            'broadcast'  => Array ('ms_ip')
            );
    }
    else
    {
        $fields_check_types = Array ();
    }
    if(are_form_fields_valid ($post_data, $fields_check_types))
    {
        //$input=saveInterfaces('eth0',$post_data,"/etc/network/interfaces",$base_dir."data");
        $input=saveInterfaces('eth0',$post_data,"/etc/network/interfaces","/etc/network/interfaces");
        //exec('sudo cp '.$base_plugin."data/interfaces /etc/network/interfaces");
        //response_additem("return", '<pre>'.print_r($post_data,true).print_r($input,true).'</pre>');
        if ($_POST['type']=="save_restart")
        {
            exec('sudo ifdown eth0; sudo ifup eth0');
        }
        response_additem("script", 'alert("Data saved")');
    }
    response_return();
}
?>