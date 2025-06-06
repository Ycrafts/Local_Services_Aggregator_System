<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProviderProfileJob extends Model
{
    use HasFactory;

    protected $table = 'provider_profile_job';

    protected $fillable = [
        'job_id',
        'provider_profile_id',
        'is_interested',
        'is_selected',
    ];

    protected $casts = [
        'is_interested' => 'boolean',
        'is_selected' => 'boolean'
    ];

    protected $unique = [
        ['job_id', 'provider_profile_id']
    ];

    public function providerProfile()
    {
        return $this->belongsTo(ProviderProfile::class, 'provider_profile_id');
    }

    public function job()
    {
        return $this->belongsTo(Job::class);
    }
}
