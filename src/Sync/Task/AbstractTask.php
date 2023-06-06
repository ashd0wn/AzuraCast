<?php

declare(strict_types=1);

namespace App\Sync\Task;

use App\Container\LoggerAwareTrait;
use App\Doctrine\ReadWriteBatchIteratorAggregate;
use App\Doctrine\ReloadableEntityManagerInterface;
use App\Entity;

abstract class AbstractTask implements ScheduledTaskInterface
{
    use LoggerAwareTrait;

    public function __construct(
        protected ReloadableEntityManagerInterface $em
    ) {
    }

    public static function isLongTask(): bool
    {
        return false;
    }

    abstract public function run(bool $force = false): void;

    /**
     * @return ReadWriteBatchIteratorAggregate<int, Entity\Station>
     */
    protected function iterateStations(): ReadWriteBatchIteratorAggregate
    {
        return ReadWriteBatchIteratorAggregate::fromQuery(
            $this->em->createQuery(
                <<<'DQL'
                    SELECT s FROM App\Entity\Station s
                DQL
            ),
            1
        );
    }

    /**
     * @param Entity\Enums\StorageLocationTypes $type
     *
     * @return ReadWriteBatchIteratorAggregate<int, Entity\StorageLocation>
     */
    protected function iterateStorageLocations(Entity\Enums\StorageLocationTypes $type): ReadWriteBatchIteratorAggregate
    {
        return ReadWriteBatchIteratorAggregate::fromQuery(
            $this->em->createQuery(
                <<<'DQL'
                    SELECT sl
                    FROM App\Entity\StorageLocation sl
                    WHERE sl.type = :type
                DQL
            )->setParameter('type', $type->value),
            1
        );
    }
}
