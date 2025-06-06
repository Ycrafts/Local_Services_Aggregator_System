<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Job;
use App\Models\ProviderProfileJob;
use App\Models\ProviderProfile;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule; 
use Illuminate\Support\Facades\Log;

use Illuminate\Support\Facades\Auth;
use App\Services\JobStatusService;
use App\Services\RequestedJobStatusService;
use App\Models\Notification;

class JobController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'job_type_id'     => 'required|exists:job_types,id',
            'description'     => 'required|string',
            'proposed_price'  => 'required|numeric|min:1',
            'title'           => 'required|string'
        ]);

        if ($request->user()->role !== 'customer') {
            return response()->json(['error' => 'Only customers can post jobs.'], 403);
        }
        
        $job = Job::create([
            'customer_profile_id' => $request->user()->customerProfile->id,
            'job_type_id'    => $validated['job_type_id'],
            'description'    => $validated['description'],
            'title'          => $validated['title'],
            'proposed_price' => $validated['proposed_price'],
            'status'         => 'open',
        ]);

        $matchedProviders = ProviderProfile::whereHas('jobTypes', function ($query) use ($job) {
            $query->where('job_type_id', $job->job_type_id);
        })->get();
    
        foreach ($matchedProviders as $provider) {
            ProviderProfileJob::create([
                'job_id' => $job->id,
                'provider_profile_id' => $provider->id,
                'status' => 'pending'
            ]);
            Notification::create([
                'user_id' => $provider->user_id,
                'job_id' => $job->id,
                'type' => 'new_job',
                'message' => 'A new job matching your skills has been posted.',
            ]);
        }
    
        return response()->json([
            'message' => 'Job posted successfully.',
            'job'     => $job
        ], 201);

    }

    public function index(Request $request)
    {
        $customerProfile = $request->user()->customerProfile;
        
        if (!$customerProfile) {
            return response()->json(['message' => 'Customer profile not found.'], 404);
        }

        $jobs = Job::with(['jobType', 'customerProfile.user'])
            ->where('customer_profile_id', $customerProfile->id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->each(function ($job) {
                $job->makeHidden(['customer_profile_id']);
                if ($job->customerProfile) {
                    $job->customerProfile->makeHidden(['user_id']);
                    if ($job->customerProfile->user) {
                        $job->customerProfile->user->makeHidden(['id']);
                    }
                }
            });

        return response()->json([
            'data' => $jobs
        ]);
    }
    
    public function show(Request $request, $id)
    {
        $customerProfile = $request->user()->customerProfile;
        
        if (!$customerProfile) {
            return response()->json(['message' => 'Customer profile not found.'], 404);
        }

        $job = Job::with(['jobType', 'customerProfile.user', 'assignedProvider.user'])
            ->where('id', $id)
            ->where('customer_profile_id', $customerProfile->id)
            ->first();

        if (!$job) {
            return response()->json(['message' => 'Job not found or not authorized.'], 404);
        }

        $job->makeHidden(['customer_profile_id']);
        if ($job->customerProfile) {
            $job->customerProfile->makeHidden(['user_id']);
            if ($job->customerProfile->user) {
                $job->customerProfile->user->makeHidden(['id']);
            }
        }
        if ($job->assignedProvider && $job->assignedProvider->user) {
            $job->assignedProvider->user->makeHidden(['id']);
        }

        return response()->json($job);
    }
    public function expressInterest(Request $request, $jobId)
    {
        $providerProfile = $request->user()->providerProfile;

        if (!$providerProfile) {
            return response()->json(['message' => 'Provider profile not found.'], 404);
        }

        $providerProfileJob = ProviderProfileJob::where('job_id', $jobId)
            ->where('provider_profile_id', $providerProfile->id)
            ->first();

        if (!$providerProfileJob) {
            return response()->json(['message' => 'Job not found or not assigned to this provider.'], 404);
        }

        $providerProfileJob->is_interested = true;
        $providerProfileJob->save();

        $job = $providerProfileJob->job;
        if ($job && $job->customerProfile) {
            Notification::create([
                'user_id' => $job->customerProfile->user_id,
                'job_id' => $job->id,
                'type' => 'provider_interested',
                'message' => 'A provider has expressed interest in your job.',
            ]);
        }

        return response()->json(['message' => 'Interest expressed successfully.']);
    }

    public function interestedProviders(Request $request, $jobId)
    {
        $job = Job::findOrFail($jobId);
        $customerProfile = $request->user()->customerProfile;

        if (!$customerProfile) {
            return response()->json(['message' => 'Customer profile not found.'], 404);
        }

        if ($customerProfile->id !== $job->customer_profile_id) {
            return response()->json(['message' => 'Unauthorized: You are not the job owner.'], 403);
        }

        $interestedProviders = ProviderProfileJob::with('providerProfile.user')
            ->where('job_id', $job->id)
            ->where('is_interested', true)
            ->get()
            ->each(function ($providerJob) {
                $providerJob->makeHidden(['job_id', 'provider_profile_id']);
                if ($providerJob->providerProfile) {
                    $providerJob->providerProfile->makeHidden(['user_id']);
                    if ($providerJob->providerProfile->user) {
                        $providerJob->providerProfile->user->makeHidden(['id']);
                    }
                }
            });

        return response()->json($interestedProviders);
    }

    public function selectProvider(Request $request, $jobId)
    {
        $job = Job::findOrFail($jobId);
        $customerProfile = $request->user()->customerProfile;

        if (!$customerProfile) {
            return response()->json(['message' => 'Customer profile not found.'], 404);
        }

        if ($customerProfile->id !== $job->customer_profile_id) {
            return response()->json(['message' => 'Unauthorized: You are not the job owner.'], 403);
        }

        $validated = $request->validate([
            'provider_profile_id' => [
                'required',
                'exists:provider_profiles,id',
                Rule::exists('provider_profile_job', 'provider_profile_id')
                    ->where('job_id', $job->id)
                    ->where('is_interested', true),
            ],
        ]);

        $providerProfileId = $validated['provider_profile_id'];
        $profile = ProviderProfile::find($providerProfileId);
        
        if (!$profile) {
            return response()->json(['message' => 'Provider profile not found.'], 404);
        }

        //  provider_profile_job record
        ProviderProfileJob::where('job_id', $job->id)
            ->where('provider_profile_id', $providerProfileId)
            ->update(['is_selected' => true]);

        // job status
        $job->assigned_provider_id = $providerProfileId;
        $job->status = 'in_progress';
        $job->save();

        Notification::create([
            'user_id' => $profile->user_id,
            'job_id' => $job->id,
            'type' => 'job_selected',
            'message' => 'You have been selected for a job!',
        ]);

        Notification::create([
            'user_id' => $job->customerProfile->user_id,
            'job_id' => $job->id,
            'type' => 'provider_assigned',
            'message' => 'A provider has been assigned to your job.',
        ]);

        $job->makeHidden(['customer_profile_id']);
        if ($job->customerProfile) {
            $job->customerProfile->makeHidden(['user_id']);
            if ($job->customerProfile->user) {
                $job->customerProfile->user->makeHidden(['id']);
            }
        }
        if ($job->assignedProvider) {
            $job->assignedProvider->makeHidden(['user_id']);
            if ($job->assignedProvider->user) {
                $job->assignedProvider->user->makeHidden(['id']);
            }
        }

        return response()->json([
            'message' => 'Provider selected successfully.',
            'job' => $job
        ]);
    }

    public function providerRequestedJobs(Request $request)
    {
        $providerProfile = ProviderProfile::where('user_id', Auth::id())->first();

        if (!$providerProfile) {
            return response()->json(['message' => 'Provider profile not found.'], 404);
        }

        $jobs = ProviderProfileJob::where('provider_profile_id', $providerProfile->id)
            ->whereHas('job', function ($query) {
                $query->where('status', 'open');
            })
            ->with(['job.jobType', 'job.customerProfile.user'])
            ->paginate(10)
            ->each(function ($providerJob) {
                $providerJob->makeHidden(['job_id', 'provider_profile_id']);
                if ($providerJob->job) {
                    $providerJob->job->makeHidden(['customer_profile_id']);
                    if ($providerJob->job->customerProfile) {
                        $providerJob->job->customerProfile->makeHidden(['user_id']);
                        if ($providerJob->job->customerProfile->user) {
                            $providerJob->job->customerProfile->user->makeHidden(['id']);
                        }
                    }
                }
            });

        return response()->json($jobs);
    }

    public function providerSelectedJobs(Request $request)
    {
        $providerProfile = ProviderProfile::where('user_id', Auth::id())->first();

        if (!$providerProfile) {
            return response()->json(['message' => 'Provider profile not found.'], 404);
        }

        $jobs = ProviderProfileJob::where('provider_profile_id', $providerProfile->id)
            ->where('is_selected', true)
            ->with(['job.jobType', 'job.customerProfile.user'])
            ->paginate(10)
            ->each(function ($providerJob) {
                $providerJob->makeHidden(['job_id', 'provider_profile_id']);
                if ($providerJob->job) {
                    $providerJob->job->makeHidden(['customer_profile_id']);
                    if ($providerJob->job->customerProfile) {
                        $providerJob->job->customerProfile->makeHidden(['user_id']);
                        if ($providerJob->job->customerProfile->user) {
                            $providerJob->job->customerProfile->user->makeHidden(['id']);
                        }
                    }
                }
            });

        return response()->json($jobs);
    }

    public function providerMarkDone(Request $request, $jobId)
    {
        $user = $request->user();
        $job = Job::with('customerProfile')->findOrFail($jobId);

        if ($user->role !== 'provider' || !$job->assigned_provider_id || $job->assigned_provider_id != $user->providerProfile->id) {
            return response()->json(['message' => 'Only the assigned provider can mark this job as done.'], 403);
        }

        if ($job->status !== 'in_progress') {
            return response()->json(['message' => 'Job must be in progress to be marked as done.'], 400);
        }

        $job->provider_marked_done_at = now();
        $job->status = 'provider_done';
        $job->save();

        Notification::create([
            'user_id' => $job->customerProfile->user_id,
            'job_id' => $job->id,
            'type' => 'status_changed',
            'message' => 'Provider has marked the job as done. Please confirm completion.',
        ]);

        return response()->json(['message' => 'Job marked as done. Awaiting customer confirmation.']);
    }

    public function customerConfirmComplete(Request $request, $jobId)
    {
        $user = $request->user();
        $job = Job::with('customerProfile')->findOrFail($jobId);

        if ($user->role !== 'customer' || $user->customerProfile->id !== $job->customer_profile_id) {
            return response()->json(['message' => 'Only the customer can confirm completion.'], 403);
        }

        if ($job->status !== 'provider_done') {
            return response()->json(['message' => 'Provider has not marked this job as done yet.'], 400);
        }

        //  already completed
        if ($job->status === 'completed') {
            return response()->json(['message' => 'Job is already completed.'], 400);
        }

        $job->status = 'completed';
        $job->save();

        Notification::create([
            'user_id' => $job->assignedProvider->user_id,
            'job_id' => $job->id,
            'type' => 'status_changed',
            'message' => 'Customer has confirmed job completion.',
        ]);

        return response()->json(['message' => 'Job marked as completed.']);
    }

    public function rateProvider(Request $request, $jobId)
    {
        $user = $request->user();
        $job = Job::with(['customerProfile', 'assignedProvider'])->findOrFail($jobId);

        if ($user->role !== 'customer' || !$user->customerProfile || $user->customerProfile->id !== $job->customer_profile_id) {
            return response()->json(['message' => 'Only the customer who owns this job can rate the provider.'], 403);
        }

        if ($job->status !== 'completed') {
            return response()->json(['message' => 'You can only rate after the job is completed.'], 400);
        }

        if (!$job->assigned_provider_id) {
            return response()->json(['message' => 'No provider assigned to this job.'], 400);
        }

        $existing = \App\Models\Rating::where('job_id', $job->id)
            ->where('customer_profile_id', $user->customerProfile->id)
            ->first();
        if ($existing) {
            return response()->json(['message' => 'You have already rated this provider for this job.'], 400);
        }

        $validated = $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        $rating = \App\Models\Rating::create([
            'job_id' => $job->id,
            'provider_profile_id' => $job->assigned_provider_id,
            'customer_profile_id' => $user->customerProfile->id,
            'rating' => $validated['rating'],
            'comment' => $validated['comment'] ?? null,
        ]);

        $provider = $job->assignedProvider;
        $avg = \App\Models\Rating::where('provider_profile_id', $provider->id)->avg('rating');
        $provider->rating = $avg;
        $provider->save();

        $rating->makeHidden(['job_id', 'provider_profile_id', 'customer_profile_id']);
        if ($rating->provider) {
            $rating->provider->makeHidden(['user_id']);
            if ($rating->provider->user) {
                $rating->provider->user->makeHidden(['id']);
            }
        }

        return response()->json([
            'message' => 'Rating submitted successfully.',
            'rating' => $rating
        ], 201);
    }
    
    public function cancel(Request $request, $jobId)
    {
        $job = Job::with(['customerProfile.user', 'assignedProvider.user'])->findOrFail($jobId);
        $customerProfile = $request->user()->customerProfile;

        if (!$customerProfile) {
            return response()->json(['message' => 'Customer profile not found.'], 404);
        }

        if ($customerProfile->id !== $job->customer_profile_id) {
            return response()->json(['message' => 'Unauthorized: You are not the job owner.'], 403);
        }

        if (!in_array($job->status, ['open', 'in_progress'])) {
            return response()->json(['message' => 'Only open or in-progress jobs can be cancelled.'], 400);
        }

        $job->status = 'cancelled';
        $job->save();

        if ($job->assigned_provider_id) {
            Notification::create([
                'user_id' => $job->assignedProvider->user_id,
                'job_id' => $job->id,
                'type' => 'status_changed',
                'message' => 'Job has been cancelled by the customer.',
            ]);
        }

        $job->makeHidden(['customer_profile_id']);
        if ($job->customerProfile) {
            $job->customerProfile->makeHidden(['user_id']);
            if ($job->customerProfile->user) {
                $job->customerProfile->user->makeHidden(['id']);
            }
        }
        if ($job->assignedProvider) {
            $job->assignedProvider->makeHidden(['user_id']);
            if ($job->assignedProvider->user) {
                $job->assignedProvider->user->makeHidden(['id']);
            }
        }

        return response()->json([
            'message' => 'Job cancelled successfully.',
            'job' => $job
        ]);
    }
}

