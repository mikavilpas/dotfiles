# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_mika_global_optspecs
	string join \n h/help V/version
end

function __fish_mika_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_mika_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_mika_using_subcommand
	set -l cmd (__fish_mika_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c mika -n "__fish_mika_needs_command" -s h -l help -d 'Print help'
complete -c mika -n "__fish_mika_needs_command" -s V -l version -d 'Print version'
complete -c mika -n "__fish_mika_needs_command" -f -a "summary" -d 'Summarize commits in markdown format, for quick PR descriptions'
complete -c mika -n "__fish_mika_needs_command" -f -a "branch-summary" -d 'Summarize the commits on the given branch, before any other local branch is reached'
complete -c mika -n "__fish_mika_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c mika -n "__fish_mika_using_subcommand summary" -l from -d 'The start ref, e.g. HEAD in (HEAD..main)' -r
complete -c mika -n "__fish_mika_using_subcommand summary" -l to -d 'The end ref, e.g. main in (HEAD..main)' -r
complete -c mika -n "__fish_mika_using_subcommand summary" -s h -l help -d 'Print help'
complete -c mika -n "__fish_mika_using_subcommand branch-summary" -l branch -d 'The branch to summarize' -r
complete -c mika -n "__fish_mika_using_subcommand branch-summary" -s h -l help -d 'Print help'
complete -c mika -n "__fish_mika_using_subcommand help; and not __fish_seen_subcommand_from summary branch-summary help" -f -a "summary" -d 'Summarize commits in markdown format, for quick PR descriptions'
complete -c mika -n "__fish_mika_using_subcommand help; and not __fish_seen_subcommand_from summary branch-summary help" -f -a "branch-summary" -d 'Summarize the commits on the given branch, before any other local branch is reached'
complete -c mika -n "__fish_mika_using_subcommand help; and not __fish_seen_subcommand_from summary branch-summary help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
