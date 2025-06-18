<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RatingResource\Pages;
use App\Filament\Resources\RatingResource\RelationManagers;
use App\Filament\Resources\JobResource;
use App\Filament\Resources\CustomerProfileResource;
use App\Filament\Resources\ProviderProfileResource;
use App\Models\Rating;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class RatingResource extends Resource
{
    protected static ?string $model = Rating::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('job_id')
                    ->required()
                    ->numeric(),
                Forms\Components\TextInput::make('provider_profile_id')
                    ->required()
                    ->numeric(),
                Forms\Components\TextInput::make('customer_profile_id')
                    ->required()
                    ->numeric(),
                Forms\Components\TextInput::make('rating')
                    ->required()
                    ->numeric()
                    ->default(0),
                Forms\Components\TextInput::make('comment')
                    ->maxLength(512),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('job_id')
                    ->label('Job')
                    ->formatStateUsing(fn ($record) => $record->job->title ?? "Job #{$record->job_id}")
                    ->url(fn ($record) => $record->job ? JobResource::getUrl('edit', ['record' => $record->job]) : null)
                    ->openUrlInNewTab()
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('provider_profile_id')
                    ->label('Provider')
                    ->formatStateUsing(fn ($record) => $record->providerProfile->user->name ?? "Provider #{$record->provider_profile_id}")
                    ->url(fn ($record) => $record->providerProfile ? ProviderProfileResource::getUrl('edit', ['record' => $record->providerProfile]) : null)
                    ->openUrlInNewTab()
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('customer_profile_id')
                    ->label('Customer')
                    ->formatStateUsing(fn ($record) => $record->customerProfile->user->name ?? "Customer #{$record->customer_profile_id}")
                    ->url(fn ($record) => $record->customerProfile ? CustomerProfileResource::getUrl('edit', ['record' => $record->customerProfile]) : null)
                    ->openUrlInNewTab()
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('rating')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('comment')
                    ->searchable() 
                    ->limit(20),
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
                Tables\Actions\DeleteAction::make()
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
            'index' => Pages\ListRatings::route('/'),
            'create' => Pages\CreateRating::route('/create'),
            'edit' => Pages\EditRating::route('/{record}/edit'),
        ];
    }
}
