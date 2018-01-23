# Bintype

`bintype` is a `newLISP` script that determines if a Windows executable is a 32-bit or 64-bit executable. It simply uses the Win32 `GetBinaryType` function from the `kernell32` Windows DLL.

For more information about `GetBinaryType`, consult the following Microsoft documentation: https://msdn.microsoft.com/en-us/library/windows/desktop/aa364819(v=vs.85).aspx.

Standalone executables of `bintype` are available in the releases area: https://github.com/andreburgaud/bintype/releases

## Using as a Script

`newLISP` needs to be installed on your Windows OS and available in the Windows `PATH`. In the `bintype` project directory:

```
C:/projects/bintype> newlisp bintype.lsp newlisp.exe

                                 Bintype 1.0.0
                         Copyright (C) 2018 Burgaud.com
                                 Andre Burgaud

newlisp.exe: 64-bit Windows-based application
```

## Build a Standalone Executable

In the `bintype` project directory:

```
C:/projects/bintype> newlisp build.lsp
newLISP v.10.7.1 64-bit on Windows IPv4/6 libffi.

Good: newLISP was found on the PATH!
Building bintype.exe...
The build was successful!
C:/projects/bintype> dir *.exe
 Volume in drive C has no label.
 Volume Serial Number is F66E-3BEE

 Directory of C:\Users\andre\AB\git\bintype

01/22/2018  11:16 PM           320,575 bintype.exe
```

## Licenses

* The source code of `Bintype` is released under the MIT license (see file [LICENSE](LICENSE.md)).
* `newLISP` http://www.newlisp.org/ is distributed under a GPL v3 license.
* `newLISP` allows to distribute the binary of the interpreter togeter with closed source http://www.newlisp.org/index.cgi?FAQ
* The binary of the `newLISP` interpreter is distributed with the `Bintype` standalone executable available in the `Releases` area https://github.com/andreburgaud/bintype/releases.

## Resources

* http://www.newlisp.org/
