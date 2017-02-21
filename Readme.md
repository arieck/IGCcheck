This Windows PC based validation software "IGCcheck.exe"
is part of the Open Validation Server project. 
More details, and a running version at http://vali.fai-civl.org/


Scope:
Competition Scorers may use the tool to check all IGC files
from a FS competition folder, with a single mouse click.
(instead of using the WebInterface at http://vali.fai-civl.org/)
More details, at http://fs.fai.org/

Prerequisites:
Windows 10 x86 (or x64) + .Net 3.5 and .Net 4.0

Since unfortunately some vali.exe files are not (yet) compatible
to the CIVL draft standard, you need to have .Net framework 
installed (3.5 and 4.0). 

Installation:
Download everything here from GitHub as a ZIP.
Then extract it on your PC, for example into your FS folder as a 
new subdirectory called "IGCcheck".

HowTo Run:
make sure you have the "bin" with all vali exe files within same 
directory of IGCcheck.exe.
Double click the IGCcheck.exe, you will be asked to select the 
directory where your IGC files are located.

The IGC scan may take about 2-3sec for each IGC file.
So if you have many files to check, you have to wait a while, 
until you see the result window.
The program runs completely on the background, without any progress bar.

SourceCode:
The code is based on a simple AutoIt script. 
See https://www.autoitscript.com/  for more details.
In case you want to modify the script with your needs, I recommended
to use the SciTE4AutoIt3.exe AutoIt Script Editor Installer, you can
download from autoitscript.com.

Please note, not all vali.exe binaries may work, depending on their 
implementation.
So far problems are known with XPF and XAF vali exe binaries.
But they are not really common used at competitions to create IGC files.

