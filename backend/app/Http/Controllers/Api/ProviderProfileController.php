<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProviderProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProviderProfileController extends Controller
{
    public function show()
    {
        $user = Auth::user();
        $profile = ProviderProfile::where('user_id', $user->id)
            ->with(['user' => function($query) {
                $query->select('id', 'first_name', 'last_name', 'phone_number', 'email', 'role');
            }])
            ->with('jobTypes')
            ->first();

        if (!$profile) {
            return response()->json(['message' => 'Profile not found'], 404);
        }

        $profileData = [
            'bio' => $profile->bio,
            'address' => $profile->address,
            'rating' => $profile->rating,
            'created_at' => $profile->created_at,
            'updated_at' => $profile->updated_at,
            'user' => [
                'first_name' => $profile->user->first_name,
                'last_name' => $profile->user->last_name,
                'phone_number' => $profile->user->phone_number,
                'email' => $profile->user->email,
                'role' => $profile->user->role
            ],
            'job_types' => $profile->jobTypes->map(function($jobType) {
                return [
                    'id' => $jobType->id,
                    'name' => $jobType->name,
                    'baseline_price' => $jobType->baseline_price
                ];
            })
        ];

        return response()->json([
            'profile' => $profileData
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'bio' => 'nullable|string|max:512',
            'address' => 'required|string|max:512',
            'job_type_ids' => 'required|array',
            'job_type_ids.*' => 'exists:job_types,id'
        ]);

        if ($request->user()->providerProfile) {
            return response()->json([
                'message' => 'You already have a provider profile.'
            ], 400);
        }

        if ($request->user()->role !== 'provider') {
            return response()->json([
                'message' => 'Only providers can create provider profiles.'
            ], 403);
        }

        $profile = ProviderProfile::create([
            'user_id' => $request->user()->id,
            'bio' => $validated['bio'],
            'address' => $validated['address'],
            'rating' => 0
        ]);

        $profile->jobTypes()->attach($validated['job_type_ids']);

        return response()->json([
            'message' => 'Provider profile created successfully',
            'profile' => $profile->load(['first_name,last_name,phone_number,email,role', 'jobTypes'])
        ], 201);
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'bio' => 'nullable|string|max:512',
            'address' => 'required|string|max:512',
            'job_type_ids' => 'nullable|array',
            'job_type_ids.*' => 'exists:job_types,id'
        ]);

        $profile = $request->user()->providerProfile;

        if (!$profile) {
            return response()->json([
                'message' => 'No provider profile found.',
            ], 404);
        }

        $profile->update([
            'bio' => $validated['bio'],
            'address' => $validated['address']
        ]);

        if ($request->has('job_type_ids')) {
            $profile->jobTypes()->sync($validated['job_type_ids']);
        }

        $profile->load(['user:id,first_name,last_name,phone_number,email,role', 'jobTypes']);
        
        // Hide IDs and pivot data
        $profile->makeHidden(['id', 'user_id']);
        $profile->user->makeHidden('id');
        
        // Transform job types to remove IDs and pivot
        $profile->job_types = $profile->jobTypes->map(function($jobType) {
            return [
                'name' => $jobType->name,
                'baseline_price' => $jobType->baseline_price
            ];
        });

        return response()->json([
            'message' => 'Profile updated successfully',
            'profile' => $profile
        ]);
    }
}
