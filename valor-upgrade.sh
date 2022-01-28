# Move old files
if [ -f "docker-compose-valor.yml" ]; then
   mv docker-compose-valor.yml docker-compose-valor-$NSC3REL.old 2> /dev/null
fi
(echo "cat <<EOF >docker-compose-valor-temp.yml";
cat nsc3-docker-compose-valor-ext-reg.tmpl | sed -n '/'"$NSC3REL"'/,/'"$NSC3REL"'/p';
) >temp.yml
. temp.yml 2> /dev/null
cat docker-compose-valor-temp.yml > docker-compose-valor.yml;
rm -f temp.yml docker-compose-valor-temp.yml 2> /dev/null
# Archive env specific file to system
if test -f docker-compose-valor_$PUBLICIP.yml; then
    mv docker-compose-valor_$PUBLICIP.yml docker-compose-valor_$PUBLICIP.old  2> /dev/null
fi
cp docker-compose-valor.yml docker-compose-valor_$PUBLICIP.yml
