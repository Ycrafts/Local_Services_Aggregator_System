<?php

namespace App\Filament\Resources;

use App\Filament\Resources\JobTypeResource\Pages;
use App\Filament\Resources\JobTypeResource\RelationManagers;
use App\Models\JobType;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class JobTypeResource extends Resource
{
    protected static ?string $model = JobType::class;

    protected static ?int $navigationSort = 4;


    protected static ?string $navigationIcon = 'heroicon-o-tag';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(64),
                Forms\Components\TextInput::make('baseline_price')
                    ->required()
                    ->numeric(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('baseline_price')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('provider_count')
                    ->label('Providers')
                    ->getStateUsing(function ($record) {
                        return $record->providerProfiles()->count();
                    })
                    ->sortable(query: function (Builder $query, string $direction): Builder {
                        return $query->withCount('providerProfiles')->orderBy('provider_profiles_count', $direction);
                    })
                    ->badge()
                    ->color('success'),
                Tables\Columns\TextColumn::make('total_jobs')
                    ->label('Total Jobs')
                    ->getStateUsing(function ($record) {
                        return $record->jobs()->count();
                    })
                    ->sortable(query: function (Builder $query, string $direction): Builder {
                        return $query->withCount('jobs')->orderBy('jobs_count', $direction);
                    })
                    ->badge()
                    ->color('info'),
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
                Tables\Actions\DeleteAction::make(),
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
            'index' => Pages\ListJobTypes::route('/'),
            'create' => Pages\CreateJobType::route('/create'),
            'edit' => Pages\EditJobType::route('/{record}/edit'),
        ];
    }
}
