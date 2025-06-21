<?php

namespace App\Filament\Widgets;

use App\Models\User;
use App\Models\Job;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Card;

class AnalyticsOverviewWidget extends BaseWidget
{
    protected function getCards(): array
    {
        $totalUsers = User::count();
        $totalProviders = User::where('role', 'provider')->count();
        $totalCustomers = User::where('role', 'customer')->count();
        $totalJobs = Job::count();
        $completedJobs = Job::where('status', 'completed')->count();
        $cancelledJobs = Job::where('status', 'cancelled')->count();
        $providerCustomerRatio = $totalCustomers > 0 ? round($totalProviders / $totalCustomers, 2) : 0;

        return [
            Card::make('Total Users', $totalUsers),
            Card::make('Providers', $totalProviders),
            Card::make('Customers', $totalCustomers),
            Card::make('Provider/Customer Ratio', $providerCustomerRatio),
            Card::make('Total Jobs', $totalJobs),
            Card::make('Completed Jobs', $completedJobs),
            Card::make('Cancelled Jobs', $cancelledJobs),
        ];
    }
} 