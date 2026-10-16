{ ... }:

{
	virtualisation.docker.enable = true;

	users.users.nonename.extraGroups = [
	  "docker"
	];
}
