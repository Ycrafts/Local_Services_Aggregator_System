<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('provider_profile_job', function (Blueprint $table) {
            $table->id();
            $table->foreignId('job_id')->constrained()->onDelete('cascade');
            $table->foreignId('provider_profile_id')->constrained()->onDelete('cascade');
            $table->boolean('is_interested')->default(false);
            $table->boolean('is_selected')->default(false);
            $table->timestamps();

            // prevent duplicate job-provider combinations
            $table->unique(['job_id', 'provider_profile_id']);
        });

        // is_selected can only be true if is_interested is true
        DB::statement('ALTER TABLE provider_profile_job ADD CONSTRAINT provider_profile_job_selection_check CHECK ((is_selected = true AND is_interested = true) OR is_selected = false)');
    }

    public function down(): void
    {
        Schema::dropIfExists('provider_profile_job');
    }
};
