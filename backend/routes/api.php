<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\JobController;
use App\Http\Controllers\Api\JobTypeController;
use App\Http\Controllers\Api\ProviderProfileController;
use App\Http\Controllers\Api\NotificationsController;
use App\Http\Controllers\Api\CustomerProfileController;

// Public Routes
Route::post('auth/register', [AuthController::class, 'register']);
Route::post('auth/login', [AuthController::class, 'login']);
Route::get('job-types', [JobTypeController::class, 'index']);

// Protected Routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('auth/logout', [AuthController::class, 'logout']);

    // Jobs
    Route::prefix('jobs')->group(function () {
        Route::get('/', [JobController::class, 'index']);
        Route::post('/', [JobController::class, 'store']);
        Route::get('/{job}', [JobController::class, 'show']);
        Route::post('/{jobId}/express-interest', [JobController::class, 'expressInterest']);
        Route::get('/{job}/interested-providers', [JobController::class, 'interestedProviders']);
        Route::post('/{job}/select-provider', [JobController::class, 'selectProvider']);
        Route::post('/{jobId}/cancel', [JobController::class, 'cancel']);
        Route::post('/{job}/rate-provider', [JobController::class, 'rateProvider']);
        Route::post('/{job}/provider-done', [JobController::class, 'providerMarkDone']);
        Route::post('/{job}/complete', [JobController::class, 'customerConfirmComplete']);
    });

    // Provider Profile
    Route::prefix('provider-profile')->group(function () {
        Route::get('/', [ProviderProfileController::class, 'show']);
        Route::post('/', [ProviderProfileController::class, 'store']);
        Route::put('/', [ProviderProfileController::class, 'update']);
    });

    // Customer Profile
    Route::prefix('customer-profile')->group(function () {
        Route::get('/', [CustomerProfileController::class, 'show']);
        Route::post('/', [CustomerProfileController::class, 'store']);
        Route::put('/', [CustomerProfileController::class, 'update']);
    });

    // Notifications
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationsController::class, 'index']);
        Route::post('/{id}/read', [NotificationsController::class, 'markAsRead']);
    });

    // Provider Jobs
    Route::get('/requested-jobs', [JobController::class, 'providerRequestedJobs']);
    Route::get('/selected-jobs', [JobController::class, 'providerSelectedJobs']);
});