const fs = require('fs')
const path = require('path')
const YAML = require('yaml')

const baseConfig = {
    'image': 'Visual Studio 2015',

    'skip_branch_with_pr': true,
    'environment': {
        'TARGET_PLATFORM': 'win32',
        'WIN_ARCH': 64,
        'GIT_FOR_WINDOWS_URL': 'https://github.com/git-for-windows/git/releases/download/v2.19.1.windows.1/MinGit-2.19.1-64-bit.zip',
        'GIT_FOR_WINDOWS_CHECKSUM': 'f89e103a41bda8e12efeaab198a8c20bb4a84804683862da518ee2cb66a5a5b3',
        'GIT_LFS_VERSION': '2.6.0',
        'GIT_LFS_CHECKSUM': 'f1312d00e435c16c8d19d914d5108db6a5ddbee1badb214c66f22cfa5d18b279'
    },
    'build_script': [
        'cmd: git submodule update --init --recursive',
        'bash: script\\build.sh',
        'bash: script\\package.sh',
    ],
    'test': 'off'
}

const appveyorFile = path.resolve(__dirname, '..', 'appveyor.yml')

const yaml = YAML.stringify(baseConfig)

fs.writeFileSync(appveyorFile, yaml)
