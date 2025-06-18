<?php

namespace App\Filament\Resources;

use App\Filament\Resources\JobResource\Pages;
use App\Filament\Resources\JobResource\RelationManagers;
use App\Filament\Resources\CustomerProfileResource;
use App\Filament\Resources\ProviderProfileResource;
use App\Models\Job;
use App\Models\JobType;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class JobResource extends Resource
{
    protected static ?string $model = Job::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('customer_profile_id')
                    ->required()
                    ->numeric(),
                Forms\Components\Select::make('job_type_id')->label('Job Type')
                    ->options(JobType::all()->pluck('name', 'id'))
                    ->required(),
                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(128),
                Forms\Components\TextInput::make('description')
                    ->required()
                    ->maxLength(1024),
                Forms\Components\TextInput::make('proposed_price')
                    ->required()
                    ->numeric(),
                Forms\Components\TextInput::make('status')
                    ->required()
                    ->maxLength(255)
                    ->default('open'),
                Forms\Components\TextInput::make('assigned_provider_id')
                    ->numeric(),
                Forms\Components\DateTimePicker::make('provider_marked_done_at'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('customer_profile_id')
                    ->label('Customer')
                    ->formatStateUsing(fn ($record) => $record->customerProfile->user->name ?? "Customer #{$record->customer_profile_id}")
                    ->url(fn ($record) => $record->customerProfile ? CustomerProfileResource::getUrl('edit', ['record' => $record->customerProfile]) : null)
                    ->openUrlInNewTab()
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('jobType.name')
                    ->label('Job Type')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('title')
                    ->searchable(),
                Tables\Columns\TextColumn::make('description')
                    ->searchable()
                    ->limit(20),
                Tables\Columns\TextColumn::make('proposed_price')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->searchable(),
                Tables\Columns\TextColumn::make('assigned_provider_id')
                    ->label('Assigned Provider')
                    ->formatStateUsing(fn ($record) => $record->assignedProvider->user->name ?? "Provider #{$record->assigned_provider_id}")
                    ->url(fn ($record) => $record->assignedProvider ? ProviderProfileResource::getUrl('edit', ['record' => $record->assignedProvider]) : null)
                    ->openUrlInNewTab()
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('provider_marked_done_at')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListJobs::route('/'),
            'create' => Pages\CreateJob::route('/create'),
            'edit' => Pages\EditJob::route('/{record}/edit'),
        ];
    }
}
