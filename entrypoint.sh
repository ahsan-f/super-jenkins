#!/bin/bash
# entrypoint.sh: jenkins-ngrok-builder/entrypoint.sh
export NGROK_AUTHTOKEN=335o6Wmz7pe6BlhcLRAhKPKAas6_5dfx474zMCTBqDN9RXNcb
# Check if NGROK_AUTH_TOKEN is provided
if [ -z "$NGROK_AUTH_TOKEN" ]; then
  echo "WARNING: NGROK_AUTH_TOKEN environment variable not set. Ngrok will not start."
else
  echo "Configuring Ngrok..."
  /usr/local/bin/ngrok authtoken "$NGROK_AUTH_TOKEN"

  echo "Starting Ngrok tunnel for Jenkins (port 8080) in the background..."
  # Use the Ngrok v2 API for more robust background tunneling
  /usr/local/bin/ngrok http 8080 --log=stdout > /var/log/ngrok.log 2>&1 &

  # Give ngrok a moment to start and retrieve the URL
  sleep 5
  NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')
  if [ -n "$NGROK_URL" ]; then
    echo "Ngrok tunnel started! Jenkins will be accessible at: $NGROK_URL"
    echo "Ngrok URL: $NGROK_URL" > /var/log/jenkins/ngrok_url.log
  else
    echo "Failed to retrieve Ngrok public URL."
    cat /var/log/ngrok.log # Print ngrok logs for debugging
  fi
fi

# Start Jenkins
echo "Starting Jenkins..."
exec /usr/local/bin/jenkins.sh "$@"
