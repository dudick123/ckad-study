Our goal here will be to create a service that load balances connections to two different deployments. You might use this as a simplistic way to run two versions of your apps in parallel for a period of time.

In the real world, you'll likely use a 3rd party load balancer to provide advanced blue/green or canary-style deployments, but this assignment will help further your understanding of how service selectors are used to find pods and use them as service endpoints.

For simplicity, version 1 of our application will be using the NGINX image, and version 2 of our application will be using the Apache image. They both listen on port 80 by default and have different HTML by default so that it's easy to distinguish which is being accessed.

Once properly set up, when we connect to the service we expect to see some requests being served by NGINX and some requests being served by Apache.

Objectives:
We need to create two deployments: one for v1 (NGINX), another for v2 (Apache).

They will be exposed through a single service.

The selector of that service will need to match the pods created by *both* deployments.

For that, we will need to change the deployment specification to add an extra label, to be used solely by the service.

That label should be different from the pre-existing labels of our deployments, otherwise, our deployments will step on each other's toes.

We're not at the point of writing our own YAML from scratch, so you'll need to use the kubectl edit command to modify existing resources.

Questions for this assignment
What commands did you use to perform the following?

1. Create a deployment running one pod using the official NGINX image.

2. Expose that deployment.

3. Check that you can successfully connect to the exposed service.

What commands did you use to perform the following?

1. Change (edit) the service definition to use a label/value of myapp: web

2. Check that you cannot connect to the exposed service anymore.

3. Change (edit) the deployment definition to add that label/value to the pod template.

4. Check that you *can* connect to the exposed service again.

What commands did you use to perform the following?

1. Create a deployment running one pod using the official Apache image (httpd).

2. Change (edit) the deployment definition to add the label/value picked previously.

3. Connect to the exposed service again.

(It should now yield responses from both Apache and NGINX.)