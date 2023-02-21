#! /usr/bin/env bash

cd "$(dirname "$0")"

# based on frida-gum/bindings/gumjs/generate-runtime.py

# TODO use the actual verions from generate-runtime.py

# frida-gum build fails with a higher version of frida-compile
# https://github.com/frida/frida-gum/issues/724

npm init -y
npm install frida-compile@^10.2.5 frida-java-bridge@6.2.3 frida-objc-bridge@7.0.2 frida-swift-bridge@2.0.6
