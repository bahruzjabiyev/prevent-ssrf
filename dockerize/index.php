<?php
  
    $url = $_GET['url'];
    if (strpos($url, "/")) {
        $options = array(
            CURLOPT_RETURNTRANSFER => true,   // return web page
            CURLOPT_HEADER         => false,  // don't return headers
            CURLOPT_FOLLOWLOCATION => true,   // follow redirects
            CURLOPT_MAXREDIRS      => 10,     // stop after 10 redirects
            CURLOPT_ENCODING       => "",     // handle compressed
            CURLOPT_USERAGENT      => "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0", // name of client
            CURLOPT_AUTOREFERER    => true,   // set referrer on redirect
            CURLOPT_CONNECTTIMEOUT => 10,    // time-out on connect
            CURLOPT_TIMEOUT        => 10,    // time-out on response
        );

        $ch = curl_init($url);
        curl_setopt_array($ch, $options);
        $content  = curl_exec($ch);
		$content_type = "text/html";
		if (!curl_errno($ch)) {
			$content_type = curl_getinfo($ch,  CURLINFO_CONTENT_TYPE);
		}
        curl_close($ch);

		header("Content-Type: " . $content_type);
        echo $content;
    } else {
        echo "not a valid url!";
    }

?>

