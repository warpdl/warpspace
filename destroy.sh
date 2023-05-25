verbose=false

exec() {
	if [ "$verbose" = false ]
	then
		$1 >/dev/null 2>&1
	else
		$1
	fi
}

exec "rm -rf warplib"
exec "rm -rf warp"
exec "rm go.work"

echo "Destroyed WarpDL Workspace!"
