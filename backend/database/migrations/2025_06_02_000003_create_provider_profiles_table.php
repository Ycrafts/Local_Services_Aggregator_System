<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('provider_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignUuid('user_id')->constrained('users', 'id')->onDelete('cascade');
            $table->decimal('rating',2,1)->default(0.0);
            $table->string('bio',512)->nullable();
            $table->string('address',512);
            $table->timestamps();
        });

        // between 0 and 5
        DB::statement('ALTER TABLE provider_profiles ADD CONSTRAINT provider_profiles_rating_check CHECK (rating >= 0 AND rating <= 5)');
    }

    public function down(): void
    {
        Schema::dropIfExists('provider_profiles');
    }
}; 