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

#include <iostream>

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
static HeaderPaths gppInternalIncludePaths(const QString &compiler)
{
    HeaderPaths result;
    QStringList arguments;
    arguments << QStringLiteral("-E") << QStringLiteral("-x") << QStringLiteral("c++")
         << QStringLiteral("-") << QStringLiteral("-v");
    QByteArray stdOut;
    QByteArray stdErr;

// milahu debug
std::cerr << "milahu err: g++ -E -x c++ - -v\n";
//std::cerr << "milahu err: arguments = " << arguments.join("  ").toStdString() << '\n'; // error: qstring is private (what??)

    if (!runProcess(compiler, arguments, &stdOut, &stdErr)) {

// milahu debug
std::cerr << "milahu err: runProcess failed\n";

        return result;
    }
    const QByteArrayList stdErrLines = stdErr.split('\n');
    bool isIncludeDir = false;
    for (const QByteArray &line : stdErrLines) {

// milahu debug
qCInfo(lcShiboken) <<
  "milahu 1: g++ output line = " << line.constData();
std::cerr <<
  "milahu 2: g++ output line = " << line.constData() << '\n';

        if (isIncludeDir) {
            if (line.startsWith(QByteArrayLiteral("End of search list"))) {
                isIncludeDir = false;
            } else {
                HeaderPath headerPath{line.trimmed(), HeaderType::System};
                if (headerPath.path.endsWith(frameworkPath())) {
// milahu debug
qCInfo(lcShiboken) <<
  "milahu 1: headerPath.path = " << headerPath.path.constData() << " : ends with frameworkPath = " << frameworkPath().constData();
std::cerr <<
  "milahu 2: headerPath.path = " << headerPath.path.constData() << " : ends with frameworkPath = " << frameworkPath().constData() << '\n';
                    headerPath.type = HeaderType::FrameworkSystem;
                    headerPath.path.truncate(headerPath.path.size() - frameworkPath().size());
// milahu debug
qCInfo(lcShiboken) <<
  "headerPath.path = " << headerPath.path.constData() << " : truncated = remove frameworkPath suffix";
std::cerr <<
  "milahu 2: headerPath.path = " << headerPath.path.constData() << " : truncated = remove frameworkPath suffix" << '\n';
                }
// milahu debug
else {
qCInfo(lcShiboken) <<
  "headerPath.path = " << headerPath.path.constData() << " : no frameworkPath";
std::cerr <<
  "milahu 2: headerPath.path = " << headerPath.path.constData() << " : no frameworkPath";
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

static QStringList findClangLibDirList()
{
    QStringList result;
    for (const char *envVar : {"LLVM_INSTALL_DIR", "CLANG_INSTALL_DIR"}) {
        if (qEnvironmentVariableIsSet(envVar)) {
            const QString path = QFile::decodeName(qgetenv(envVar)) + QLatin1String("/lib");
            if (QFileInfo::exists(path))
                result << path;
            else
                qWarning("%s: %s as pointed to by %s does not exist.", __FUNCTION__, qPrintable(path), envVar);
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

// milahu debug
std::cerr << "milahu cerr: clangPathLibDir = " << clangPathLibDir.toStdString() << '\n';
std::cerr << "milahu cerr: clangDirName = " << clangDirName.toStdString() << '\n';
//std::cerr << "milahu cerr: clangDir = " << clangDir << '\n';

/*
milahu cerr: clangPathLibDir = /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib
milahu cerr: clangDirName = /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib/clang
milahu cerr: clangBuiltinIncludesDir = /nix/store/r0zab6w8bwf93id0pq9pkwf3iw441zs7-clang-9.0.1-lib/lib/clang/9.0.1/include
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
        if (!candidate.isEmpty())
            result << candidate + QStringLiteral("/include");
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

    const QStringList clangBuiltinIncludesDirList = findClangBuiltInIncludesDirList();

    std::transform(
        findClangBuiltInIncludesDirList.begin(),
        findClangBuiltInIncludesDirList.end(),
        findClangBuiltInIncludesDirList.begin(),
        QDir::toNativeSeparators
    );



// milahu debug
std::cerr << "milahu cerr: clangBuiltinIncludesDir = " << clangBuiltinIncludesDir.toStdString() << '\n';

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
            qCInfo(lcShiboken, "CLANG builtins includes directory: %s",
                qPrintable(clangBuiltinIncludesDir));
            p->append(HeaderPath{QFile::encodeName(clangBuiltinIncludesDir),
                                HeaderType::System});
        }
    }


// milahu debug
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
        headerPaths.append(gppInternalIncludePaths(compilerFromCMake(u"clang++"_qs)));
        result.append(noStandardIncludeOption());
        break;
    case Compiler::Gpp:
        if (needsClangBuiltinIncludes())
            appendClangBuiltinIncludes(&headerPaths);
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
