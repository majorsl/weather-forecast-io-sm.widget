iconSet = "Yahoo"
numberOfDays = 5 # max of 8 days
numberOfAlerts = 2
latitude = "44.804690"
longitude = "-74.678010"
apiKey = "youkeyinhere"
showForecast = 1
debug = 0

command: "curl -s 'https://api.forecast.io/forecast/#{apiKey}/#{latitude},#{longitude}?exclude=minutely,hourly,flags'"

refreshFrequency: '30m'

style: """
  bottom: 10px
  right: 10px
  font-family: Helvetica Neue
  color: #fff
  background rgba(#000, .5)
  padding 10px 10px 15px
  border-radius 5px
  .weather
    display: flex
  .text-container
    display: flex
    flex-direction: column
    justify-content: center
  .image-container
    display: flex
    flex-direction: column
    justify-content: center
    padding-left: 5px
    padding-right: 5px
    border-style: solid
    border-width: 1px
    border-color: #262626
    border-radius: 9px
  .conditions
    font-size: 20px
    font-weight: bold
    text-shadow: black 1px 2px 0px
    text-align: center
  .time
    font-size: 9px
    padding-top: 7px
  .forecast
    font-size: 12px
    max-width: 650px
    text-shadow: black 1px 1px 0px
    font-weight: bolder
    padding-right: 5px
  .date
    width: 35px
    float: left
  .temp
    width: 50px
    float: left
  .desc
    float: left
  img
    height: 100px
    display: block
    margin-top: 1px
"""

render: -> """
  <div class="weather">
    <div class="text-container">
      <div class="forecast"></div>
      <div class="time"></div>
    </div>
    <div class="image-container">
      <div class="conditions"></div>
      <div class="image"></div>
  </div>
"""

update: (output, domEl) ->
  weatherData = JSON.parse(output)
  if debug
    console.log(weatherData)
  # image
  if weatherData.hasOwnProperty('alerts!')
    $(domEl).find('.image').html('<img src=' + "weather-forecast-io-sm.widget/images/" + iconSet + "/severe.png" + '>')
  else
    $(domEl).find('.image').html('<img src=' + "weather-forecast-io-sm.widget/images/" + iconSet + "/" + weatherData.currently.icon + ".png"+ '>')

  # time of last update
  time = "Last update: " + new Date(weatherData.currently.time * 1000).toLocaleDateString('en-US', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric', hour: 'numeric', minute: 'numeric' });
  $(domEl).find('.time').html(time)

  # current conditions
  current = weatherData.currently.summary + ", " + Math.round(weatherData.currently.temperature) + "°"
  $(domEl).find('.conditions').html(current)

  # forecast
  if showForecast == 1 || weatherData.hasOwnProperty('alerts')
    forecast = ""
    if weatherData.hasOwnProperty('alerts')
      if numberOfAlerts < weatherData.alerts.length
        maxAlerts = numberOfAlerts
      else
        maxAlerts = weatherData.alerts.length
      for i in [0..maxAlerts-1]
        forecast = forecast + "<div style='white-space: pre-wrap; color:yellow'>" + weatherData.alerts[i].title + ": <span style='color:white'> Expires " + new Date(weatherData.alerts[i].expires * 1000).toLocaleDateString('en-US', { weekday: 'short', hour: 'numeric', minute: 'numeric' });"</div>"
        forecast = forecast + "<br>" + weatherData.alerts[i].description + "<p>"
        forecast = forecast.replace(/\n/g, " ")
        forecast = forecast.replace(/\*/g, "\n* ")
    else
      if numberOfDays > 8
        maxDays = 8
      else
        maxDays = numberOfDays
      for i in [0..numberOfDays-1]
        forecastDate = "<div class=date>" + new Date(weatherData.daily.data[i].time * 1000).toLocaleDateString('en-US', {weekday: 'short'}) + "</div>"
        forecastTemps = "<div class=temp>" + Math.round(weatherData.daily.data[i].temperatureMax) + "° / " + Math.round(weatherData.daily.data[i].temperatureMin)+ "°</div>"
        forecastDescr = "<div class=desc>" + weatherData.daily.data[i].summary + "</div><br>"
        forecast = forecast + forecastDate + forecastTemps + forecastDescr
    forecast = forecast.replace(/ +/g, " ")
    $(domEl).find('.forecast').html(forecast)
