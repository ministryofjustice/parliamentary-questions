# #
# # TODO
# The app should respond to /healthcheck.json to check the system components below.  
# If all components are live, a simple JSON response should return message:OK with status 200. 
# If any services are down, it should return "message:<details of error(s)>" with status 500.

# The components to be checked are:
# - we get a 200 response on the dashboard
# - we can connect to sendgrid with our credentials
# - we can connect to the Parliament API with our credentials 
# (but not more often than every 15 minutes - configurable via config file).
#
