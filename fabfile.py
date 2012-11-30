#!/usr/bin/env python

from fabric.api import cd, env, local, run

def dev():
    # change the default user
    env.user = 'vagrant'
    env.hosts = ['10.13.3.7']
    env.code_root = '/vagrant'
    # use vagrant ssh key
    result = local('vagrant ssh-config | grep IdentityFile', capture=True)
    env.key_filename = result.split()[1]
    
def runserver(port=31337):
    with cd(env.code_root):
        run('python ./manage.py runserver 0.0.0.0:%s' % port)
