FIXME

error: The name `garbage_collect' does not exist in the context of `GLib.Thread' (glib-2.0)

[40/144] Compiling Vala source ../lib/gadget/gadget.vala lib/base/frida-base-1.0.vapi lib/payload/frida-payload-1.0.vapi
FAILED: lib/gadget/libfrida-gadget.so.p/gadget.c lib/gadget/frida-gadget.h lib/gadget/frida-gadget.vapi
valac -C --define=HAVE_EMBEDDED_ASSETS --define=HAVE_V8 --define=HAVE_GIOOPENSSL --define=HAVE_NICE --vapidir=/home/user/src/frida/frida-core/vapi --pkg config --define=LINUX --define=X86_64 --pkg gio-unix-2.0 --pkg gioopenssl --pkg nice --pkg frida-gumjs-1.0 --pkg frida-gum-1.0 --pkg json-glib-1.0 --pkg gee-0.8 --pkg gio-2.0 --color=always --directory lib/gadget/libfrida-gadget.so.p --basedir ../lib/gadget --library frida-gadget --header lib/gadget/frida-gadget.h --vapi ../frida-gadget.vapi ../lib/gadget/gadget.vala lib/base/frida-base-1.0.vapi lib/payload/frida-payload-1.0.vapi
../lib/gadget/gadget.vala:2137.32-2137.53: error: The name `garbage_collect' does not exist in the context of `GLib.Thread' (glib-2.0)
 2137 |                         bool collected_everything = Thread.garbage_collect ();
      |                                                     ^~~~~~~~~~~~~~~~~~~~~~









Program v8-mksnapshot-linux-x86_64 found: NO



[11/144] Compiling C object lib/base/libfrida-base-1.0.a.p/p2p-glue.c.o
../lib/base/p2p-glue.c: In function '_frida_sctp_timer_source_get_timeout':
../lib/base/p2p-glue.c:347:10: warning: implicit declaration of function 'usrsctp_get_timeout'; did you mean 'usrsctp_get_stat'? [-Wimplicit-function-declaration]
  347 |   return usrsctp_get_timeout ();
      |          ^~~~~~~~~~~~~~~~~~~



[34/144] Generating src/compiler/frida-compiler-agent with a custom command
FAILED: src/compiler/agent.js src/compiler/snapshot.bin
/build/source/src/compiler/generate-agent.py /build/source/src/compiler /build/source/build/src/compiler linux 64 ''
npm ERR! code EAI_AGAIN
npm ERR! syscall getaddrinfo
npm ERR! errno EAI_AGAIN
npm ERR! request to https://registry.npmjs.org/wrappy/-/wrappy-1.0.2.tgz failed, reason: getaddrinfo EAI_AGAIN registry.npmjs.org

npm ERR! Log files were not written due to an error writing to the directory: /homeless-shelter/.npm/_logs
npm ERR! You can rerun the command with `--loglevel=verbose` to see the logs in your terminal

***
Failed to bootstrap the compiler agent:
        Command '['npm', 'install']' returned non-zero exit status 1.
It appears Node.js is not installed.
We need it for processing JavaScript code at build-time.
Check PATH or set NPM to the absolute path of your npm binary.
***

# input_dir = /build/source/src/compiler
# output_dir = /build/source/build/src/compiler

https://github.com/frida/frida-core/blob/main/src/compiler/package.json

TODO install node_modules from
https://github.com/frida/frida-core/blob/main/src/compiler/package-lock.json
