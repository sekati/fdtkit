/*
JSFL Command:	Safe Test Movie
Version:				1.0.0
Date:					10.2006
Author:					jason m horwitz // sekati.com
License:				GNU General Public License - http://www.gnu.org/licenses/gpl.txt
*/
function clearASOCache (path) {
	if (!FLfile.exists (path)) {
		fl.trace (path + "does not exist");
		return;
	}
	FLfile.remove (path);
}
clearASOCache (fl.configURI + "Classes/aso");
fl.outputPanel.clear ();
fl.getDocumentDOM ().save ();
fl.getDocumentDOM ().testMovie ();
//fl.trace ("___Safe_Test_Movie___");