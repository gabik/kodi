for i in `ls -d plugin.video.* ` ; do  zip -r ${i}-1.0.0.zip $i ; mv -f ${i}-1.0.0.zip $i ; done

