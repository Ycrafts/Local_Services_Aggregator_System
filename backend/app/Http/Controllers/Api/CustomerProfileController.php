<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CustomerProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth; 

class CustomerProfileController extends Controller
{
    public function show()
    {
        $user = Auth::user(); 
        $profile = CustomerProfile::where('user_id', $user->id)
            ->with(['user' => function($query) {
                $query->select('id', 'first_name', 'last_name', 'phone_number', 'email', 'role');
            }])
            ->first();

        if (!$profile) {
            return response()->json(['message' => 'Profile not found'], 404);
        }

        $profileData = [
            'address' => $profile->address,
            'additional_info' => $profile->additional_info,
            'created_at' => $profile->created_at,
            'updated_at' => $profile->updated_at,
            'user' => [
                'first_name' => $profile->user->first_name,
                'last_name' => $profile->user->last_name,
                'phone_number' => $profile->user->phone_number,
                'email' => $profile->user->email,
                'role' => $profile->user->role
            ]
        ];

        return response()->json([
            'profile' => $profileData
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'address' => 'required|max:512',
            'additional_info' => 'nullable|max:512',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = Auth::user(); 

        if (CustomerProfile::where('user_id', $user->id)->exists()) {
            return response()->json(['message' => 'Profile already exists'], 400);
        }

        $profile = CustomerProfile::create([
            'user_id' => $user->id,
            'address' => $request->address,
            'additional_info' => $request->additional_info,
        ]);

        return response()->json([
            'message' => 'Profile created successfully',
            'profile' => $profile->load(['user:id,first_name,last_name,phone_number,email,role'])
                ->makeHidden(['id', 'user_id'])
                ->setRelation('user', $profile->user->makeHidden(['id'])),
        ], 201);
    }

    public function update(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'address' => 'required|max:512',
            'additional_info' => 'nullable|max:512',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = Auth::user();
        $profile = CustomerProfile::where('user_id', $user->id)->first();

        if (!$profile) {
            return response()->json(['message' => 'Profile not found'], 404);
        }

        $profile->update([
            'address' => $request->address,
            'additional_info' => $request->additional_info,
        ]);

        return response()->json([
            'message' => 'Profile updated successfully',
            'profile' => $profile->load(['user:id,first_name,last_name,phone_number,email,role'])
                ->makeHidden(['id', 'user_id'])
                ->setRelation('user', $profile->user->makeHidden(['id'])),
        ]);
    }
}