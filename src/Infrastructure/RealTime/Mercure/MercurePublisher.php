<?php

declare(strict_types=1);

namespace App\Infrastructure\RealTime\Mercure;

use App\Domain\User\Entity\User;
use Symfony\Component\Mercure\HubInterface;
use Symfony\Component\Mercure\Update;

use function Safe\json_encode;

class MercurePublisher implements MercurePublisherInterface
{
    public function __construct(
        private HubInterface $hub,
    ) {
    }

    public function refreshUser(User $user, ?string $context = null): void
    {
        $data = json_encode([
            'type' => 'user.refresh',
            'userId' => $user->getId(),
            'context' => $context,
        ]);

        $this->publish($user, $data);
    }

    private function publish(User $user, string $data): void
    {
        $update = new Update(
            "/users/{$user->getId()}",
            $data
        );

        $this->hub->publish($update);
    }
}
