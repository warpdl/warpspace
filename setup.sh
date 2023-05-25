verbose=false

DIRESOS=$(cat << EOF
Select an option from the following:
1 - Setup a new one with some other name
2 - Delete existing and setup a new one
3 - Git pull in the existing directory
4 - Exit program

Default Option: 3
EOF
)

WORG="https://github.com/warpdl"
WLIB=warplib
WCOR=warp

es() {
	echo
	sleep $1
}

# print won't echo if verbose is true
print() {
	if [ "$verbose" = false ]
	then
		echo $1
	else
		:
	fi
}

exec() {
	if [ "$verbose" = false ]
	then
		$1 >/dev/null 2>&1
	else
		$1
	fi
}

clone() {
	print "Cloning $1 into '$2'..."
	exec "git clone $1 $2"
	print "Successfully cloned!"	
}

pull() {
	print "Running git pull..."
	exec "git pull"	
}

askAndClone() {
	echo -n "Please enter an alternative name: "
	read name
	if [[ "$name" == "" ]]
	then
		echo "You didn't enter anything, please try again!"
		askAndClone $1
	else
		clone $1 $name
	fi
}

direso() {
	repo=$WORG/$1
	echo "Directory $1 exists already!"
	echo "$DIRESOS"
	echo
	echo -n "Please input an option: "
	read uinput
	case $uinput in
		1)
			echo "You chose option 1!"
			askAndClone $repo
			;;
		2)
			echo "You chose option 2!"
			echo "Deleting previous '$1' directory..."
			rm -rf $1
			clone $repo $1
			;;
		3 | "")
			echo "You chose option 3!"
			cd $1
			pull
			cd ..
			;;
		4)
			echo "You chose option 4!"
			echo "Exiting..."
			;;
		*)
			echo "$uinput is not a valid option! Exiting..."
			;;
	esac
}

setupRepo() {
	echo
	echo "Setting up $2..." 
	if [ -d "$1" ];
	then
		direso $1
	else
		clone $WORG/$1 $1
	fi
	echo "Done!"
}

echo "WarpDL Workspace Utility"
es 2

setupRepo $WLIB "WarpLib"
es 1

setupRepo $WCOR "Warp Core"
es 1

echo "Downloaded all the required repositories!"
es 1

echo "Creating a go workspace..."
exec "go work init"
es 1

echo "Adding all the required repositories to workspace..."
exec "go work use $WCOR $WLIB"
es 1

echo "Successfully setup workspace!"
echo "Exiting in 5s..."
es 5
