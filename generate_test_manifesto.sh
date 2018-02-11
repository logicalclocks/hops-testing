#!/bin/bash 

if [ $# -lt 1 ] ; then
    echo ""
    echo "usage: $0 [rollback] branchname "
    echo ""        
    exit 1
fi

if [ $# -eq 2 ] ; then

    cd ../hopsworks-chef
    cp -f Berksfile.${2} Berksfile
    exit 1
    git commit -am 'Berksfile un-mastering from hops-testing for Vagrant'
    git push
    if [ $? -ne 0 ] ; then
	echo ""
	echo "Error."
	echo "Could not push Berksfile un-masterizing to github"
	echo ""    
	exit 12
    fi
    cd ../hops-testing
    exit 0
fi

if [ ! -d ../hopsworks-chef ] ; then
    echo ""    
    echo "Error."
    echo "You need to clone hopsworks-chef into the same parent directory of hops-testing."
    echo ""
    exit 2
fi

cd ../hopsworks-chef
git checkout $1
if [ $? -ne 0 ] ; then
    echo ""
    echo "Error."
    echo "Could not find branch $1 in hopsworks-chef"
    echo ""
    exit 4
fi

grep "branch: \"$1\"" Berksfile > /dev/null

if [ $? -ne 0 ] ; then
    echo ""
    echo "Error."
    echo "Could not find the branch $1 in hopsworks-chef/Berksfile"
    echo ""    
    exit 2
fi

cp -f Berksfile Berksfile.$1

perl -pi -e "s/branch: \"$1\"/branch: \"master\"/" Berksfile

git commit -am 'Berksfile mastering for hops-testing'
git push
if [ $? -ne 0 ] ; then
    echo ""
    echo "Error."
    echo "Could not push Berksfile masterizing to github"
    echo ""    
    exit 12
fi

cd ../hops-testing

echo "hopshadoop/hopsworks-chef/$1" > test_manifesto
grep $1 ../hopsworks-chef/Berksfile.${1} | sed -e 's/.*hopshadoop/hopshadoop/' | sed -e 's/",\s* branch:\s*"/\//' | sed -e 's/"//' >> test_manifesto
echo ""
echo "Updated the file 'test_manifesto'"
echo "Contents:"
echo ""
cat test_manifesto
echo ""
echo "Done."
