#!/bin/bash

FILE=db.csv

Log(){
echo $(date) "$@"
}

if [ ! -f ${FILE} ]
then
Log WARN file not found, creating an empty one now
touch ${FILE}
fi


Create(){
#Locking the file
{
flock -x 3
#get the ID of the last line
LATESTEXISTINGID=`tail -1 ${FILE} | grep -o ^[0-9]*`
IDCANDIDATE=$(( LATESTEXISTINGID + 1 ))
#echo $IDCANDIDATE
#We find the first suitable unitilised ID
while Exists $IDCANDIDATE
do
Log INFO ID is taken, choosing another one
IDCANDIDATE=$(( IDCANDIDATE + 1 ))
done
echo "${IDCANDIDATE},$1,$2" >> ${FILE}

#sleep 30
} 3>dblock.lock



}

Read(){
IDSOUGHT="$1"
grep -E "^$IDSOUGHT," ${FILE}
}

Update(){
#Locking the file
{
flock -x 3
IDCANDIDATE=$1
if Exists $IDCANDIDATE
then
Log INFO exists
sed "s/^${IDCANDIDATE},.*/${IDCANDIDATE},$2,$3/g" ${FILE} > ${FILE}.tmp
mv ${FILE}.tmp ${FILE}
else
Log WARN "Entry doesn't exist"
fi

} 3>dblock.lock

}

Delete(){
#Locking the file
{
flock -x 3
IDCANDIDATE=$1
if Exists $IDCANDIDATE
then
Log INFO exists
sed "/^${IDCANDIDATE},.*/d" ${FILE} > ${FILE}.tmp
mv ${FILE}.tmp ${FILE}
else
Log WARN "Entry doesn't exist"
fi



} 3>dblock.lock

}

Exists(){
IDWANTED="$1"
return $( grep -qE "^$IDWANTED," ${FILE})
}

