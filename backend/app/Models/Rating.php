<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    use HasFactory;

    protected $fillable = [
        'job_id',
        'provider_profile_id',
        'customer_profile_id',
        'rating',
        'comment',
    ];

    protected $casts = [
        'rating' => 'decimal:1'
    ];

    protected $unique = [
        ['job_id', 'customer_profile_id']
    ];

    public function job()
    {
        return $this->belongsTo(Job::class);
    }

    public function providerProfile()
    {
        return $this->belongsTo(ProviderProfile::class);
    }

    public function customerProfile()
    {
        return $this->belongsTo(CustomerProfile::class, 'customer_profile_id');
    }
}
