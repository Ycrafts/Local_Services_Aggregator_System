<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

use Illuminate\Database\Eloquent\Factories\HasFactory;

class Job extends Model
{
    use HasFactory;

    protected $fillable = [
    'customer_profile_id',
    'job_type_id',
    'title',
    'description',
    'proposed_price',  
    'status'
    ];

    public function jobType()
    {
        return $this->belongsTo(JobType::class);
    }

    public function interestedProviders()
    {
        return $this->belongsToMany(ProviderProfile::class, 'provider_profile_job')
                    ->withPivot('is_interested', 'is_selected')
                    ->withTimestamps();
    }

    public function assignedProvider()
    {
        return $this->belongsTo(ProviderProfile::class, 'assigned_provider_id');
    }

    public function rating()
    {
        return $this->hasMany(Rating::class);
    }

    public function customerProfile()
    {
        return $this->belongsTo(CustomerProfile::class);
    }
}
