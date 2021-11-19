Let's deploy another application called wordsmith
Wordsmith has 3 components:

a web frontend bretfisher/wordsmith-web

an API backend bretfisher/wordsmith-words

a postgres DB bretfisher/wordsmith-db

These images have been built and pushed to Docker Hub

We want to deploy all 3 components on Kubernetes



Here's how the parts of this app communicate with each other:

The web frontend listens on port 80

The web frontend should be public (available on a high port from outside the cluster)

The web frontend connects to the API at the address http://words:8080

The API backend listens on port 8080

The API connects to the database with the connection string pgsql://db:5432

The database listens on port 5432

Your Assignment is to create the kubectl create commands to make this all work
This is what we should see when we bring up the web frontend on our browser:


  (You will probably see a different sentence, though.)

- Yes, there is some repetition in that sentence; that's OK for now

- If you see empty LEGO bricks, something's wrong ...

Questions for this assignment
What deployment commands did you use to create the pods?

What service commands did you use to make the pods available on a friendly DNS name?

If we add more wordsmith-words API pods, then when the browser is refreshed, you'll see different words. What is the command to scale that deployment up to 5 pods? Test it to ensure a browser refresh shows different words.