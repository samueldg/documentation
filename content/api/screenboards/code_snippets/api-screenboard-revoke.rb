require 'rubygems'
require 'dogapi'

api_key = '<YOUR_API_KEY>'
app_key = '<YOUR_APP_KEY>'

dog = Dogapi::Client.new(api_key, app_key)

board_id = '6334'

# Share it
dog.share_screenboard(board_id)

# Revoke the sharing
dog.revoke_screenboard(board_id)