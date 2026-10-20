<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    protected $table = 'users';

    // "INS-15", "SUP-02": los mismos `sub` del token.
    public $incrementing = false;
    protected $keyType = 'string';

    public $timestamps = false;

    protected $hidden = ['password_hash'];
}
