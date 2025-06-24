<?php

namespace App\Providers;

use Illuminate\Support\Facades\DB;
use RuntimeException;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Ensure PostgreSQL is being used
        if (config('database.default') !== 'pgsql' || DB::connection()->getDriverName() !== 'pgsql') {
            throw new RuntimeException(
                'This application requires PostgreSQL. Please check your database configuration.'
            );
        }
    }
}
