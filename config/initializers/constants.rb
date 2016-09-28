LARGEST_POSTGRES_INTEGER = 2147483647
def parliament_session_start
  Date.strptime("{ 2016, 5, 19 }", "{ %Y, %m, %d }")
end
