These questions will either ask for you to enter a kubectl command, other shell commands, or ask for a long-form answer. For each one expecting a command, test your answers, and then use that command as the answer to the assignment question.

The goal here is to practice thinking of kubectl commands to solve your own problems, without resorting to looking at answers. It'll help you get used to the CLI if you force yourself to use the --help as much as possible. The long-form questions are to get you thinking about the "why" of things in Kubernetes, which will deepen your understanding.

Questions for this assignment
Create a deployment called littletomcat using the tomcat image.

What command will help you get the IP address of that Tomcat server?

What steps would you take to ping it from another container?                               

(Use the shpod environment if necessary)

What command would delete the running pod inside that deployment?

What happens if we delete the pod that holds Tomcat, while the ping is running?

What command can give our Tomcat server a stable DNS name and IP address?                                         

(An address that doesn't change when something bad happens to the container)

What commands would you run to curl Tomcat with that DNS address?

(Use the shpod environment if necessary)

If we delete the pod that holds Tomcat, does the IP address still work? How could we test that?