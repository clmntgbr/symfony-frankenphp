<?php

declare(strict_types=1);

namespace App\Infrastructure\Serializer;

use ApiPlatform\State\Pagination\PaginatorInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareTrait;
use Symfony\Component\Serializer\Normalizer\NormalizerInterface;

use function is_array;

final class CollectionNormalizer implements NormalizerInterface, NormalizerAwareInterface
{
    use NormalizerAwareTrait;

    private const ALREADY_CALLED = 'COLLECTION_NORMALIZER_ALREADY_CALLED';

    /**
     * @param array<string, mixed> $context
     *
     * @return array<string, mixed>
     */
    public function normalize(mixed $object, ?string $format = null, array $context = []): array
    {
        $context[self::ALREADY_CALLED] = true;

        $data = $this->normalizer->normalize($object, $format, $context);

        if (! is_array($data)) {
            return [];
        }

        if ($object instanceof PaginatorInterface) {
            $currentPage = $object->getCurrentPage();
            $itemsPerPage = $object->getItemsPerPage();
            $totalItems = $object->getTotalItems();
            $totalPages = $itemsPerPage > 0 ? (int) ceil($totalItems / $itemsPerPage) : 1;

            $data = array_merge([
                'currentPage' => $currentPage,
                'itemsPerPage' => $itemsPerPage,
                'totalPages' => $totalPages,
                'totalItems' => $totalItems,
            ], $data);
        }

        return $data;
    }

    /**
     * @param array<string, mixed> $context
     */
    public function supportsNormalization(mixed $data, ?string $format = null, array $context = []): bool
    {
        if (isset($context[self::ALREADY_CALLED])) {
            return false;
        }

        return $data instanceof PaginatorInterface;
    }

    public function getSupportedTypes(?string $format): array
    {
        return [
            PaginatorInterface::class => false,
        ];
    }
}
