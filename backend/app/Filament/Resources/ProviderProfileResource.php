<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProviderProfileResource\Pages;
use App\Filament\Resources\ProviderProfileResource\RelationManagers;
use App\Models\ProviderProfile;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class ProviderProfileResource extends Resource
{
    protected static ?string $model = ProviderProfile::class;

    protected static ?int $navigationSort = 4;


    protected static ?string $navigationIcon = 'heroicon-o-user-group';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->label('User')
                    ->options(User::where('role', 'provider')->get()->pluck('name', 'id'))
                    ->searchable()
                    ->required()
                    ->placeholder('Select a provider user'),
                Forms\Components\TextInput::make('rating')
                    ->required()
                    ->numeric()
                    ->default(0)
                    ->minValue(0)
                    ->maxValue(5)
                    ->step(0.1)
                    ->placeholder('Provider rating (0-5)'),
                Forms\Components\Textarea::make('bio')
                    ->maxLength(512)
                    ->placeholder('Provider bio/description')
                    ->rows(3),
                Forms\Components\TextInput::make('address')
                    ->required()
                    ->maxLength(512)
                    ->placeholder('Provider address'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Provider Name')
                    ->searchable(query: function (Builder $query, string $search): Builder {
                        return $query->whereHas('user', function ($query) use ($search) {
                            $query->where('first_name', 'ilike', "%{$search}%")
                                  ->orWhere('last_name', 'ilike', "%{$search}%");
                        });
                    })
                    ->sortable(),
                Tables\Columns\TextColumn::make('user.email')
                    ->label('Email')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('user.phone_number')
                    ->label('Phone')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('rating')
                    ->numeric()
                    ->sortable()
                    ->formatStateUsing(fn (string $state): string => number_format($state, 1)),
                Tables\Columns\TextColumn::make('bio')
                    ->searchable()
                    ->limit(30)
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('address')
                    ->searchable()
                    ->limit(30),
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
            'index' => Pages\ListProviderProfiles::route('/'),
            'create' => Pages\CreateProviderProfile::route('/create'),
            'edit' => Pages\EditProviderProfile::route('/{record}/edit'),
        ];
    }
}
