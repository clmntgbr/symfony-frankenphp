<?php

namespace App\Repository;

use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;

/**
 * @template T of object
 */
abstract class AbstractRepository extends ServiceEntityRepository
{
    /**
     * @param T $entity
     *
     * @return T
     */
    public function refresh(object $entity): object
    {
        $this->getEntityManager()->refresh($entity);

        return $entity;
    }

    /**
     * @param T $entity
     */
    public function delete(object $entity): void
    {
        $this->getEntityManager()->remove($entity);
        $this->getEntityManager()->flush();
    }

    /**
     * @param T $entity
     */
    public function save(object $entity, bool $persist = false): void
    {
        if (null === $entity->getId() || $persist) {
            $this->getEntityManager()->persist($entity);
        }

        $this->getEntityManager()->flush();
    }

    public function saveAll(array $entities, bool $persist = false): void
    {
        foreach ($entities as $entity) {
            $this->save($entity, $persist);
        }
    }

    public function saveAllChunks(iterable $entities, int $chunkSize = 50): void
    {
        if ($chunkSize <= 0) {
            throw new \ValueError(__METHOD__.': Argument #2 ($chunkSize) must be greater than 0');
        }

        $em = $this->getEntityManager();

        $chunks = iterator_chunk($entities, $chunkSize);
        foreach ($chunks as $chunk) {
            foreach ($chunk as $entity) {
                if (!$em->contains($entity)) {
                    $em->persist($entity);
                }
            }

            $em->flush();
            $em->clear();
        }
    }

    /**
     * @param T $entity
     *
     * @return T
     */
    public function update(object $entity, array $data): object
    {
        foreach ($data as $key => $value) {
            $method = 'set'.ucfirst($key);
            if (method_exists($entity, $method)) {
                $entity->$method($value);
                continue;
            }

            $method = 'add'.ucfirst($key);
            if (method_exists($entity, $method)) {
                $entity->$method($value);
            }
        }

        $this->save($entity);

        return $entity;
    }
}
