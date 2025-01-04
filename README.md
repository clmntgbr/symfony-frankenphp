# Symfony Docker FrankenPHP Boilerplate

Based on A [Symfony Docker](https://github.com/dunglas/symfony-docker) installer and runtime for the [Symfony](https://symfony.com) web framework,
with [FrankenPHP](https://frankenphp.dev) and [Caddy](https://caddyserver.com/) inside!

## Getting Started

1. Run `docker compose build --no-cache` to build fresh images
2. Run `docker compose up --pull always -d --wait` to set up and start a fresh Symfony project
3. Open `https://localhost` in your favorite web browser
4. Run `docker compose down --remove-orphans` to stop the Docker containers.

## Features

* Production, development and CI ready
* Just 1 service by default
* Blazing-fast performance thanks to [the worker mode of FrankenPHP](https://github.com/dunglas/frankenphp/blob/main/docs/worker.md) (automatically enabled in prod mode)
* Automatic HTTPS (in dev and prod)
* HTTP/3 and [Early Hints](https://symfony.com/blog/new-in-symfony-6-3-early-hints) support
* ApiPlatform, Doctrine, Fixtures, AMQP Messenger bundles

**Enjoy!**

## License

Symfony Docker is available under the MIT License.
