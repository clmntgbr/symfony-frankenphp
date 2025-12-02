<?php

declare(strict_types=1);

namespace App\Application\User\Command;

use App\Domain\User\Entity\User;
use App\Domain\User\Repository\UserRepository;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler]
class CreateUserCommandHandler
{
    public function __construct(
        private UserRepository $userRepository,
    ) {
    }

    public function __invoke(CreateUserCommand $command): User
    {
        $user = User::create(
            firstname: $command->getFirstname(),
            lastname: $command->getLastname(),
            picture: $command->getPicture(),
            email: $command->getEmail(),
            plainPassword: $command->getPlainPassword(),
        );

        $this->userRepository->saveAndFlush($user);

        return $user;
    }
}
