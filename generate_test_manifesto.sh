#!/bin/bash 

if [ $# -ne 1 ] ; then
    echo ""
    echo "usage: $0 branchname "
    echo ""        
    exit 1
fi

if [ ! -d ../hopsworks-chef ] ; then
    echo ""    
    echo "Error."
    echo "You need to clone hopsworks-chef into the same parent directory of hops-testing."
    echo ""
    exit 2
fi

grep "branch: \"$1\"" ../hopsworks-chef/Berksfile > /dev/null

if [ $? -ne 0 ] ; then
    echo ""
    echo "Error."
    echo "Could not find the branch $1 in hopsworks-chef/Berksfile"
    echo ""    
    exit 2
fi

echo "hopshadoop/hopsworks-chef/$1" > test_manifesto
grep $1 ../hopsworks-chef/Berksfile | sed -e 's/.*hopshadoop/hopshadoop/' | sed -e 's/",\s* branch:\s*"/\//' | sed -e 's/"//' >> test_manifesto
echo ""
echo "Updated the file 'test_manifesto'"
echo "Contents:"
echo ""
cat test_manifesto
echo ""
echo "Done."
