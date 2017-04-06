repos="kodil/kodil teamThevibe/thevibe-repo"

for i in $repos ; do
  echo ${i}
  file=$(echo "${i}" | cut -d\/ -f2)
	wget --no-check-certificate "http://github.com/${i}/archive/master.zip" -O ${file}.zip
done
