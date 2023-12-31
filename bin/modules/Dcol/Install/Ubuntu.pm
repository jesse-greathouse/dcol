#!/usr/bin/perl

package Dcol::Install::Ubuntu;
use strict;
use Cwd qw(getcwd abs_path);
use File::Copy;
use Exporter 'import';
our @EXPORT_OK = qw(
    install_system_dependencies
    install_php
    install_perl_modules
    install_pear
    install_imagick
    install_composer
    install_symlinks
    install_composer_dependencies
    cleanup
);

my @systemDependencies = (
    'supervisor',
    'authbind',
    'expect',
    'openssl',
    'build-essential',
    'intltool',
    'autoconf',
    'automake',
    'gcc',
    'perl',
    'curl',
    'pkg-config',
    'expect',
    'mysql-client',
    'imagemagick',
    'libpcre++-dev',
    'libcurl4',
    'libcurl4-openssl-dev',
    'libmagickwand-dev',
    'libssl-dev',
    'libxslt1-dev',
    'libmysqlclient-dev',
    'libpcre2-dev',
    'libxml2',
    'libxml2-dev',
    'libicu-dev',
    'libmagick++-dev',
    'libzip-dev',
    'libonig-dev',
    'libsodium-dev',
    'libglib2.0-dev',
    'libgd-dev',
    'libfreetype-dev',
    'libedit-dev',
);

my @perlModules = (
    'JSON',
    'YAML::XS',
    'LWP::UserAgent',
    'cpanm LWP::Protocol::https',
    'Term::ANSIScreen',
    'Term::Menus',
    'Term::Prompt',
    'Term::ReadKey',
    'Text::Wrap',
    'Archive::Zip',
    'File::Slurper',
    'File::HomeDir',
    'File::Find::Rule',
);

1;

# ====================================
#    Subroutines below this point
# ====================================

# installs OS level system dependencies.
sub install_system_dependencies {
    my @updateCmd = ('sudo');
    push @updateCmd, 'apt-get';
    push @updateCmd, 'update';
    system(@updateCmd);
    command_result($?, $!, "Updating system dependencies...", \@updateCmd);

    my @cmd = ('sudo');
    push @cmd, 'apt-get';
    push @cmd, 'install';
    push @cmd, '-y';
    foreach my $dependency (@systemDependencies) {
        push @cmd, $dependency;
    }

    system(@cmd);
    command_result($?, $!, "Install system dependencies...", \@cmd);
}

# installs PHP.
sub install_php {
    my ($dir) = @_;
    my @configurePhp = ('./configure');
    push @configurePhp, '--prefix=' . $dir . '/opt/php';
    push @configurePhp, '--sysconfdir=' . $dir . '/etc',;
    push @configurePhp, '--with-config-file-path=' . $dir . '/etc/php',;
    push @configurePhp, '--with-config-file-scan-dir=' . $dir . '/etc/php/conf.d';
    push @configurePhp, '--enable-opcache';
    push @configurePhp, '--enable-fpm';
    push @configurePhp, '--enable-dom';
    push @configurePhp, '--enable-exif';
    push @configurePhp, '--enable-fileinfo';
    push @configurePhp, '--enable-json';
    push @configurePhp, '--enable-mbstring';
    push @configurePhp, '--enable-bcmath';
    push @configurePhp, '--enable-intl';
    push @configurePhp, '--enable-ftp';
    push @configurePhp, '--enable-gd';
    push @configurePhp, '--without-sqlite3';
    push @configurePhp, '--without-pdo-sqlite';
    push @configurePhp, '--with-readline';
    push @configurePhp, '--with-libedit';
    push @configurePhp, '--with-libxml';
    push @configurePhp, '--with-xsl';
    push @configurePhp, '--with-xmlrpc';
    push @configurePhp, '--with-zlib';
    push @configurePhp, '--with-curl';
    push @configurePhp, '--with-webp';
    push @configurePhp, '--with-openssl';
    push @configurePhp, '--with-zip';
    push @configurePhp, '--with-sodium';
    push @configurePhp, '--with-mysqli';
    push @configurePhp, '--with-pdo-mysql';
    push @configurePhp, '--with-mysql-sock';
    push @configurePhp, '--with-iconv';
    push @configurePhp, '--with-jpeg';
    push @configurePhp, '--with-freetype';

    my $originalDir = getcwd();
   
    # Unpack
    system(('bash', '-c', "tar -xzf $dir/opt/php-*.tar.gz -C $dir/opt/"));
    command_result($?, $!, 'Unpack PHP Archive...', 'tar -xf ' . $dir . '/opt/php-*.tar.gz -C ' . $dir . ' /opt/');

    chdir glob("$dir/opt/php-*/");

    # configure
    system(@configurePhp);
    command_result($?, $!, 'Configure PHP...', \@configurePhp);

    # make
    system('make');
    command_result($?, $!, 'Make PHP...', 'make');

    # install
    system('make install');
    command_result($?, $!, 'Install PHP...', 'make install');

    chdir $originalDir;
}

# installs Perl Modules.
sub install_perl_modules {
    foreach my $perlModule (@perlModules) {
        my @cmd = ('sudo');
        push @cmd, 'cpanm';
        push @cmd, $perlModule;
        system(@cmd);

        command_result($?, $!, "Shared library pass for: $_", \@cmd);
    }
}


# installs Pear.
sub install_pear {
    my ($dir) = @_;
    my $phpIniFile = $dir . '/etc/php/php.ini';
    my $phpIniBackupFile = $phpIniFile . '.' . time() . '.bak';

    # If php.ini exists, hide it before pear installs
    if (-e $phpIniFile) {
        move($phpIniFile, $phpIniBackupFile);
    }

    system(('bash', '-c', "yes n | $dir/bin/install-pear.sh $dir/opt"));
    command_result($?, $!, 'Install Pear...', "yes n | $dir/bin/install-pear.sh $dir/opt");

    # Replace the php.ini file
    if (-e $phpIniBackupFile) {
         move($phpIniBackupFile, $phpIniFile);
    }
}

# installs Imagemagick.
sub install_imagick {
    my ($dir) = @_;
    my $phpIniFile = $dir . '/etc/php/php.ini';
    my $phpIniBackupFile = $phpIniFile . '.' . time() . '.bak';
    my $cmd = 'yes n | PATH="' . $dir . '/opt/php/bin:$PATH" ' . $dir . '/opt/pear/bin/pecl install imagick';

    # If php.ini exists, hide it before pear installs
    if (-e $phpIniFile) {
        move($phpIniFile, $phpIniBackupFile);
    }

    system(('bash', '-c', $cmd));
    command_result($?, $!, 'Install Imagemagick...', "...");

    # Replace the php.ini file
    if (-e $phpIniBackupFile) {
         move($phpIniBackupFile, $phpIniFile);
    }
}

# installs Composer.
sub install_composer {
    my ($dir) = @_;
    my $binDir = $dir . '/bin';
    my $phpExecutable = $dir . '/opt/php/bin/php';
    my $composerInstallScript = $binDir . '/composer-setup.php';
    my $composerHash = 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02';
    my $composerDownloadCommand = "$phpExecutable -r \"copy('https://getcomposer.org/installer', '$composerInstallScript');\"";
    my $composerCheckHashCommand = "$phpExecutable -r \"if (hash_file('sha384', '$composerInstallScript') === '$composerHash') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('$composerInstallScript'); } echo PHP_EOL;\"";
    my $composerInstallCommand = "$phpExecutable $composerInstallScript";
    my $removeIntallScriptCommand = "$phpExecutable -r \"unlink('$composerInstallScript');\"";
    my $composerArtifact = "composer.phar";

    # Remove the composer artifact if it already exists.
    if (-e "$binDir/$composerArtifact") {
         unlink "$binDir/$composerArtifact";
    }

    system(('bash', '-c', $composerDownloadCommand));
    command_result($?, $!, 'Download Composer Install Script...', $composerDownloadCommand);

    system(('bash', '-c', $composerCheckHashCommand));
    command_result($?, $!, 'Verify Composer Hash...', $composerCheckHashCommand);

    system(('bash', '-c', $composerInstallCommand));
    command_result($?, $!, 'Installing Composer...', $composerInstallCommand);

    system(('bash', '-c', $removeIntallScriptCommand));
    command_result($?, $!, 'Removing Composer Install Script...', $removeIntallScriptCommand);

    # Move the composer artifact to the right place in bin/
    if (-e $composerArtifact) {
         move($composerArtifact, "$binDir/$composerArtifact");
    }
}

# installs symlinks.
sub install_symlinks {
    my ($dir) = @_;
    my $binDir = $dir . '/bin';
    my $optDir = $dir . '/opt';
    my $vendorDir = $dir . '/vendor';
    symlink("$optDir/php/bin/php", "$binDir/php");
    symlink("$binDir/composer.phar", "$binDir/composer");
    symlink("$vendorDir/bin/laravel", "$binDir/laravel");
}

# installs composer dependencies.
sub install_composer_dependencies {
    my ($dir) = @_;
    my $binDir = $dir . '/bin';
    my $phpExecutable = $binDir . '/php';
    my $composerExecutable = "$phpExecutable $binDir/composer";
    my $composerInstallCommand = "$composerExecutable install";

    system(('bash', '-c', $composerInstallCommand));
    command_result($?, $!, 'Installing Composer Dependencies...', $composerInstallCommand);
}

sub cleanup {
    my ($dir) = @_;
    my $phpBuildDir = glob("$dir/opt/php-*/");
    system(('bash', '-c', "rm -rf $phpBuildDir"));
    command_result($?, $!, 'Remove PHP Build Dir...', "rm -rf $phpBuildDir");
}

sub command_result {
    my ($exit, $err, $operation_str, @cmd) = @_;

    if ($exit == -1) {
        print "failed to execute: $err \n";
        exit $exit;
    }
    elsif ($exit & 127) {
        printf "child died with signal %d, %s coredump\n",
            ($exit & 127),  ($exit & 128) ? 'with' : 'without';
        exit $exit;
    }
    else {
        printf "$operation_str exited with value %d\n", $exit >> 8;
    }
}
