# BrambleChallenge

To start your Phoenix server on local:

  * Install dependencies with `mix deps.get`
  * Install node dependencies `cd assets/ && npm install`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
Repeat step 5 6 7 in the below guidance with `localhost:4000` instead of `localhost:4001`

# How to run project with docker

1. Install docker (https://docs.docker.com/engine/install/) and docker-compose
2. Create `.env` file in the root directory and add your environment variable to the following
```
DATABASE_URL=postgres://postgres:postgres@db:5432/bramble_challenge_dev
SECRET_KEY_BASE=YOUR_SECRET_KEY_BASE
```
You can generate secret key by running: `mix phx.gen.secret`

3. Execute command below in the shell
```
`$ docker-compose up
```
4. Navigate to localhost:4001 in the browser
5. Start registering an user at `http://localhost:4001/users/register`
6. You can navigate to live_view page at `http://localhost:4001/users/requests`
7. Test out API after you has registered an user.
Get an `access token` with:
```
curl -X POST -H "Content-Type: application/json" -u your_email:password localhost:4001/api/auth/token
```

Send an API request:
```
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer your_access_token" localhost:4001/api/user-requests
```

# Running tests

Run all current test cases with:
```
mix test
```


