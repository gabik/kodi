#!/bin/bash -x

repo_dir="/home/gabi/kodi/repo"
src_dir="${repo_dir}/repos/input"
full_archive="${repo_dir}/repos/full_archive"

cd output

for i in $(ls $src_dir) ; do
	rdir="$(cat ${src_dir}/${i} | head -1)"
	if grep $i $full_archive &> /dev/null ; then
		curl -LOsk ${rdir}
		unzip master.zip
		mv ${i}-master ${i}
		cd ${i}
		newver=$(head -1 changelog.txt)
		cd ..
		file=${i}-${newver}.zip
		zip -r $file ${i}
		rm -rf ${i}
		rm master.zip
	else
		rfile=$(curl -s ${rdir} | grep zip | cut -d\" -f4 | tail -1)
		rlink=https://github.com$(echo ${rfile} | sed  "s/\/blob\//\/raw\//")
		curl -LOsk ${rlink}
		file=$(echo $rlink | xargs basename)
	fi
	cp -f $file ${repo_dir}/$i
	rm $file
done

exit 0

OLD_IFS=$IFS
IFS=

ADDONS_HEAD="
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
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
"

cd $repo_dir
rm addons.xml*

echo $ADDONS_HEAD > addons.xml

for i in $(ls -l | grep ^d | awk '{print $NF}' | grep -v ^repo) ; do
	cd ${i}
	find * -type d -exec rm -rf {} \;
	new=$(ls *zip | tail -1)
	unzip ${new}
	cd $(find * -type d | tail -1)
	cat addon.xml >> ${repo_dir}/addons.xml
	cd ..
	find * -type d -exec rm -rf {} \;
	cd ..
done

cd $repo_dir

echo '
</addons>' >> addons.xml

md5sum addons.xml | awk '{print $1}'> addons.xml.md5

