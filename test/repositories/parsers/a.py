import http.client
import urllib.request
import urllib.parse

# Enable debugging output
http.client.HTTPConnection.debuglevel = 1

# Sample data
url = 'https://www.douyu.com/lapi/live/getH5Play/24422'
data =  {
    "v": "220120241110",
    "did": "10000000000000000000000000003306",
    "tt": "1731190002",
    "sign": "cebadc06ea58ca84cd07a09f83789e9f",
    "ver": "22011191",
    "rid": "24422",
    "rate": "0"
  }
encoded_data = urllib.parse.urlencode(data).encode("utf-8")

# Make the request
req = urllib.request.Request(url, data=encoded_data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
with urllib.request.urlopen(req) as response:
    response_data = response.read()
    print(response_data.decode('utf-8'))