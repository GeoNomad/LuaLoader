<?php
echo "the button received\n";

$msg = "\nThe red button was pushed.\n";

require 'PushBullet.class.php'; //https://github.com/PENDOnl/emails-to-pushbullet/blob/master/classes/pushbullet.class.php

$p = new PushBullet('yourOauthToken');
$p->pushNote('yourDeviceToen', 'RED Button', $msg);

mail("youremail@gmail.com","RED Button",$msg,"From: golem@yourserver.com\r\n");
?> 
