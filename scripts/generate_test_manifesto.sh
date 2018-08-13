#!/bin/bash 

if [ $# -lt 1 ] ; then
    echo ""
    echo "usage: $0 [rollback] branchname [no-hopsworks]"
    echo ""        
    exit 1
fi

NO_HOPSWORKS=0

if [ $# -eq 2 ] ; then

    if [ "$1" == "rollback" ] ; then
	cd ../hopsworks-chef
	cp -f Berksfile.${2} Berksfile
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
    if [ "$2" == "no-hopsworks" ] ; then
	NO_HOPSWORKS=1
    fi
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

repo=$(git remote -v | grep origin | grep fetch | sed -e 's/origin\tgit@github.com://' | sed -e 's/\/.*//')

if [ $NO_HOPSWORKS -eq 0 ] ; then
    echo "${repo}/hopsworks/$1" > test_manifesto
    echo "logicalclocks/hopsworks-chef/$1" >> test_manifesto
else
    echo "logicalclocks/hopsworks-chef/$1" > test_manifesto    
fi    

grep $1 ../hopsworks-chef/Berksfile.${1} | sed -e 's/.*logicalclocks/logicalclocks/' | sed -e 's/",\s* branch:\s*"/\//' | sed -e 's/"//' >> test_manifesto

git commit -am 'updated test_manifesto'
git push
echo ""
echo "Updated the file 'test_manifesto'"
echo "Contents:"
echo ""
cat test_manifesto
echo ""
echo "Done."
