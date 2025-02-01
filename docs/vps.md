install nixos over the existing OS in a DigitalOcean droplet (and others with minor modifications)
ref:: https://github.com/elitak/nixos-infect




How to run a docker container declaratively on nixos ?
    How do I run a docker container declaratively on nixos server ? I am trying to run whoogle on a nix server and I don't wish to manually restart the whoogle container everytime I restart the server.
    ref:: https://www.reddit.com/r/NixOS/comments/wcybfa/how_to_run_a_docker_container_declaratively_on/
    
    This creates a new SystemD service that runs automatically on boot and captures logs and stats too. I use it for running a bunch of docker containers on NixOS
        virtualisation.oci-containers.containers.whoogle = {                                                     
            image = "benbusby/whoogle-search";
            ports = [ "0.0.0.0:5000:5000" ];
        };