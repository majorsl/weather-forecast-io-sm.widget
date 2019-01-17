iconSet = "Yahoo"
numberOfDays = 8 # max of 8 days
numberOfAlerts = 2
latitude = "44.804690"
longitude = "-74.678010"
apiKey = "yourkeyhere"
showForecast = 1
debug = 0

command: "curl -s 'https://api.forecast.io/forecast/#{apiKey}/#{latitude},#{longitude}?exclude=minutely,hourly,flags'"

refreshFrequency: '30m'

style: """
  bottom: 10px
  right: 10px
  font-family: Helvetica Neue
  color: #fff
  padding 10px 10px 15px
  border-radius 3px
  .weather
    display: flex
  .alert-container
    display: flex
    flex-direction: column
    justify-content: center
    background: rgba(#FFFDB8, .4)
  .alertforecast
    font-size: 12px
    max-width: 650px
    text-shadow: black 1px 1px 0px
    font-weight: bolder
  .text-container
    display: flex
    flex-direction: column
    justify-content: center
    border-style: solid
    border-width: 1px
    border-color: #262626
    border-radius: 3px
    background: rgba(#000, .5)
    padding-left 5px
  .image-container
    display: flex
    flex-direction: column
    justify-content: center
    padding-left: 5px
    padding-right: 5px
    border-style: solid
    border-width: 1px
    border-color: #262626
    border-radius: 1px
    background: rgba(#000, .5)
  .conditions
    font-size: 20px
    font-weight: bold
    text-shadow: black 1px 2px 0px
    text-align: center
  .precip
    font-size: 12px
    font-weight: bold
    text-shadow: black 1px 1px 0px
    text-align: center
    color: #C5CCED
  .apparent
    font-size: 12px
    font-weight: bold
    text-shadow: black 1px 1px 0px
    text-align: right
    color: #b2b2b2
  .time
    font-size: 9px
    padding-top: 7px
    font-weight: bold
    color: #b2b2b2
    text-align: left
  .forecast
    font-size: 12px
    max-width: 650px
    text-shadow: black 1px 1px 0px
    font-weight: bolder
    padding-right: 5px
  .date
    width: 30px
    float: left
  .datetoday
    width: 39px
    float: left
  .temp
    width: 44px
    float: left
  .desc
    float: left
  .hi
    color: #ffa291
    position: relative
    font-size: 12px
  .low
    color: #C5CCED
    letter-spacing: -1px
    position: relative
    top: 0px
    font-size: 10px
  img
    height: 100px
    display: block
    margin-top: 0px
    margin-left: auto;
    margin-right: auto;
"""

render: -> """
  <div class="weather">
    <div class="alert-container">
      <div class="alertforecast"></div>
    </div>
    <div class="text-container">
      <div class="forecast"></div>
      <div class="time"></div>
    </div>
    <div class="image-container">
      <div class="conditions"></div>
      <div class="apparent"></div>
      <div class="image"></div>
      <div class="precip"></div>
  </div>
"""

update: (output, domEl) ->
  weatherData = JSON.parse(output)
  if debug
    console.log(weatherData)
  # image
  $(domEl).find('.image').html('<img src=' + "weather-forecast-io-sm.widget/images/" + iconSet + "/" + weatherData.currently.icon + ".png"+ '>')
  
  # current conditions
  current = weatherData.currently.summary + ", " + Math.round(weatherData.currently.temperature) + "°"
  $(domEl).find('.conditions').html(current)

  # apparent temp (feels like)
  apparent = "Feels Like " + Math.round(weatherData.currently.apparentTemperature) + "°"
  $(domEl).find('.apparent').html(apparent)

  # chance of precip for the day
  precip = "Chance of Precipitation: " + Math.round(100 * weatherData.daily.data[0].precipProbability) + "%"
  $(domEl).find('.precip').html(precip)

  # moon phase (possibly future use)
  # moon = weatherData.daily.data[0].moonPhase

  # forecast-alerts
  if showForecast == 1 || weatherData.hasOwnProperty('alerts')
    forecast = ""
    if weatherData.hasOwnProperty('alerts')
      if numberOfAlerts < weatherData.alerts.length
        maxAlerts = numberOfAlerts
      else
        maxAlerts = weatherData.alerts.length
      for i in [0..maxAlerts-1]
        forecast = forecast + "<div style='white-space: pre-wrap; color:#f34b38; padding-left:5px'>" + weatherData.alerts[i].title + ": <span style='color:#D0EDC5'> Expires " + new Date(weatherData.alerts[i].expires * 1000).toLocaleDateString('en-US', { weekday: 'short', hour: 'numeric', minute: 'numeric' });"</div>"
        forecast = forecast + "<span style='color:white'><br>" + weatherData.alerts[i].description + "<p>"
        forecast = forecast.replace(/\n/g, " ")
        forecast = forecast.replace(/\*/g, "\n* ")
    forecast = forecast.replace(/ +/g, " ")
    $(domEl).find('.alertforecast').html(forecast)
  # forecast
    forecast = ""
    if numberOfDays > 8
      maxDays = 8
    else
      maxDays = numberOfDays
      for i in [0..numberOfDays-1]
        forecastDate = "<div class=date>" + new Date(weatherData.daily.data[i].time * 1000).toLocaleDateString('en-US', {weekday: 'short'}) + "</div>"
        forecastTemps = "<div class=temp><span class=hi>" + Math.round(weatherData.daily.data[i].temperatureMax) + "°</span><span class=low>&#8675;" + Math.round(weatherData.daily.data[i].temperatureMin)+ "°</span></div>"
        forecastDescr = "<div class=desc>" + weatherData.daily.data[i].summary + "</div><br>"
        forecast = forecast + forecastDate + forecastTemps + forecastDescr
    forecast = forecast.replace(/ +/g, " ")
    $(domEl).find('.forecast').html(forecast)
    # time of last update
    time = "Last update: " + new Date(weatherData.currently.time * 1000).toLocaleDateString('en-US', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric', hour: 'numeric', minute: 'numeric' });
    $(domEl).find('.time').html(time)
