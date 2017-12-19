#!/bin/bash -x

repo_dir="/home/gabi/kodi/repo"
cd $repo_dir/repos
src_dir="${repo_dir}/repos/input"
full_archive="${repo_dir}/repos/full_archive"

upgrade_list=$(ls $src_dir)
if [[ $# -eq 1 ]] ; then upgrade_list=${1} ; fi


cd output

for i in ${upgrade_list} ; do
	rdir="$(cat ${src_dir}/${i} | head -1)"
	if grep $i $full_archive &> /dev/null ; then
		curl -LOsk ${rdir}/archive/master.zip
		unzip master.zip
		mv ${i}-master ${i}
		cd ${i}
		#newver=$(cat addon.xml | grep version | grep -v xml | head -1 | cut -d\" -f2)
		newver=$(cat addon.xml | perl -pe 's/<\?xml .*?>//' | perl -ne 'print $1, "\n" if /version=\"(.*?)\"/' | head -1)
		cd ..
		file=${i}-${newver}.zip
		zip -r $file ${i}
		rm -rf ${i}
		rm master.zip
	else
		rfile=$(curl -s ${rdir} | grep zip | cut -d\" -f4 | grep -e "zip$" | sort --version-sort | tail -1)
		rlink=https://github.com$(echo ${rfile} | sed  "s/\/blob\//\/raw\//")
		curl -LOsk ${rlink}
		file=$(echo $rlink | xargs basename)
	fi
	cp -f $file ${repo_dir}/$i
	rm $file
done

OLD_IFS=$IFS
IFS=

ADDONS_HEAD='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<addons>

<addon id="repository.gabi" name="Gabi repository" version="1.0.1" provider-name="Gabi">
        <extension point="xbmc.addon.repository" name="Gabi repository">
                <dir>
                        <info compressed="false">http://kodi.kazav.net/repo/addons.xml</info>
                        <checksum>http://kodi.kazav.net/repo/addons.xml.md5</checksum>
                        <datadir zip="true">http://kodi.kazav.net/repo/</datadir>
                </dir>
                <info compressed="false">http://kodi.kazav.net/repo/addons.xml</info>
                <checksum>http://kodi.kazav.net/repo/addons.xml.md5</checksum>
                <datadir zip="true">http://kodi.kazav.net/repo/</datadir>
        </extension>
        <extension point="xbmc.addon.metadata">
                <summary>Install Add-ons from Gabi</summary>
                <description>Download and install add-ons from Gabi repository.</description>
                <platform>all</platform>
        </extension>
</addon>
'

cd $repo_dir
mv addons.xml old_addons.xml
rm addons.xml*

echo $ADDONS_HEAD > addons.xml

IFS=$OLD_IFS

for i in $(ls -l | grep ^d | awk '{print $NF}' | grep -v ^repos$ | grep -v ^repository.gabi$) ; do
	cd ${i}
	rm -rf ${i}
	new=$(ls *zip | sort --version-sort | tail -1)
	unzip ${new}
	cd ${i}
	cat addon.xml | perl -pe 's/<\?xml .*?>//' | perl -pe 's/<import addon="repository.*$//' >> ${repo_dir}/addons.xml
	cd ..
	rm -rf ${i}
	cd ..
done

cd $repo_dir

echo '
</addons>' >> addons.xml

md5sum addons.xml | awk '{print $1}'> addons.xml.md5

if ! xmllint --noout addons.xml ; then echo "addons.xml Chack failed!!!!" 
else 
	echo "addons.xml validated OK." 
	diff old_addons.xml addons.xml
	rm old_addons.xml
fi
