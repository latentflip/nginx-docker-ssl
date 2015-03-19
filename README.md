# T Hell S

I've just come off a project where everything needed to be served via https, even in development. Security restrictions in chrome mean that if you want to use screensharing + webrtc, you need to serve the page over ssl. And as soon as one page needs to be served over ssl, everything needs to be.

This presents a few problems in development.

1. Dev servers etc would need to be configured to serve ssl. In production we terminate ssl at the load balancer/proxy, and node servers etc don't deal with it.
2. We'd need self-signed certs which are always a pain in the butt, as you either need to add them to keychain or whatever (which I'm apparently incapable of doing in such a way that they stick; or you have to accept them all the time in chrome, which is annoying (and full of invisible failures when you're connecting to servers over ajax and chrome blocks them for you).

So, I've come up with something, that's a little crazy, but seems to work. It goes like this:

1) Run nginx in a docker container on my machine.
2) Configure /etc/hosts on my dev machine to reroute requests for a proper domain that we own (cowboy.io), to that docker container, instead of hitting the internet.
3) Configure that nginx instance to:
  * terminate ssl with proper certificates for a proper domain (cowboy.io)
  * proxy all traffic on that domain, to my dev machine (that's hosting docker), on the same port.
  * e.g. a request to https://cowboy.io:3000/foo get's routed by /etc/hosts on my devmachine to the dockered-nginx, which properly terminates ssl, and proxies the traffic to a node server running at http://<my-machine-ip>:3000/foo.
4) Repeat 3) for a load of ports (e.g. 3000 -> 3100 and 8000 -> 8100) so that I can spin up any dev server on localhost in those ranges, and automatically be able to hit it at https://cowboy.io:<port>.

## Making it work.

I'm totally new to docker, and I suck at computers, so there may be a better way. But this is what I've got so far.

1) First, I templated a `sites-enabled/default` config for nginx: [templates/default.erb](https://github.com/latentflip/nginx-docker-ssl/blob/master/templates/default.erb)
  * It's pretty basic, it just templates a long list of `listen 3000;` directives for all the ports I want.
  * Terminates ssl for them
  * And proxies them to the host machines ip on the same port.
  * Note that `{hostip}` is templated, again, not with erb. We'll come back to that.
  * You can see what it looks like [here](https://github.com/latentflip/nginx-docker-ssl/blob/master/default.tmpl)
2) Here's my [Dockerfile](https://github.com/latentflip/nginx-docker-ssl/blob/master/Dockerfile). It:
  * Installs ubuntu/nginx
  * Copies the certificates, the output of step 1), and boot.sh, into the container and builds it.
3) This is [boot.sh](https://github.com/latentflip/nginx-docker-ssl/blob/master/boot.sh)
  * This is what runs at docker start
  * It re-templates the nginx config, to insert the hostip (the ip of my dev machine as visible from the container.
  * It gets this by pulling it from `/etc/hosts` in the container, an entry for my machine is added by the `docker run` command using `--add-host`
  * It starts nginx
4) And this is the start script (templated again) (templates/start.sh.erb)[https://github.com/latentflip/nginx-docker-ssl/blob/master/templates/start.sh.erb]
  * This needs to be templated to export all the ports.
  * The output is [start.sh](https://github.com/latentflip/nginx-docker-ssl/blob/master/start.sh)
  * We also pass in the ip of my machine with `--add-host` so that it gets added to `/etc/hosts` for step 3) to pull out within the container once it starts.