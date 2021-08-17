<?php

/**
 * @file
 */

$databases = [
  "default" => [
    "default" => [
      "database" => $_ENV['MYSQL_DATABASE'],
      "username" => $_ENV['MYSQL_USER'],
      "password" => $_ENV['MYSQL_PASSWORD'],
      "host" => "database",
      "port" => "3306",
      "driver" => "mysql",
      "prefix" => "",
    ],
  ],
];

$settings["file_temp_path"] = '/tmp';
$settings['config_sync_directory'] = __DIR__ . '/files/configs';
$settings['file_private_path'] = __DIR__ . '/files/private';
$settings['trusted_host_patterns'] = [];
$settings["hash_salt"] = 'fkldgkdfjgkldjsfg';

