<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProviderProfile extends Model
{
    use HasFactory;

    protected $table = 'provider_profiles';

    protected $fillable = [
        'user_id',
        'rating',
        'bio',
        'address'
    ];

    protected $casts = [
        'rating' => 'decimal:1'
    ];

    public function jobTypes()
    {
        return $this->belongsToMany(JobType::class, 'provider_profile_job_type')
                    ->withTimestamps();
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function assignedJobs()
    {
        return $this->hasMany(Job::class, 'assigned_provider_id');
    }

    public function interestedJobs()
    {
        return $this->belongsToMany(Job::class, 'provider_profile_job')
                    ->withPivot('is_interested', 'is_selected')
                    ->withTimestamps();
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }
}
