<?php
// server/config/database.php
// La conexión a la base del compose. El host `db` sólo existe dentro de la red del
// compose: desde el host no resuelve. Ver bea-02, "could not translate host name".

return [
    'default' => 'pgsql',

    'connections' => [
        'pgsql' => [
            'driver' => 'pgsql',
            'host' => 'db',
            'port' => 5432,
            'database' => 'certcore',
            'username' => 'postgres',
            'password' => 'certcore',
            'charset' => 'utf8',
            'prefix' => '',
            'schema' => 'public',
        ],
    ],

    'migrations' => 'migrations',
];
