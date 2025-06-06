<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;


class AuthController extends Controller
{
    public function register(Request $request)
    {
        $requestData = $request->all();
        $fields = $request->validate([
            'first_name' => 'required|string|max:64',
            'last_name' => 'required|string|max:64',
            'role' => 'required|in:customer,provider,admin',
            'email' => 'required|email|unique:users',
            'phone_number' => [
                'required',
                'unique:users',
                'regex:/^(\+251|0)?9\d{8}$/'
            ],
            'password' => 'required|confirmed|min:8',
        ]);

        // Create user
        $user = User::create([
            'first_name' => $fields['first_name'],
            'last_name' => $fields['last_name'],
            'email' => $fields['email'],
            'phone_number' => $fields['phone_number'],
            'password' => Hash::make($fields['password']),
            'role' => $fields['role']
        ]);
        $response = response()->json([
            'message' => 'Successfully Registered',
            'user' => [
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'email' => $user->email,
                'phone_number' => $user->phone_number,
                'role' => $user->role
            ]
        ], 201);
        return $response;
    }

    public function login(Request $request){
        $request->validate([
            'phone_number' => 'required',
            'password' => 'required'
        ]);

        $user = User::where('phone_number', $request->phone_number)->first();

        if(!$user || !Hash::check($request->password, $user->password)){
            return response()->json([
                'message' => 'Unknown phone number or wrong password',
            ], 403);
        }

        $token = $user->createToken($user->id);

        $response = [
            'token' => $token->plainTextToken,
            'user' => [
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'email' => $user->email,
                'phone_number' => $user->phone_number,
                'role' => $user->role
            ]
        ];

        return response()->json($response);
    }

    public function logout(Request $request){
        $request->user()->tokens()->delete();
        return response()->json([
            'message'=>'You are logged out'
        ],200);
    }
}
