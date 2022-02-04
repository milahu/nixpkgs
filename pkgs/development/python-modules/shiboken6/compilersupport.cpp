// pyside6/sources/shiboken6/ApiExtractor/clangparser/compilersupport.cpp

/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of Qt for Python.
**
** $QT_BEGIN_LICENSE:GPL-EXCEPT$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 as published by the Free Software
** Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "compilersupport.h"
#include "header_paths.h"

#include <reporthandler.h>

#include <QtCore/QDebug>
#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include <QtCore/QProcess>
#include <QtCore/QStandardPaths>
#include <QtCore/QStringList>
#include <QtCore/QVersionNumber>

#include <clang-c/Index.h>

#include <string.h>
#include <algorithm>
#include <iterator>

#include <iostream> // std::cerr

namespace clang {

QVersionNumber libClangVersion()
{
    return QVersionNumber(CINDEX_VERSION_MAJOR, CINDEX_VERSION_MINOR);
}

static Compiler _compiler =
#if defined (Q_CC_CLANG)
    Compiler::Clang;
#elif defined (Q_CC_MSVC)
    Compiler::Msvc;
#else
    Compiler::Gpp;
#endif

Compiler compiler() { return _compiler; }

static Platform _platform =
#if defined (Q_OS_DARWIN)
    Platform::macOS;
#elif defined (Q_OS_WIN)
    Platform::Windows;
#else
    Platform::Unix;
#endif

Platform platform() { return _platform; }

static bool runProcess(const QString &program, const QStringList &arguments,
                       QByteArray *stdOutIn = nullptr, QByteArray *stdErrIn = nullptr)
{
    QProcess process;
    process.start(program, arguments, QProcess::ReadWrite);
    if (!process.waitForStarted()) {
        qWarning().noquote().nospace() << "Unable to start "
            << process.program() << ": " << process.errorString();
        return false;
    }
    process.closeWriteChannel();
    const bool finished = process.waitForFinished();
    const QByteArray stdErr = process.readAllStandardError();
    if (stdErrIn)
        *stdErrIn = stdErr;
    if (stdOutIn)
        *stdOutIn = process.readAllStandardOutput();

    if (!finished) {
        qWarning().noquote().nospace() << process.program() << " timed out: " << stdErr;
        process.kill();
        return false;
    }

    if (process.exitStatus() != QProcess::NormalExit) {
        qWarning().noquote().nospace() << process.program() << " crashed: " << stdErr;
        return false;
    }

    if (process.exitCode() != 0) {
        qWarning().noquote().nospace() <<  process.program() << " exited "
            << process.exitCode() << ": " << stdErr;
        return false;
    }

    return true;
}

static QByteArray frameworkPath() { return QByteArrayLiteral(" (framework directory)"); }

static void filterHomebrewHeaderPaths(HeaderPaths &headerPaths)
{
    QByteArray homebrewPrefix = qgetenv("HOMEBREW_OPT");

    // If HOMEBREW_OPT is found we assume that the build is happening
    // inside a brew environment, which means we need to filter out
    // the -isystem flags added by the brew clang shim. This is needed
    // because brew passes the Qt include paths as system include paths
    // and because our parser ignores system headers, Qt classes won't
    // be found and thus compilation errors will occur.
    if (homebrewPrefix.isEmpty())
        return;

    qCInfo(lcShiboken) << "Found HOMEBREW_OPT with value:" << homebrewPrefix
                       << "Assuming homebrew build environment.";

    HeaderPaths::iterator it = headerPaths.begin();
    while (it != headerPaths.end()) {
        if (it->path.startsWith(homebrewPrefix)) {
            qCInfo(lcShiboken) << "Filtering out homebrew include path: "
                               << it->path;
            it = headerPaths.erase(it);
        } else {
            ++it;
        }
    }
}

// Determine g++'s internal include paths from the output of
// g++ -E -x c++ - -v </dev/null
// Output looks like:
// #include <...> search starts here:
// /usr/local/include
// /System/Library/Frameworks (framework directory)
// End of search list.

// TODO(milahu) revert patch
static HeaderPaths gppInternalIncludePaths(const QString &compiler)
{
    std::cerr << "milahu debug: gppInternalIncludePaths: compiler = " << compiler.toStdString() << '\n';

    HeaderPaths result;
    QStringList arguments;
    arguments << QStringLiteral("-E") << QStringLiteral("-x") << QStringLiteral("c++")
         << QStringLiteral("-") << QStringLiteral("-v");
    QByteArray stdOut;
    QByteArray stdErr;

    // milahu debug
    for (QString arg : arguments)
      std::cerr << "milahu debug: gppInternalIncludePaths: argument[] = " << arg.toStdString() << '\n';

    if (!runProcess(compiler, arguments, &stdOut, &stdErr)) {

        // milahu debug
        std::cerr << "milahu debug: gppInternalIncludePaths: runProcess failed\n";

        return result;
    }

    std::cerr << "milahu debug: gppInternalIncludePaths: runProcess stdOut = " << stdOut.constData() << '\n';
    std::cerr << "milahu debug: gppInternalIncludePaths: runProcess stdErr = " << stdErr.constData() << '\n';

/*
stderr:

#include "..." search starts here:
#include <...> search starts here:
 /nix/store/fxzhmc5zgws2la9c21p577m8hmzbjisb-compiler-rt-libc-13.0.0-dev/include
 /nix/store/9zig5f1s1745lj2f1k68wz129087y3ww-clang-13.0.0-dev/include
 /nix/store/5lzxpdzrg7j47vvjrv3ryfz2amwvwnch-llvm-13.0.0-dev/include
 /nix/store/03aqjxlvv0zhnzai2c1vxj63sd4v0v2k-ncurses-6.3-dev/include
 /nix/store/pnjapywqwhbi7y8462bc858y0k2j00dn-zlib-1.2.11-dev/include
 /nix/store/i6vabb4div9iy6lsl642d86k1q8riasn-python3-3.9.9/include
 /nix/store/0kb2vf3qnvd0cccgn6g98w4lyy7kadh7-qtbase-6.2.2-dev/include
 ...
 /nix/store/9m0k71s1ddhsp5l84wlpk9yhcmh5n1wx-gcc-10.3.0/include/c++/10.3.0
 /nix/store/9m0k71s1ddhsp5l84wlpk9yhcmh5n1wx-gcc-10.3.0/include/c++/10.3.0/x86_64-unknown-linux-gnu
 /nix/store/jdnmdqrrjphi8n85d9d8im9ym30dkd68-clang-wrapper-13.0.0/resource-root/include
 /nix/store/93z3gj6kl0qvdm1mzwb5vaxlz7i481lz-glibc-2.33-62-dev/include
End of search list.
*/

    // milahu debug
    std::cerr << "milahu debug: gppInternalIncludePaths: frameworkPath = " << frameworkPath().constData() << '\n';

    const QByteArrayList stdErrLines = stdErr.split('\n');
    bool isIncludeDir = false;
    for (const QByteArray &line : stdErrLines) {

        // milahu debug
        //std::cerr << "milahu debug: gppInternalIncludePaths: g++ output line = " << line.constData() << '\n';

        if (isIncludeDir) {
            if (line.startsWith(QByteArrayLiteral("End of search list"))) {
                isIncludeDir = false;
            } else {
                HeaderPath headerPath{line.trimmed(), HeaderType::System};
                if (headerPath.path.endsWith(frameworkPath())) {

                    // milahu debug
                    std::cerr <<
                      "milahu debug: gppInternalIncludePaths: headerPath.path = " << headerPath.path.constData() << " : ends with frameworkPath = " << frameworkPath().constData() << '\n';
                    // -> no path "ends with frameworkPath"

                    headerPath.type = HeaderType::FrameworkSystem;
                    headerPath.path.truncate(headerPath.path.size() - frameworkPath().size());

                    // milahu debug
                    std::cerr <<
                    "milahu debug: gppInternalIncludePaths: headerPath.path = " << headerPath.path.constData() << " : truncated = remove frameworkPath suffix" << '\n';
                }
                // milahu: force qt paths to be "framework" paths
                // based on nixpkgs/pkgs/development/python-modules/shiboken6/nix_compile_cflags.patch
                else if (headerPath.path.contains("-qt")) {
                    std::cerr << "milahu debug: gppInternalIncludePaths: headerPath.path = " << headerPath.path.constData() << " : contains qt -> force frameworkPath\n";
                    // override headerType
                    headerPath.type = HeaderType::FrameworkSystem;
                }
                // milahu debug
                else {
                  std::cerr <<
                    "milahu debug: gppInternalIncludePaths: headerPath.path = " << headerPath.path.constData() << " : no frameworkPath\n";
                }

                result.append(headerPath);
            }
        } else if (line.startsWith(QByteArrayLiteral("#include <...> search starts here"))) {
            isIncludeDir = true;
        }
    }

    if (platform() == Platform::macOS)
        filterHomebrewHeaderPaths(result);

    return result;
}

// Detect Vulkan as supported from Qt 5.10 by checking the environment variables.
static void detectVulkan(HeaderPaths *headerPaths)
{
    static const char *vulkanVariables[] = {"VULKAN_SDK", "VK_SDK_PATH"};
    for (const char *vulkanVariable : vulkanVariables) {
        if (qEnvironmentVariableIsSet(vulkanVariable)) {
            const QByteArray path = qgetenv(vulkanVariable) + QByteArrayLiteral("/include");
            headerPaths->append(HeaderPath{path, HeaderType::System});
            break;
        }
    }
}

// For MSVC, we set the MS compatibility version and let Clang figure out its own
// options and include paths.
// For the others, we pass "-nostdinc" since libclang tries to add it's own system
// include paths, which together with the clang compiler paths causes some clash
// which causes std types not being found and construct -I/-F options from the
// include paths of the host compiler.

static QByteArray noStandardIncludeOption() { return QByteArrayLiteral("-nostdinc"); }

// The clang builtin includes directory is used to find the definitions for
// intrinsic functions and builtin types. It is necessary to use the clang
// includes to prevent redefinition errors. The default toolchain includes
// should be picked up automatically by clang without specifying
// them implicitly.

// Besides g++/Linux, as of MSVC 19.28.29334, MSVC needs clang includes
// due to PYSIDE-1433, LLVM-47099

static bool needsClangBuiltinIncludes()
{
    return platform() != Platform::macOS;
}

// TODO(milahu) revert patch. wrong place for libcxx include path
static QStringList findClangLibDirList()
{
    QStringList result;
    for (const char *envVar : {"LLVM_INSTALL_DIR", "CLANG_INSTALL_DIR"}) {
        if (qEnvironmentVariableIsSet(envVar)) {
            QByteArray pathBytesList = qgetenv(envVar); // colon-separated list of paths
            for (QByteArray pathBytes : pathBytesList.split(':')) {
              const QString path = QFile::decodeName(pathBytes) + QLatin1String("/lib");
              // libclang -> ${llvmPackages_9.libclang.lib}/lib/clang/9.0.1/include     // ok
              // libcxx   -> ${llvmPackages_9.libcxx.dev  }/include/c++/v1/type_traits  // wrong!
              // -> libcxx include path must come from somewhere else.
              if (QFileInfo::exists(path))
                  result << path;
              else
                  qWarning("%s: %s as pointed to by %s does not exist.", __FUNCTION__, qPrintable(path), envVar);
            }
        }
    }
    if (result.size() > 0)
        return result;
    const QString llvmConfig =
        QStandardPaths::findExecutable(QLatin1String("llvm-config"));
    if (!llvmConfig.isEmpty()) {
        QByteArray stdOut;
        if (runProcess(llvmConfig, QStringList{QLatin1String("--libdir")}, &stdOut)) {
            const QString path = QFile::decodeName(stdOut.trimmed());
            if (QFileInfo::exists(path))
                result << path;
            else
                qWarning("%s: %s as returned by llvm-config does not exist.", __FUNCTION__, qPrintable(path));
        }
    }
    return result;
}

static QStringList findClangBuiltInIncludesDirList()
{
    QStringList result;
    // Find the include directory of the highest version.
    const QStringList clangPathLibDirList = findClangLibDirList();
    for (QString clangPathLibDir : clangPathLibDirList) {
        QString candidate;
        QVersionNumber lastVersionNumber(1, 0, 0);
        const QString clangDirName = clangPathLibDir + QLatin1String("/clang");
        QDir clangDir(clangDirName);

        // reached

        // milahu debug
        std::cerr << "milahu debug: findClangBuiltInIncludesDirList: clangPathLibDir = " << clangPathLibDir.toStdString() << '\n';
        std::cerr << "milahu debug: findClangBuiltInIncludesDirList: clangDirName = " << clangDirName.toStdString() << '\n';
        //std::cerr << "milahu debug: clangDir = " << clangDir << '\n';

        /*
        milahu debug: clangPathLibDir = /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib
        milahu debug: clangDirName = /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib/clang
        milahu debug: clangBuiltinIncludesDir = /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib/clang/9.0.1/include
        qt.shiboken: (shiboken) CLANG builtins includes directory: /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib/clang/9.0.1/include
        */

        const QFileInfoList versionDirs =
            clangDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
        if (versionDirs.isEmpty())
            qWarning("%s: No subdirectories found in %s.", __FUNCTION__, qPrintable(clangDirName));

        // (shiboken) findClangBuiltInIncludesDirList: No subdirectories found in /nix/store/vjcxibppbkmcsibv832a660wxal72n8k-llvm-9.0.1-lib/lib/clang.

        for (const QFileInfo &fi : versionDirs) {
            const QString fileName = fi.fileName();
            if (fileName.at(0).isDigit()) {
                const QVersionNumber versionNumber = QVersionNumber::fromString(fileName);
                if (!versionNumber.isNull() && versionNumber > lastVersionNumber) {
                    candidate = fi.absoluteFilePath();
                    lastVersionNumber = versionNumber;
                }
            }
        }
        if (!candidate.isEmpty()) {
            std::cerr << "milahu debug: findClangBuiltInIncludesDirList: add candidate: " << candidate.toStdString() << "/include\n";
            result << candidate + QStringLiteral("/include");
            // /nix/store/bj29nvjhx4hjfhfrwqwq1kazc3ibmq9m-clang-10.0.1-lib/lib/clang/10.0.1/include

        }
    }
    return result;
}

static QString compilerFromCMake(const QString &defaultCompiler)
{
// Added !defined(Q_OS_DARWIN) due to PYSIDE-1032
    QString result = defaultCompiler;
    if (platform() != Platform::macOS)
#ifdef CMAKE_CXX_COMPILER
        result = QString::fromLocal8Bit(CMAKE_CXX_COMPILER);
#endif
    return result;
}

static void appendClangBuiltinIncludes(HeaderPaths *p)
{
    //const QStringList clangBuiltinIncludesDirList =
    //    QDir::toNativeSeparators(findClangBuiltInIncludesDirList());
    //const QStringList clangBuiltinIncludesDirList = findClangBuiltInIncludesDirList();

    QStringList clangBuiltinIncludesDirList;

    for (QString path : findClangBuiltInIncludesDirList())
      clangBuiltinIncludesDirList << QDir::toNativeSeparators(path);

    if (clangBuiltinIncludesDirList.size() == 0) {
        qCWarning(lcShiboken, "Unable to locate Clang's built-in include directory "
                  "(neither by checking the environment variables LLVM_INSTALL_DIR, CLANG_INSTALL_DIR "
                  " nor running llvm-config). This may lead to parse errors.");

// milahu debug
// qt.shiboken: (shiboken) Unable to locate Clang's built-in include directory
// (neither by checking the environment variables LLVM_INSTALL_DIR, CLANG_INSTALL_DIR
// nor running llvm-config). This may lead to parse errors.

    } else {
        for (QString clangBuiltinIncludesDir : clangBuiltinIncludesDirList) {


            // reached

            // milahu debug
            std::cerr << "milahu debug: clangBuiltinIncludesDir = " << clangBuiltinIncludesDir.toStdString() << '\n';

            qCInfo(lcShiboken, "CLANG builtins includes directory: %s",
                qPrintable(clangBuiltinIncludesDir));
            p->append(HeaderPath{QFile::encodeName(clangBuiltinIncludesDir),
                                HeaderType::System});
        }
    }


// milahu debug
// TODO try as non-system headers
/*
{
  // fix: fatal error: 'type_traits' file not found
  //QString clangBuiltinIncludesDir = QLatin1String("/nix/store/vdfr889lwm84xzgabqhdnm9vwc0xrwy1-libcxx-9.0.1-dev/include/c++/v1"); // ${llvmPackages_9.libcxx.dev}/include/c++/v1/type_traits
  QString clangBuiltinIncludesDir = QLatin1String("/nix/store/vb1dk5c3xg9r8q6mdw3cl3qgzm6vgnvd-libcxx-10.0.1-dev/include/c++/v1"); // ${llvmPackages_10.libcxx.dev}/include/c++/v1/type_traits
  std::cerr << "milahu debug: clangBuiltinIncludesDir: manually add libcxx include path: " << qPrintable(clangBuiltinIncludesDir) << "\n";
  p->append(HeaderPath{
    QFile::encodeName(clangBuiltinIncludesDir),
    HeaderType::System
  });
}
{
  // fix: fatal error: 'features.h' file not found
  QString clangBuiltinIncludesDir = QLatin1String("/nix/store/93z3gj6kl0qvdm1mzwb5vaxlz7i481lz-glibc-2.33-62-dev/include"); // ${glibc.dev}/include/features.h
  std::cerr << "milahu debug: clangBuiltinIncludesDir: manually add glibc include path: " << qPrintable(clangBuiltinIncludesDir) << "\n";
  p->append(HeaderPath{
    QFile::encodeName(clangBuiltinIncludesDir),
    HeaderType::System
  });
}
*/

/*
{
  // fix: fatal error: 'stddef.h' file not found
  // /nix/store/bj29nvjhx4hjfhfrwqwq1kazc3ibmq9m-clang-10.0.1-lib/lib/clang/10.0.1/include/stddef.h
  // this should be added by ...
  // qt.shiboken: (shiboken) CLANG builtins includes directory: /nix/store/bj29nvjhx4hjfhfrwqwq1kazc3ibmq9m-clang-10.0.1-lib/lib/clang/10.0.1/include
  QString clangBuiltinIncludesDir = QLatin1String("/nix/store/bj29nvjhx4hjfhfrwqwq1kazc3ibmq9m-clang-10.0.1-lib/lib/clang/10.0.1/include"); // ${llvmPackages_10.clang-unwrapped.lib}/lib/clang/10.0.1/include/stddef.h
  std::cerr << "milahu debug: clangBuiltinIncludesDir: manually add clang include path: " << qPrintable(clangBuiltinIncludesDir) << "\n";
  p->append(HeaderPath{
    QFile::encodeName(clangBuiltinIncludesDir),
    HeaderType::System
  });
}
*/


/*
    {
        QString clangBuiltinIncludesDir("");
        qCInfo(lcShiboken, "CLANG builtins includes directory: %s",
               qPrintable(clangBuiltinIncludesDir));
        p->append(HeaderPath{QFile::encodeName(clangBuiltinIncludesDir),
                             HeaderType::System});
    }
*/

}

// Returns clang options needed for emulating the host compiler
QByteArrayList emulatedCompilerOptions()
{
    QByteArrayList result;
    HeaderPaths headerPaths;
    switch (compiler()) {
    case Compiler::Msvc:
        result.append(QByteArrayLiteral("-fms-compatibility-version=19.26.28806"));
        result.append(QByteArrayLiteral("-fdelayed-template-parsing"));
        result.append(QByteArrayLiteral("-Wno-microsoft-enum-value"));
        // Fix yvals_core.h:  STL1000: Unexpected compiler version, expected Clang 7 or newer (MSVC2017 update)
        result.append(QByteArrayLiteral("-D_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH"));
        if (needsClangBuiltinIncludes())
            appendClangBuiltinIncludes(&headerPaths);
        break;
    case Compiler::Clang:

        std::cerr << "milahu debug: Compiler::Clang\n";
        std::cerr << "milahu debug: Compiler::Clang: gppInternalIncludePaths clang++\n";

        headerPaths.append(gppInternalIncludePaths(compilerFromCMake(u"clang++"_qs)));
        result.append(noStandardIncludeOption());
        break;
    case Compiler::Gpp:

        // reached
        std::cerr << "milahu debug: Compiler::Gpp\n";

        if (needsClangBuiltinIncludes()) {
            // reached
            std::cerr << "milahu debug: Compiler::Gpp: needsClangBuiltinIncludes -> appendClangBuiltinIncludes\n";
            appendClangBuiltinIncludes(&headerPaths);
        }
        break;
    }

    detectVulkan(&headerPaths);
    std::transform(headerPaths.cbegin(), headerPaths.cend(),
                   std::back_inserter(result), HeaderPath::includeOption);
    return result;
}

LanguageLevel emulatedCompilerLanguageLevel()
{
    return LanguageLevel::Cpp17;
}

struct LanguageLevelMapping
{
    const char *option;
    LanguageLevel level;
};

static const LanguageLevelMapping languageLevelMapping[] =
{
    {"c++11", LanguageLevel::Cpp11},
    {"c++14", LanguageLevel::Cpp14},
    {"c++17", LanguageLevel::Cpp17},
    {"c++20", LanguageLevel::Cpp20},
    {"c++1z", LanguageLevel::Cpp1Z}
};

const char *languageLevelOption(LanguageLevel l)
{
    for (const LanguageLevelMapping &m : languageLevelMapping) {
        if (m.level == l)
            return m.option;
    }
    return nullptr;
}

LanguageLevel languageLevelFromOption(const char *o)
{
    for (const LanguageLevelMapping &m : languageLevelMapping) {
        if (!strcmp(m.option, o))
            return m.level;
    }
    return LanguageLevel::Default;
}

} // namespace clang
