<?php

namespace App\Filament\Widgets;

use App\Models\Job;
use Filament\Widgets\PieChartWidget;

class JobStatusPieChartWidget extends PieChartWidget
{
    protected static ?string $heading = 'Job Statuses Proportion';

    protected function getData(): array
    {
        $open = Job::where('status', 'open')->count();
        $inProgress = Job::where('status', 'in_progress')->count();
        $providerDone = Job::where('status', 'provider_done')->count();
        $completed = Job::where('status', 'completed')->count();
        $cancelled = Job::where('status', 'cancelled')->count();

        $inProgressTotal = $inProgress + $providerDone;

        return [
            'datasets' => [
                [
                    'data' => [
                        $open,
                        $inProgressTotal,
                        $completed,
                        $cancelled,
                    ],
                    'backgroundColor' => [
                        '#3b82f6', 
                        '#f59e42', 
                        '#10b981', 
                        '#ef4444',
                    ],
                ],
            ],
            'labels' => [
                'Open',
                'In Progress',
                'Completed',
                'Cancelled',
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