<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
   
    public function up(): void
    {
        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('job_id')->constrained()->onDelete('cascade');
            $table->foreignId('provider_profile_id')->constrained()->onDelete('cascade');
            $table->foreignId('customer_profile_id')->constrained()->onDelete('cascade');
            $table->decimal('rating',2,1)->default(0.0);
            $table->string('comment',512)->nullable();
            $table->timestamps();
            
            // prevent multiple ratings for the same job
            $table->unique(['job_id', 'customer_profile_id']);
        });

        // between 0 and 5
        DB::statement('ALTER TABLE ratings ADD CONSTRAINT ratings_rating_check CHECK (rating >= 0 AND rating <= 5)');
    }

    public function down(): void
    {
        Schema::dropIfExists('ratings');
    }
};
