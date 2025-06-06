<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('job_id')->constrained()->onDelete('cascade');
            $table->foreignUuid('user_id')->constrained('users', 'id')->onDelete('cascade');
            $table->enum('type',['new_job','job_selected','status_changed','provider_interested','provider_assigned'])->index();
            $table->string('message',128);
            $table->boolean('is_read')->index()->default(false);
            $table->timestamps();
        });
    }
   
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
