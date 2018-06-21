<?php
/** fabi/bin/tmpl/sami.conf.php
 *
 * Template config. file for PHP/Sami API documentation generator.
 *
 * F/2018-06-21
 */

use Sami\Sami;
use Sami\RemoteRepository\GitHubRemoteRepository;
use Symfony\Component\Finder\Finder;
use Sami\Parser\Filter\TrueFilter;

$iterator = Finder::create()
    ->files()
    ->name('*.php')
    ->exclude('Resources')
    ->exclude('Tests')
    ->in('./app')
;

$sami = new Sami($iterator, array(
    'theme'                => 'default',
    'title'                => 'Das App. API',
    'build_dir'            => __DIR__.'/tmp/sami/build',
    'cache_dir'            => __DIR__.'/tmp/sami/cache',
    'remote_repository'    => new GitHubRemoteRepository('username/repository', '/path/to/repository'),
    'default_opened_level' => 2,
));

$sami['filter'] = function () {
    return new TrueFilter();
};

return $sami ;
