<?php

declare(strict_types=1);

namespace App\Infrastructure\RealTime\Mercure;

use App\Domain\User\Entity\User;

interface MercurePublisherInterface
{
    public function refreshUser(User $user, ?string $context = null): void;
}
