<?php

namespace App\Filament\Widgets;

use App\Models\User;
use Filament\Widgets\PieChartWidget;

class UsersRolePieChartWidget extends PieChartWidget
{
    protected static ?string $heading = 'User Roles Proportion';

    protected function getData(): array
    {
        $providerCount = User::where('role', 'provider')->count();
        $customerCount = User::where('role', 'customer')->count();
        $adminCount = User::where('role', 'admin')->count();

        return [
            'datasets' => [
                [
                    'data' => [
                        $providerCount,
                        $customerCount,
                        $adminCount,
                    ],
                    'backgroundColor' => [
                        '#3b82f6', // blue
                        '#10b981', // green 
                        '#f59e42', // orange
                    ],
                ],
            ],
            'labels' => [
                'Providers',
                'Customers',
                'Admins',
            ],
        ];
    }

    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'display' => true,
                    'position' => 'bottom',
                    'labels' => [
                        'font' => [
                            'size' => 16,
                            'weight' => 'bold',
                        ],
                    ],
                ],
                'tooltip' => [
                    'enabled' => true,
                    'backgroundColor' => '#222',
                    'titleColor' => '#fff',
                    'bodyColor' => '#fff',
                ],
            ],
            'animation' => [
                'animateRotate' => true,
                'animateScale' => true,
                'duration' => 1500,
                'easing' => 'easeOutBounce',
            ],
            'cutout' => '40%', 
        ];
    }
} 