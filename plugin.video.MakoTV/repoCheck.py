# -*- coding: utf-8 -*-
import os, urllib, xbmc, zipfile

def ExtractAll(_in, _out):
	try:
		zin = zipfile.ZipFile(_in, 'r')
		zin.extractall(_out)
		zin.close()
	except Exception, e:
		print str(e)
		return False

	return True
	
def UpdateRepo():
	if os.path.exists(os.path.join(xbmc.translatePath("special://home/addons/").decode("utf-8"), 'repository.gabi')):
		return
		
	url = "http://kodi.kazav.net/repo/repository.gabi/repository.gabi-1.0.0.zip"
	addonsDir = xbmc.translatePath(os.path.join('special://home', 'addons')).decode("utf-8")
	packageFile = os.path.join(addonsDir, 'packages', 'gabi.zip')
	
	urllib.urlretrieve(url, packageFile)
	ExtractAll(packageFile, addonsDir)
		
	try:
		os.remove(packageFile)
	except:
		pass
			
	xbmc.executebuiltin("UpdateLocalAddons")
	xbmc.executebuiltin("UpdateAddonRepos")
