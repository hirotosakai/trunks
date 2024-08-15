-- Copyright (c) 2005 Hiroto Sakai
-- 
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included
-- in all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

try
	tell application "AppleGlot"
		activate
	end tell
	
	tell application "System Events"
		tell process "AppleGlot"
			-- click menu item "Initial Pass (create NewLoc, using _OldLoc if available)" of menu "Actions" of menu bar 1
			click menu item "Incremental Pass (update NewLoc from Glossaries)" of menu "Actions" of menu bar 1
			-- click menu item "Final Pass (remove temporary working files)" of menu "Actions" of menu bar 1
		end tell
	end tell
	return true
on error errMsg number errNum
	return false
end try
