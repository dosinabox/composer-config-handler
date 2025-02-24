#!/usr/bin/env php

<?php
  #
  # Usage: openssl cast5-cbc -d -in QCONF.cast5 | ./qconf-exporter.php
  #

  while($line = fgets(STDIN)) {
    if (preg_match('/^\s*#/', $line)) {
      continue;
    }

    if (preg_match('/^\s*$/', $line)) {
      continue;
    }

    $exploded_line = explode("\t", trim($line), 2);

    if (empty($exploded_line[0])) {
      continue;
    }

    $variable = $exploded_line[0];
    if (empty($exploded_line[1])) {
      echo escapeshellcmd("unset ${variable}");
    } else {
      $value = $exploded_line[1];
      echo escapeshellcmd("export ${variable}=${value}");
    }
    echo "\n";
  }

