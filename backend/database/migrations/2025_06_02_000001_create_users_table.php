<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('first_name',64);
            $table->string('last_name',64);
            $table->string('phone_number',12)->index();
            $table->string('email',128)->unique()->index();
            $table->timestamp('phone_verified_at')->nullable();
            $table->string('password',256);
            $table->enum('role', ['customer', 'provider', 'admin'])->default('customer');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
}; 