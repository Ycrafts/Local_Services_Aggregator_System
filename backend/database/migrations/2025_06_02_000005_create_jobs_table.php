<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jobs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_profile_id')->constrained()->onDelete('cascade');
            $table->foreignId('job_type_id')->constrained()->onDelete('restrict');
            $table->string('title',128);
            $table->string('description',1024);
            $table->decimal('proposed_price', 10, 2);
            $table->enum('status', ['open', 'in_progress', 'completed', 'cancelled'])->index()->default('open');
            $table->foreignId('assigned_provider_id')->nullable()->constrained('provider_profiles')->onDelete('set null');
            $table->timestamp('provider_marked_done_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jobs');
    }
}; 